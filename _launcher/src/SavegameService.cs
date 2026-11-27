using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Web.Script.Serialization;

namespace BladeOfAgonyLauncher
{
    internal sealed class SavegameInfo
    {
        internal string Path;
        internal string Title;
        internal string CurrentMap;
        internal string Comment;
        internal string Software;
        internal string GameWad;
        internal DateTime CreationTime;
        internal DateTime LastWriteTime;
        internal bool IsMultiplayer;
        internal byte[] PreviewPng
        {
            get { return SavegameService.ReadPreview(Path); }
        }

        internal string Kind
        {
            get
            {
                string name = System.IO.Path.GetFileNameWithoutExtension(Path) ?? string.Empty;
                if (name.StartsWith("auto", StringComparison.OrdinalIgnoreCase)) return "Auto";
                if (name.StartsWith("quick", StringComparison.OrdinalIgnoreCase)) return "Quick";
                return "Manual";
            }
        }

        internal string DisplayTitle
        {
            get
            {
                if (string.IsNullOrWhiteSpace(Comment)) {
                    return string.IsNullOrWhiteSpace(Title)
                        ? System.IO.Path.GetFileName(Path)
                        : Title;
                }
                string normalized = Comment.Replace("\r\n", "\n").Replace('\r', '\n');
                string[] lines = normalized.Split(
                    new[] { '\n' }, StringSplitOptions.RemoveEmptyEntries);
                List<string> parts = new List<string>();
                foreach (string line in lines) {
                    string part = line.Trim();
                    if (part.Length > 0) parts.Add(part);
                }
                return string.Join(" - ", parts.ToArray());
            }
        }

        public override string ToString()
        {
            return Kind + " - " + DisplayTitle + " - " +
                CreationTime.ToString("g", CultureInfo.CurrentCulture);
        }
    }

    internal enum SaveCompatibilitySeverity
    {
        Information,
        Warning,
        Blocking
    }

    internal sealed class SaveCompatibilityIssue
    {
        internal SaveCompatibilitySeverity Severity;
        internal string Message;
    }

    internal sealed class SaveCompatibilityResult
    {
        internal readonly List<SaveCompatibilityIssue> Issues =
            new List<SaveCompatibilityIssue>();

        internal bool CanLaunch
        {
            get
            {
                return !Issues.Any(delegate(SaveCompatibilityIssue issue) {
                    return issue.Severity == SaveCompatibilitySeverity.Blocking;
                });
            }
        }
    }

    internal static class SavegameService
    {
        private static readonly FileMemo<SavegameInfo> metadataCache = new FileMemo<SavegameInfo>(512);
        private static readonly FileMemo<byte[]> previewCache = new FileMemo<byte[]>(4);
        private const string BindingSuffix = ".boa-launcher.ini";
        private static readonly Guid SavedGamesFolderId =
            new Guid("4C5C32FF-BB9D-43B0-BF2D-AE1DDB0C7328");

        internal static List<SavegameInfo> Scan(string baseDirectory)
        {
            List<SavegameInfo> result = new List<SavegameInfo>();
            foreach (string path in EnumerateSaveFiles(baseDirectory)) {
                try {
                    SavegameInfo save = Read(path);
                    if (IsBladeOfAgonySave(save)) {
                        save.IsMultiplayer = CoopSaveService.IsCoop(save);
                        result.Add(save);
                    }
                } catch {
                    // A damaged save remains an engine concern and is omitted from Continue.
                }
            }
            result.Sort(delegate(SavegameInfo left, SavegameInfo right) {
                return right.LastWriteTime.CompareTo(left.LastWriteTime);
            });
            return result;
        }

        private static bool IsBladeOfAgonySave(SavegameInfo save)
        {
            return save != null &&
                !string.IsNullOrWhiteSpace(save.GameWad) &&
                string.Equals(
                    Path.GetFileName(save.GameWad.Trim()),
                    "boa.ipk3",
                    StringComparison.OrdinalIgnoreCase);
        }

        internal static SavegameInfo Read(string path)
        {
            return metadataCache.Get(path, string.Empty,
                delegate { return ReadMetadata(path); });
        }

