using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Security.Cryptography;
using System.Text;
using System.Threading;

namespace BladeOfAgonyLauncher
{
    // Cached values are read-only after publication. Failed or changing reads are not retained.
    internal sealed class FileMemo<T>
    {
        private sealed class Entry
        {
            internal string Stamp;
            internal T Value;
            internal long Used;
        }
        private readonly Dictionary<string, Entry> entries =
            new Dictionary<string, Entry>(StringComparer.OrdinalIgnoreCase);
        private readonly int capacity;
        private long clock;

        internal FileMemo(int limit) { capacity = limit; }

        internal T Get(string path, string variant, Func<T> read)
        {
            string key = Path.GetFullPath(path) + "|" + variant;
            lock (entries) {
                string stamp = Stamp(path);
                Entry entry;
                if (entries.TryGetValue(key, out entry) && entry.Stamp == stamp) {
                    entry.Used = ++clock;
                    return entry.Value;
                }
                entries.Remove(key);
                T value = read();
                if (stamp != Stamp(path)) return value;
                if (entries.Count >= capacity) {
                    string oldest = null;
                    long used = long.MaxValue;
                    foreach (KeyValuePair<string, Entry> pair in entries) {
                        if (pair.Value.Used < used) { oldest = pair.Key; used = pair.Value.Used; }
                    }
                    if (oldest != null) entries.Remove(oldest);
                }
                entries[key] = new Entry { Stamp = stamp, Value = value, Used = ++clock };
                return value;
            }
        }

        internal static string Stamp(string path)
        {
            FileInfo file = new FileInfo(path);
            return file.Exists
                ? file.Length.ToString(CultureInfo.InvariantCulture) + ":" +
                    file.LastWriteTimeUtc.Ticks.ToString(CultureInfo.InvariantCulture)
                : "missing";
        }
    }

    internal static class LauncherPaths
    {
        internal const string EngineExecutableName = "uzdoom.exe";
        private static readonly Dictionary<string, string> dataDirectories =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        internal static string EngineExecutable(string baseDirectory)
        {
            return Path.Combine(baseDirectory, EngineExecutableName);
        }

        internal static string DataDirectory(string baseDirectory)
        {
            string key = Path.GetFullPath(baseDirectory);
            lock (dataDirectories) {
                string path;
                if (dataDirectories.TryGetValue(key, out path) && Directory.Exists(path)) return path;
                path = ResolveDataDirectory(baseDirectory);
                dataDirectories[key] = path;
                return path;
            }
        }

        private static string ResolveDataDirectory(string baseDirectory)
        {
            string path = Path.Combine(baseDirectory, "launcher-data");
            try {
                Directory.CreateDirectory(path);
                if (CanWriteDirectory(path)) return path;
            } catch {
                // Fall back to per-user storage for read-only installations.
            }
            string local = Environment.GetFolderPath(
                Environment.SpecialFolder.LocalApplicationData);
            if (string.IsNullOrWhiteSpace(local)) {
                local = Path.GetTempPath();
            }
            path = Path.Combine(local, "Realm667", "Blade of Agony Launcher",
                "launcher-data");
            try {
                Directory.CreateDirectory(path);
                if (CanWriteDirectory(path)) return path;
            } catch {
                // Restricted environments can also block the normal user profile.
            }
            path = Path.Combine(Path.GetTempPath(), "Realm667",
                "Blade of Agony Launcher", "launcher-data");
            Directory.CreateDirectory(path);
            return path;
        }

        internal static string SettingsFile(string baseDirectory)
        {
            string portable = Path.Combine(baseDirectory, "boa-launcher.ini");
            if (File.Exists(portable) || CanWriteDirectory(baseDirectory)) {
                return portable;
            }
            return Path.Combine(DataDirectory(baseDirectory), "boa-launcher.ini");
        }

        internal static string ProfileDirectory(string baseDirectory)
        {
            string portable = Path.Combine(baseDirectory, "launcher-profiles");
            try {
                Directory.CreateDirectory(portable);
                if (CanWriteDirectory(portable)) return portable;
            } catch {
                // Use the per-user launcher data fallback below.
            }
            string path = Path.Combine(DataDirectory(baseDirectory), "profiles");
            Directory.CreateDirectory(path);
            return path;
        }

