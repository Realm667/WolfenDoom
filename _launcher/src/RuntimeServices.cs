using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Web.Script.Serialization;

namespace BladeOfAgonyLauncher
{
    internal enum EngineReleaseChannel
    {
        Missing,
        Stable,
        Preview,
        Unsupported
    }

    internal static class UZDoomConfiguration
    {
        internal static List<string> GetCandidates(string baseDirectory)
        {
            List<string> result = new List<string>();
            Add(result, Path.Combine(baseDirectory, "uzdoom_portable.ini"));
            Add(result, Path.Combine(baseDirectory, "uzdoom.ini"));

            string documents = Environment.GetFolderPath(
                Environment.SpecialFolder.MyDocuments);
            if (!string.IsNullOrWhiteSpace(documents)) {
                Add(result, Path.Combine(documents, "My Games", "UZDoom", "uzdoom.ini"));
                Add(result, Path.Combine(documents, "MyGames", "UZDoom", "uzdoom.ini"));
            }

            string appData = Environment.GetFolderPath(
                Environment.SpecialFolder.ApplicationData);
            if (!string.IsNullOrWhiteSpace(appData)) {
                Add(result, Path.Combine(appData, "UZDoom", "uzdoom.ini"));
            }
            return result;
        }

        internal static string FindExisting(string baseDirectory)
        {
            foreach (string path in GetCandidates(baseDirectory)) {
                if (File.Exists(path)) return path;
            }
            return string.Empty;
        }

        internal static string ReadSaveDirectory(string baseDirectory)
        {
            foreach (string path in GetCandidates(baseDirectory)) {
                if (!File.Exists(path)) continue;
                try {
                    string value = IniFile.Load(path).Get(
                        "GlobalSettings", "save_dir", string.Empty);
                    if (!string.IsNullOrWhiteSpace(value)) {
                        return value.Trim().Trim('"');
                    }
                } catch {
                    // Continue with the remaining supported UZDoom locations.
                }
            }
            return string.Empty;
        }

        private static void Add(List<string> values, string path)
        {
            string full;
            try {
                full = Path.GetFullPath(path);
            } catch {
                return;
            }
            if (!values.Any(delegate(string existing) {
                    return string.Equals(existing, full,
                        StringComparison.OrdinalIgnoreCase);
                })) {
                values.Add(full);
            }
        }
    }

    internal enum PreflightSeverity
    {
        Information,
        Warning,
        Blocking
    }

    internal sealed class PreflightFinding
    {
        internal PreflightSeverity Severity;
        internal string Area;
        internal string Message;
        internal string Resolution;
        internal string SummaryKey;
        internal string[] SummaryArguments;

        public override string ToString()
        {
            string result = "[" + Severity.ToString().ToUpperInvariant() + "] " +
                Area + ": " + Message;
            return string.IsNullOrWhiteSpace(Resolution)
                ? result
                : result + " " + Resolution;
        }
    }

    internal sealed class PreflightResult
    {
        internal readonly List<PreflightFinding> Findings =
            new List<PreflightFinding>();

        internal bool CanLaunch
        {
            get
            {
                return !Findings.Any(delegate(PreflightFinding finding) {
                    return finding.Severity == PreflightSeverity.Blocking;
                });
            }
        }

        internal int WarningCount
        {
            get
            {
                return Findings.Count(delegate(PreflightFinding finding) {
                    return finding.Severity == PreflightSeverity.Warning;
                });
            }
        }
    }