        internal static byte[] ReadPreview(string path)
        {
            try {
                return previewCache.Get(path, string.Empty, delegate {
                    using (ZipArchive archive = ZipFile.OpenRead(path)) {
                        ZipArchiveEntry preview = FindEntry(archive, "savepic.png");
                        if (preview == null || preview.Length > 16 * 1024 * 1024) return null;
                        using (Stream source = preview.Open())
                        using (MemoryStream target = new MemoryStream()) {
                            source.CopyTo(target);
                            return target.ToArray();
                        }
                    }
                });
            } catch (IOException) { return null;
            } catch (InvalidDataException) { return null; }
        }

        private static SavegameInfo ReadMetadata(string path)
        {
            using (ZipArchive archive = ZipFile.OpenRead(path)) {
                ZipArchiveEntry infoEntry = FindEntry(archive, "info.json");
                if (infoEntry == null) {
                    throw new InvalidDataException("The save does not contain info.json.");
                }
                string json;
                using (StreamReader reader = new StreamReader(
                        infoEntry.Open(), Encoding.UTF8, true)) {
                    json = reader.ReadToEnd();
                }
                Dictionary<string, object> values =
                    new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(json);
                SavegameInfo result = new SavegameInfo();
                result.Path = System.IO.Path.GetFullPath(path);
                result.Title = ReadString(values, "Title");
                result.CurrentMap = ReadString(values, "Current Map").ToUpperInvariant();
                result.Comment = ReadString(values, "Comment");
                result.Software = ReadString(values, "Software");
                result.GameWad = ReadString(values, "Game WAD");
                result.LastWriteTime = File.GetLastWriteTime(path);
                DateTime created;
                result.CreationTime = DateTime.TryParse(
                    ReadString(values, "Creation Time"),
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.AssumeLocal,
                    out created) ? created : result.LastWriteTime;

                return result;
            }
        }

        internal static IDictionary<string, DateTime> CaptureSnapshot(string baseDirectory)
        {
            Dictionary<string, DateTime> result =
                new Dictionary<string, DateTime>(StringComparer.OrdinalIgnoreCase);
            foreach (string path in EnumerateSaveFiles(baseDirectory)) {
                result[path] = File.GetLastWriteTimeUtc(path);
            }
            return result;
        }

        internal static void BindChangedSaves(
            LauncherOptions options,
            IDictionary<string, DateTime> before)
        {
            foreach (string path in EnumerateSaveFiles(options.BaseDirectory)) {
                DateTime previous;
                DateTime current = File.GetLastWriteTimeUtc(path);
                if (before != null && before.TryGetValue(path, out previous) && current <= previous) {
                    continue;
                }
                WriteBinding(path, options);
            }
        }

        internal static List<string> GetSaveRoots(string baseDirectory)
        {
            List<string> result = new List<string>();
            AddSaveRoot(result, Path.Combine(baseDirectory, "save"));

            string configured = ReadConfiguredSaveDirectory(baseDirectory);
            if (!string.IsNullOrWhiteSpace(configured)) {
                AddSaveRoot(result, ResolveSaveDirectory(configured, baseDirectory));
                string networkRoot = GetSavedGamesDirectory();
                if (!string.IsNullOrEmpty(networkRoot)) AddSaveRoot(result, Path.Combine(networkRoot, "UZDoom", "NetGame"));
                return result;
            }

            string savedGames = GetSavedGamesDirectory();
            if (!string.IsNullOrWhiteSpace(savedGames)) {
                AddSaveRoot(result, Path.Combine(savedGames, "UZDoom"));
            }
            return result;
        }