        internal static bool CanWriteDirectory(string path)
        {
            if (string.IsNullOrWhiteSpace(path)) return false;
            string probe = null;
            try {
                Directory.CreateDirectory(path);
                probe = Path.Combine(path, ".boa-write-" +
                    Guid.NewGuid().ToString("N") + ".tmp");
                using (FileStream stream = new FileStream(
                        probe, FileMode.CreateNew, FileAccess.Write,
                        FileShare.None, 1, FileOptions.DeleteOnClose)) {
                    stream.WriteByte(0);
                }
                return true;
            } catch {
                return false;
            } finally {
                try {
                    if (!string.IsNullOrEmpty(probe) && File.Exists(probe)) {
                        File.Delete(probe);
                    }
                } catch {
                    // The write result is already known.
                }
            }
        }

        internal static string RelativeToBase(string baseDirectory, string path)
        {
            string root = Path.GetFullPath(baseDirectory).TrimEnd(Path.DirectorySeparatorChar) +
                Path.DirectorySeparatorChar;
            string full = Path.GetFullPath(path);
            if (full.StartsWith(root, StringComparison.OrdinalIgnoreCase)) {
                return full.Substring(root.Length).Replace('\\', '/');
            }
            return full;
        }
    }

    internal static class FileFingerprint
    {
        private sealed class Store
        {
            internal IniFile Values;
            internal readonly Dictionary<string, string[]> Pending = new Dictionary<string, string[]>();
        }
        private static readonly Dictionary<string, Store> stores =
            new Dictionary<string, Store>(StringComparer.OrdinalIgnoreCase);

        static FileFingerprint()
        {
            AppDomain.CurrentDomain.ProcessExit += delegate { Flush(); };
        }

        internal static void Flush()
        {
            lock (stores) {
                foreach (KeyValuePair<string, Store> pair in stores) {
                    if (pair.Value.Pending.Count == 0) continue;
                    try {
                        IniFile merged = IniFile.Load(pair.Key);
                        foreach (KeyValuePair<string, string[]> entry in pair.Value.Pending) {
                            merged.Set(entry.Key, "Stamp", entry.Value[0]);
                            merged.Set(entry.Key, "Sha256", entry.Value[1]);
                        }
                        merged.Save(pair.Key);
                        pair.Value.Values = merged;
                        pair.Value.Pending.Clear();
                    } catch (IOException) {
                        // Fingerprints are an optional optimization; keep pending data for retry.
                    } catch (UnauthorizedAccessException) { }
                }
            }
        }
        internal static string Sha256(string path)
        {
            if (!File.Exists(path)) {
                return string.Empty;
            }
            using (FileStream stream = File.OpenRead(path))
            using (SHA256 hash = SHA256.Create()) {
                byte[] bytes = hash.ComputeHash(stream);
                StringBuilder result = new StringBuilder(bytes.Length * 2);
                foreach (byte value in bytes) {
                    result.Append(value.ToString("x2", CultureInfo.InvariantCulture));
                }
                return result.ToString();
            }
        }

        internal static string Short(string value)
        {
            return string.IsNullOrEmpty(value)
                ? "missing"
                : value.Substring(0, Math.Min(12, value.Length));
        }

        internal static string CachedSha256(string baseDirectory, string path)
        {
            if (!File.Exists(path)) {
                return string.Empty;
            }
            FileInfo file = new FileInfo(path);
            string cachePath = Path.Combine(
                LauncherPaths.DataDirectory(baseDirectory), "file-fingerprints.ini");
            string key = Path.GetFileName(path).Replace(' ', '_').Replace('.', '_') + "_" + PathKey(path);
            string stamp = file.Length.ToString(CultureInfo.InvariantCulture) + ":" +
                file.LastWriteTimeUtc.Ticks.ToString(CultureInfo.InvariantCulture);
            Store store;
            lock (stores) {
            if (!stores.TryGetValue(cachePath, out store)) {
                store = new Store { Values = IniFile.Load(cachePath) };
                stores.Add(cachePath, store);
            }
            IniFile cache = store.Values;
            if (cache.Get(key, "Stamp", string.Empty) == stamp) {
                string cached = cache.Get(key, "Sha256", string.Empty);
                if (cached.Length == 64) {
                    return cached;
                }
            }
            }
            string result = Sha256(path);
            if (stamp != FileMemo<string>.Stamp(path))
                throw new IOException("File changed during fingerprinting: " + path);
            lock (stores) {
                store.Values.Set(key, "Stamp", stamp);
                store.Values.Set(key, "Sha256", result);
                store.Pending[key] = new[] { stamp, result };
            }
            return result;
        }