    internal static class LauncherPreflight
    {
        internal static PreflightResult Inspect(
            LauncherOptions options, IList<AddonDescriptor> selectedAddons,
            IList<CompatibilityIssue> compatibility = null)
        {
            PreflightResult result = new PreflightResult();
            string engine = LauncherPaths.EngineExecutable(options.BaseDirectory);
            string game = Path.Combine(options.BaseDirectory, "boa.ipk3");

            if (!File.Exists(engine)) {
                Add(result, PreflightSeverity.Blocking, "Engine",
                    "uzdoom.exe is missing.",
                    "Place the supported UZDoom executable next to the launcher.", "Missing file: {0}", "uzdoom.exe");
            } else if (!EngineVersionSupport.IsSupported(
                    EngineVersionSupport.ReadProductVersion(options.BaseDirectory))) {
                Add(result, PreflightSeverity.Blocking, "Engine",
                    "The detected UZDoom version is not supported.",
                    "Use UZDoom " + EngineVersionSupport.MinimumVersion + " or newer.", "Requires UZDoom {0}+", EngineVersionSupport.MinimumVersion);
            }

            if (!File.Exists(game)) {
                Add(result, PreflightSeverity.Blocking, "Main game",
                    "boa.ipk3 is missing.",
                    "Place the final Blade of Agony game file next to the launcher.", "Missing file: {0}", "boa.ipk3");
            } else {
                try {
                    using (FileStream stream = File.Open(
                            game, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)) {
                        if (stream.Length == 0) {
                            Add(result, PreflightSeverity.Blocking, "Main game",
                                "boa.ipk3 is empty.", "Restore the game package.", "Empty file: {0}", "boa.ipk3");
                        }
                    }
                } catch (Exception exception) {
                    Add(result, PreflightSeverity.Blocking, "Main game",
                        "boa.ipk3 cannot be read: " + exception.Message,
                        "Close tools that lock the file and check file permissions.", "Cannot read: {0}", "boa.ipk3");
                }
            }

            if (!LauncherPaths.CanWriteDirectory(
                    LauncherPaths.DataDirectory(options.BaseDirectory))) {
                Add(result, PreflightSeverity.Blocking, "Launcher data",
                    "The launcher data directory is not writable.",
                    "Choose a writable game location or correct its permissions.", "Cannot write: {0}", LauncherPaths.DataDirectory(options.BaseDirectory));
            }

            foreach (string root in SavegameService.GetSaveRoots(options.BaseDirectory)) {
                string existing = Directory.Exists(root)
                    ? root
                    : Path.GetDirectoryName(root);
                if (!string.IsNullOrEmpty(existing) && Directory.Exists(existing) &&
                        !LauncherPaths.CanWriteDirectory(existing)) {
                    Add(result, PreflightSeverity.Warning, "Savegames",
                        "A detected save location is not writable: " + root,
                        "UZDoom may use another configured save location.", "Cannot write: {0}", root);
                }
            }

            if (options.NetworkMode == MultiplayerMode.SinglePlayer &&
                    !options.SafeMode && options.UseAddon) {
                foreach (CompatibilityIssue issue in compatibility ?? AddonCompatibility.Analyze(
                        options.BaseDirectory, selectedAddons ??
                            new List<AddonDescriptor>())) {
                    if (issue.Severity == CompatibilitySeverity.Error) {
                        Add(result, PreflightSeverity.Blocking, "Add-ons",
                            issue.Message, "Correct the selection or load order.", issue.SummaryKey, issue.SummaryArguments);
                    }
                }
            }

            if (options.NetworkMode != MultiplayerMode.SinglePlayer) {
                try { MultiplayerSettings.Validate(options, EngineCapabilities.Detect(options.BaseDirectory)); }
                catch (Exception exception) {
                    Add(result, PreflightSeverity.Blocking, "Multiplayer", exception.Message,
                        "Review the Multiplayer settings before starting.");
                }
            }

            if (result.Findings.Count == 0) {
                Add(result, PreflightSeverity.Information, "Ready",
                    "Engine, main game, paths, and selected content passed preflight.",
                    string.Empty);
            }
            return result;
        }

        private static void Add(
            PreflightResult result, PreflightSeverity severity,
            string area, string message, string resolution, string key = null, params string[] args)
        {
            result.Findings.Add(new PreflightFinding {
                Severity = severity,
                Area = area,
                Message = message,
                SummaryKey = key ?? message, SummaryArguments = args,
                Resolution = resolution
            });
        }
    }

    internal sealed class BoaLauncherManifest
    {
        internal int FormatVersion = 1;
        internal string BoaVersion = string.Empty;
        internal string MinimumEngineVersion = EngineVersionSupport.MinimumVersion;
        internal readonly List<string> SupportedLanguages = new List<string>();
        internal readonly List<string> Episodes = new List<string>();
        internal readonly List<string> Missions = new List<string>();
        internal readonly Dictionary<string, List<string>> AddonConflicts =
            new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);
        internal string Source = "MAPINFO fallback";
        private static readonly FileMemo<string> manifestTextCache = new FileMemo<string>(16);

        internal static BoaLauncherManifest Load(
            string baseDirectory, BoaContentCatalog catalog)
        {
            BoaLauncherManifest result = null;
            string unpacked = Path.Combine(baseDirectory, "boa-launcher.json");
            if (File.Exists(unpacked)) {
                try {
                    result = Parse(manifestTextCache.Get(unpacked, string.Empty,
                        delegate { return File.ReadAllText(unpacked, Encoding.UTF8); }));
                    result.Source = "boa-launcher.json";
                } catch {
                    result = null;
                }
            }
            string archivePath = Path.Combine(baseDirectory, "boa.ipk3");
            if (result == null && File.Exists(archivePath)) {
                try {
                    string json = manifestTextCache.Get(archivePath, "manifest", delegate {
                    using (ZipArchive archive = ZipFile.OpenRead(archivePath)) {
                        ZipArchiveEntry entry = GameArchive.FindEntry(archive, "boa-launcher.json");
                        if (entry != null) {
                            using (StreamReader reader = new StreamReader(
                                    entry.Open(), Encoding.UTF8, true)) {
                                return reader.ReadToEnd();
                            }
                        }
                    }
                    return null;
                    });
                    if (json != null) {
                        result = Parse(json);
                        result.Source = "boa.ipk3/boa-launcher.json";
                    }
                } catch {
                    result = null;
                }
            }
            if (result == null) result = FromCatalog(catalog);
            EnsureDefaults(result, catalog);
            return result;
        }