        internal static SaveCompatibilityResult Check(
            SavegameInfo save,
            LauncherOptions options)
        {
            SaveCompatibilityResult result = new SaveCompatibilityResult();
            if (save.IsMultiplayer || CoopSaveService.IsCoop(save)) {
                Add(result, SaveCompatibilitySeverity.Blocking, "Use Multiplayer to resume this co-op save.");
                return result;
            }
            if (!string.IsNullOrEmpty(save.GameWad) &&
                    !string.Equals(
                        Path.GetFileName(save.GameWad), "boa.ipk3",
                        StringComparison.OrdinalIgnoreCase)) {
                Add(result, SaveCompatibilitySeverity.Blocking,
                    "This save was created for " + save.GameWad + ", not boa.ipk3.");
            }

            string bindingPath = save.Path + BindingSuffix;
            if (!File.Exists(bindingPath)) {
                Add(result, SaveCompatibilitySeverity.Warning,
                    "This legacy save has no v2.5 compatibility binding. Engine and add-on parity cannot be guaranteed.");
                return result;
            }

            IniFile binding = IniFile.Load(bindingPath);
            string expectedGame = binding.Get("Files", "MainGameSha256", string.Empty);
            string currentGame = FileFingerprint.CachedSha256(
                options.BaseDirectory, Path.Combine(options.BaseDirectory, "boa.ipk3"));
            if (expectedGame.Length > 0 && currentGame.Length > 0 &&
                    !string.Equals(expectedGame, currentGame, StringComparison.OrdinalIgnoreCase)) {
                Add(result, SaveCompatibilitySeverity.Blocking,
                    "boa.ipk3 differs from the version used by this save.");
            }

            string expectedAddons = binding.Get("Addons", "Selection", string.Empty);
            string currentAddons = BuildAddonBinding(options);
            if (!string.Equals(expectedAddons, currentAddons, StringComparison.OrdinalIgnoreCase)) {
                Add(result, SaveCompatibilitySeverity.Blocking,
                    "The selected add-ons or their load order differ from this save.");
            }

            string expectedEngine = binding.Get("Files", "EngineSha256", string.Empty);
            string currentEngine = FileFingerprint.CachedSha256(
                options.BaseDirectory, LauncherPaths.EngineExecutable(options.BaseDirectory));
            if (expectedEngine.Length > 0 && currentEngine.Length > 0 &&
                    !string.Equals(expectedEngine, currentEngine, StringComparison.OrdinalIgnoreCase)) {
                Add(result, SaveCompatibilitySeverity.Warning,
                    "The engine executable differs from the one used by this save.");
            }
            return result;
        }

        internal static string Backup(SavegameInfo save, string baseDirectory)
        {
            if (save == null || !File.Exists(save.Path)) {
                throw new FileNotFoundException("The selected savegame no longer exists.");
            }
            string directory = Path.Combine(
                LauncherPaths.DataDirectory(baseDirectory), "save-backups");
            Directory.CreateDirectory(directory);
            string name = Path.GetFileNameWithoutExtension(save.Path) + "-" +
                DateTime.Now.ToString("yyyyMMdd-HHmmss", CultureInfo.InvariantCulture) +
                Path.GetExtension(save.Path);
            string target = Path.Combine(directory, name);
            File.Copy(save.Path, target, false);
            string binding = save.Path + BindingSuffix;
            if (File.Exists(binding)) {
                File.Copy(binding, target + BindingSuffix, false);
            }
            return target;
        }

        internal static string BuildAddonBinding(LauncherOptions options)
        {
            if (!options.UseAddon || options.NetworkMode != MultiplayerMode.SinglePlayer) {
                return string.Empty;
            }
            List<AddonDescriptor> addons = new List<AddonDescriptor>();
            if (options.MultiAddons.Count > 0) {
                addons.AddRange(options.MultiAddons);
            } else if (options.SingleAddon != null) {
                addons.Add(options.SingleAddon);
            }
            List<string> values = new List<string>();
            foreach (AddonDescriptor addon in addons) {
                values.Add(
                    addon.Id + "@" + addon.Version + "@" +
                    FileFingerprint.Short(FileFingerprint.CachedSha256(
                        options.BaseDirectory, addon.DescriptorPath)));
            }
            return string.Join("|", values.ToArray());
        }

        private static void WriteBinding(string savePath, LauncherOptions options)
        {
            IniFile binding = new IniFile();
            binding.Set("Save", "BoundAt", DateTime.UtcNow.ToString("o", CultureInfo.InvariantCulture));
            binding.Set("Files", "EngineVersion",
                EngineVersionSupport.ReadProductVersion(options.BaseDirectory) ?? string.Empty);
            binding.Set("Files", "EngineSha256", FileFingerprint.CachedSha256(
                options.BaseDirectory, LauncherPaths.EngineExecutable(options.BaseDirectory)));
            binding.Set("Files", "MainGameSha256", FileFingerprint.CachedSha256(
                options.BaseDirectory, Path.Combine(options.BaseDirectory, "boa.ipk3")));
            binding.Set("Addons", "Selection", BuildAddonBinding(options));
            binding.Save(savePath + BindingSuffix);
        }