        private static string PathKey(string path)
        {
            using (SHA256 hash = SHA256.Create()) {
                byte[] bytes = hash.ComputeHash(Encoding.UTF8.GetBytes(
                    Path.GetFullPath(path).ToLowerInvariant()));
                StringBuilder result = new StringBuilder(16);
                for (int index = 0; index < 8; index++) {
                    result.Append(bytes[index].ToString("x2", CultureInfo.InvariantCulture));
                }
                return result.ToString();
            }
        }
    }

    internal sealed class RecoveryStatus
    {
        internal bool PreviousRunInterrupted;
        internal string Command;
        internal DateTime Started;
    }

    internal static class LaunchRecovery
    {
        private const string StateFile = "active-run.ini";

        internal static RecoveryStatus Inspect(string baseDirectory)
        {
            RecoveryStatus result = new RecoveryStatus();
            string path = Path.Combine(LauncherPaths.DataDirectory(baseDirectory), StateFile);
            if (!File.Exists(path)) {
                return result;
            }
            IniFile ini = IniFile.Load(path);
            int processId;
            int.TryParse(ini.Get("Run", "ProcessId", "0"), out processId);
            bool stillRunning = false;
            if (processId > 0) {
                try {
                    stillRunning = !Process.GetProcessById(processId).HasExited;
                } catch {
                    stillRunning = false;
                }
            }
            if (!stillRunning) {
                result.PreviousRunInterrupted = true;
                result.Command = ini.Get("Run", "Command", string.Empty);
                DateTime started;
                if (DateTime.TryParse(
                        ini.Get("Run", "Started", string.Empty),
                        CultureInfo.InvariantCulture,
                        DateTimeStyles.RoundtripKind,
                        out started)) {
                    result.Started = started;
                }
            }
            return result;
        }

        internal static void Track(
            Process process,
            LauncherOptions options,
            IDictionary<string, DateTime> saveSnapshot)
        {
            string path = Path.Combine(LauncherPaths.DataDirectory(options.BaseDirectory), StateFile);
            IniFile ini = new IniFile();
            ini.Set("Run", "ProcessId", process.Id.ToString(CultureInfo.InvariantCulture));
            ini.Set("Run", "Started", DateTime.UtcNow.ToString("o", CultureInfo.InvariantCulture));
            ini.Set("Run", "Command", LauncherCommand.BuildPrivacySafeDisplayCommand(options));
            ini.Save(path);

            ThreadPool.QueueUserWorkItem(delegate {
                try {
                    process.WaitForExit();
                    SavegameService.BindChangedSaves(options, saveSnapshot);
                    string historyPath = Path.Combine(
                        LauncherPaths.DataDirectory(options.BaseDirectory), "last-run.ini");
                    IniFile history = new IniFile();
                    history.Set("Run", "ExitCode", process.ExitCode.ToString(CultureInfo.InvariantCulture));
                    history.Set("Run", "Finished", DateTime.UtcNow.ToString("o", CultureInfo.InvariantCulture));
                    history.Set("Run", "Command", LauncherCommand.BuildPrivacySafeDisplayCommand(options));
                    history.Save(historyPath);
                    if (File.Exists(path)) {
                        File.Delete(path);
                    }
                } catch {
                    // Keep the active marker so the next launcher run can offer recovery.
                } finally {
                    process.Dispose();
                }
            });
        }

        internal static void Dismiss(string baseDirectory)
        {
            string path = Path.Combine(LauncherPaths.DataDirectory(baseDirectory), StateFile);
            if (File.Exists(path)) {
                File.Delete(path);
            }
        }
    }
}