        internal static string CreateJson(
            string boaVersion, BoaContentCatalog catalog)
        {
            Dictionary<string, object> value = new Dictionary<string, object>();
            value["formatVersion"] = 1;
            value["boaVersion"] = boaVersion ?? string.Empty;
            value["minimumEngineVersion"] = EngineVersionSupport.MinimumVersion;
            value["supportedLanguages"] = new[] {
                "en-US", "en-GB", "de", "es", "ru", "pt-PT",
                "it", "tr", "fr", "cs", "pl"
            };
            Dictionary<string, object> addonConflicts =
                new Dictionary<string, object>();
            addonConflicts["confiscated_weapons"] =
                new[] { "more_weapons" };
            value["addonConflicts"] = addonConflicts;
            value["episodes"] = catalog == null
                ? new string[0]
                : catalog.Episodes.Select(delegate(BoaEpisode episode) {
                    return episode.StartMap;
                }).ToArray();
            value["missions"] = catalog == null
                ? new string[0]
                : EnumerateMaps(catalog).Select(delegate(BoaMap map) {
                    return map.Id;
                }).ToArray();
            return new JavaScriptSerializer().Serialize(value);
        }

        private static BoaLauncherManifest Parse(string json)
        {
            Dictionary<string, object> value =
                new JavaScriptSerializer().Deserialize<Dictionary<string, object>>(json);
            BoaLauncherManifest result = new BoaLauncherManifest();
            object item;
            if (value.TryGetValue("formatVersion", out item)) {
                int.TryParse(Convert.ToString(item, CultureInfo.InvariantCulture),
                    out result.FormatVersion);
            }
            result.BoaVersion = Read(value, "boaVersion");
            result.MinimumEngineVersion = Read(value, "minimumEngineVersion");
            AddStrings(result.SupportedLanguages, value, "supportedLanguages");
            AddStrings(result.Episodes, value, "episodes");
            AddStrings(result.Missions, value, "missions");
            AddStringMap(result.AddonConflicts, value, "addonConflicts");
            if (result.FormatVersion != 1) {
                throw new InvalidDataException("Unsupported launcher manifest format.");
            }
            return result;
        }

        private static BoaLauncherManifest FromCatalog(BoaContentCatalog catalog)
        {
            BoaLauncherManifest result = new BoaLauncherManifest();
            if (catalog != null) {
                foreach (BoaEpisode episode in catalog.Episodes) {
                    result.Episodes.Add(episode.StartMap);
                }
                foreach (BoaMap map in EnumerateMaps(catalog)) {
                    result.Missions.Add(map.Id);
                }
            }
            return result;
        }

        private static void EnsureDefaults(
            BoaLauncherManifest result, BoaContentCatalog catalog)
        {
            // Older game manifests cannot lower the launcher's support floor.
            if (!EngineVersionSupport.IsSupported(result.MinimumEngineVersion)) {
                result.MinimumEngineVersion = EngineVersionSupport.MinimumVersion;
            }
            if (result.SupportedLanguages.Count == 0) {
                result.SupportedLanguages.AddRange(new[] {
                    "en-US", "en-GB", "de", "es", "ru", "pt-PT",
                    "it", "tr", "fr", "cs", "pl"
                });
            }
            if (result.Missions.Count == 0 && catalog != null) {
                foreach (BoaMap map in EnumerateMaps(catalog)) {
                    result.Missions.Add(map.Id);
                }
            }
            EnsureConflict(result, "confiscated_weapons", "more_weapons");
        }

        private static void EnsureConflict(
            BoaLauncherManifest manifest, string left, string right)
        {
            List<string> conflicts;
            if (!manifest.AddonConflicts.TryGetValue(left, out conflicts)) {
                conflicts = new List<string>();
                manifest.AddonConflicts[left] = conflicts;
            }
            if (!conflicts.Any(delegate(string value) {
                    return string.Equals(value, right,
                        StringComparison.OrdinalIgnoreCase);
                })) {
                conflicts.Add(right);
            }
        }

        private static IEnumerable<BoaMap> EnumerateMaps(BoaContentCatalog catalog)
        {
            HashSet<string> seen = new HashSet<string>(
                StringComparer.OrdinalIgnoreCase);
            foreach (BoaEpisode episode in catalog.Episodes) {
                foreach (BoaMap map in episode.Maps) {
                    if (seen.Add(map.Id)) yield return map;
                }
            }
        }