        private static IEnumerable<string> EnumerateSaveFiles(string baseDirectory)
        {
            HashSet<string> seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (string root in GetSaveRoots(baseDirectory)) {
                if (!Directory.Exists(root)) {
                    continue;
                }
                foreach (string path in EnumerateDirectory(root)) {
                    string fullPath;
                    try {
                        fullPath = Path.GetFullPath(path);
                    } catch {
                        continue;
                    }
                    if (seen.Add(fullPath)) {
                        yield return fullPath;
                    }
                }
            }
        }

        private static IEnumerable<string> EnumerateDirectory(string root)
        {
            Stack<string> pending = new Stack<string>();
            pending.Push(root);
            while (pending.Count > 0) {
                string directory = pending.Pop();
                string[] files;
                string[] children;
                try {
                    files = Directory.GetFiles(directory, "*.zds");
                    children = Directory.GetDirectories(directory);
                } catch (IOException) { continue;
                } catch (UnauthorizedAccessException) { continue; }
                foreach (string file in files) yield return file;
                foreach (string child in children) {
                    try {
                        if ((File.GetAttributes(child) & FileAttributes.ReparsePoint) == 0)
                            pending.Push(child);
                    } catch (IOException) {
                    } catch (UnauthorizedAccessException) { }
                }
            }
        }

        private static void AddSaveRoot(List<string> roots, string path)
        {
            if (string.IsNullOrWhiteSpace(path)) {
                return;
            }
            string fullPath;
            try {
                fullPath = Path.GetFullPath(path);
            } catch {
                return;
            }
            if (!roots.Any(delegate(string existing) {
                    return string.Equals(existing, fullPath, StringComparison.OrdinalIgnoreCase);
                })) {
                roots.Add(fullPath);
            }
        }

        private static string ReadConfiguredSaveDirectory(string baseDirectory)
        {
            return UZDoomConfiguration.ReadSaveDirectory(baseDirectory);
        }

        private static string ResolveSaveDirectory(string value, string baseDirectory)
        {
            string userProfile = Environment.GetFolderPath(
                Environment.SpecialFolder.UserProfile);
            string result = Environment.ExpandEnvironmentVariables(value);
            result = ReplaceOrdinalIgnoreCase(result, "$PROGDIR", baseDirectory);
            result = ReplaceOrdinalIgnoreCase(result, "$HOME", userProfile);
            if (!Path.IsPathRooted(result)) {
                result = Path.Combine(baseDirectory, result);
            }
            return Path.GetFullPath(result);
        }

        private static string ReplaceOrdinalIgnoreCase(
            string value, string search, string replacement)
        {
            int index = value.IndexOf(search, StringComparison.OrdinalIgnoreCase);
            while (index >= 0) {
                value = value.Substring(0, index) + replacement +
                    value.Substring(index + search.Length);
                index = value.IndexOf(
                    search, index + replacement.Length,
                    StringComparison.OrdinalIgnoreCase);
            }
            return value;
        }

        internal static string GetSavedGamesDirectory()
        {
            IntPtr path = IntPtr.Zero;
            try {
                Guid folderId = SavedGamesFolderId;
                if (SHGetKnownFolderPath(ref folderId, 0, IntPtr.Zero, out path) == 0 &&
                        path != IntPtr.Zero) {
                    return Marshal.PtrToStringUni(path);
                }
            } catch {
                // Fall back to the conventional location below.
            } finally {
                if (path != IntPtr.Zero) Marshal.FreeCoTaskMem(path);
            }
            string profile = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
            return string.IsNullOrWhiteSpace(profile)
                ? string.Empty
                : Path.Combine(profile, "Saved Games");
        }

        [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
        private static extern int SHGetKnownFolderPath(
            ref Guid folderId, uint flags, IntPtr token, out IntPtr path);

        private static ZipArchiveEntry FindEntry(ZipArchive archive, string name)
        {
            foreach (ZipArchiveEntry entry in archive.Entries) {
                if (string.Equals(entry.FullName.Replace('\\', '/'), name,
                        StringComparison.OrdinalIgnoreCase)) {
                    return entry;
                }
            }
            return null;
        }

        private static string ReadString(Dictionary<string, object> values, string key)
        {
            object value;
            return values.TryGetValue(key, out value) && value != null
                ? Convert.ToString(value, CultureInfo.InvariantCulture)
                : string.Empty;
        }

        private static void Add(
            SaveCompatibilityResult result,
            SaveCompatibilitySeverity severity,
            string message)
        {
            result.Issues.Add(new SaveCompatibilityIssue {
                Severity = severity,
                Message = message
            });
        }
    }
}