        private static string Read(Dictionary<string, object> value, string key)
        {
            object item;
            return value.TryGetValue(key, out item) && item != null
                ? Convert.ToString(item, CultureInfo.InvariantCulture)
                : string.Empty;
        }

        private static void AddStrings(
            List<string> target, Dictionary<string, object> value, string key)
        {
            object item;
            object[] items;
            if (!value.TryGetValue(key, out item) ||
                    (items = item as object[]) == null) return;
            foreach (object entry in items) {
                string text = Convert.ToString(entry, CultureInfo.InvariantCulture);
                if (!string.IsNullOrWhiteSpace(text)) target.Add(text.Trim());
            }
        }

        private static void AddStringMap(
            Dictionary<string, List<string>> target,
            Dictionary<string, object> value, string key)
        {
            object item;
            Dictionary<string, object> mapping;
            if (!value.TryGetValue(key, out item) ||
                    (mapping = item as Dictionary<string, object>) == null) return;
            foreach (KeyValuePair<string, object> pair in mapping) {
                object[] entries = pair.Value as object[];
                if (entries == null || string.IsNullOrWhiteSpace(pair.Key)) continue;
                List<string> conflicts = new List<string>();
                foreach (object entry in entries) {
                    string text = Convert.ToString(
                        entry, CultureInfo.InvariantCulture);
                    if (!string.IsNullOrWhiteSpace(text)) conflicts.Add(text.Trim());
                }
                if (conflicts.Count > 0) target[pair.Key.Trim()] = conflicts;
            }
        }
    }

    internal sealed class CrashDiagnosis
    {
        internal string Category;
        internal string Summary;
        internal string Recommendation;
        internal string LogPath;
    }

    internal static class CrashLogAnalyzer
    {
        internal static CrashDiagnosis AnalyzeLatest(string baseDirectory)
        {
            string log = FindLatestLog(baseDirectory);
            if (string.IsNullOrEmpty(log)) return null;
            string text;
            try {
                text = File.ReadAllText(log);
            } catch {
                return null;
            }
            string lower = text.ToLowerInvariant();
            CrashDiagnosis result = new CrashDiagnosis { LogPath = log };
            if (lower.Contains("script error") || lower.Contains("zscript") &&
                    lower.Contains("error")) {
                result.Category = "Add-on / ZScript";
                result.Summary = "The latest log contains a script compilation error.";
                result.Recommendation = "Review the selected add-ons and retry without the conflicting content.";
            } else if (lower.Contains("vulkan") &&
                    (lower.Contains("fatal") || lower.Contains("failed"))) {
                result.Category = "Renderer";
                result.Summary = "The latest log indicates a Vulkan or graphics initialization failure.";
                result.Recommendation = "Use Safe Mode, update the graphics driver, or select a conservative renderer in UZDoom.";
            } else if (lower.Contains("cannot find savegame") ||
                    lower.Contains("savegame is from a different")) {
                result.Category = "Savegame";
                result.Summary = "The latest log indicates a missing or incompatible savegame.";
                result.Recommendation = "Choose another compatible Blade of Agony save from the launcher.";
            } else if (lower.Contains("cannot find") || lower.Contains("not found")) {
                result.Category = "Missing file";
                result.Summary = "The latest log reports a missing game resource.";
                result.Recommendation = "Run Verify installation and restore the reported file.";
            } else if (lower.Contains("execution could not continue") ||
                    lower.Contains("fatal error")) {
                result.Category = "Engine";
                result.Summary = "The latest UZDoom run ended with a fatal engine error.";
                result.Recommendation = "Create a support package and retry in Safe Mode.";
            } else {
                return null;
            }
            return result;
        }

        private static string FindLatestLog(string baseDirectory)
        {
            List<string> roots = new List<string> {
                baseDirectory,
                LauncherPaths.DataDirectory(baseDirectory)
            };
            foreach (string config in UZDoomConfiguration.GetCandidates(baseDirectory)) {
                string directory = Path.GetDirectoryName(config);
                if (!string.IsNullOrEmpty(directory)) roots.Add(directory);
            }
            FileInfo latest = null;
            foreach (string root in roots.Distinct(StringComparer.OrdinalIgnoreCase)) {
                if (!Directory.Exists(root)) continue;
                string[] files;
                try {
                    files = Directory.GetFiles(root, "*.log", SearchOption.TopDirectoryOnly);
                } catch {
                    continue;
                }
                foreach (string path in files) {
                    FileInfo file = new FileInfo(path);
                    if (latest == null || file.LastWriteTimeUtc > latest.LastWriteTimeUtc) {
                        latest = file;
                    }
                }
            }
            return latest == null ? string.Empty : latest.FullName;
        }
    }
}
