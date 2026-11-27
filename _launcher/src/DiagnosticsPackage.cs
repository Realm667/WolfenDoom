using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace BladeOfAgonyLauncher
{
    internal static class DiagnosticsPackage
    {
        internal static void Create(string outputPath, LauncherOptions options)
        {
            string report = BuildReport(options);
            using (FileStream stream = new FileStream(
                    outputPath, FileMode.Create, FileAccess.ReadWrite, FileShare.None))
            using (ZipArchive archive = new ZipArchive(stream, ZipArchiveMode.Create)) {
                WriteText(archive, "diagnostics.txt", report);
                WriteText(archive, "command-line.txt", SanitizeCommand(
                    LauncherCommand.BuildPrivacySafeDisplayCommand(options), options));
                string log = FindLatestLog(options.BaseDirectory);
                if (log != null) {
                    string contents = ReadTail(log, 256 * 1024);
                    WriteText(archive, "last-engine-log.txt", Redact(contents, options));
                }
                string lastRun = Path.Combine(
                    LauncherPaths.DataDirectory(options.BaseDirectory), "last-run.ini");
                if (File.Exists(lastRun)) {
                    WriteText(archive, "last-run.txt", Redact(
                        File.ReadAllText(lastRun, Encoding.UTF8), options));
                }
            }
        }

        internal static string BuildReport(LauncherOptions options)
        {
            StringBuilder result = new StringBuilder();
            EngineCapabilitySet capabilities = EngineCapabilities.Detect(options.BaseDirectory);
            MultiplayerCompatibilityStatus status =
                MultiplayerCompatibilityStatus.Inspect(options.BaseDirectory);
            result.AppendLine("Blade of Agony Launcher support report");
            result.AppendLine("GeneratedUtc=" + DateTime.UtcNow.ToString("o", CultureInfo.InvariantCulture));
            result.AppendLine("LauncherVersion=" + LauncherVersion.Number);
            result.AppendLine("EngineChannel=" +
                EngineVersionSupport.ReleaseChannel(options.BaseDirectory));
            result.AppendLine("UZDoomConfig=" + Redact(
                UZDoomConfiguration.FindExisting(options.BaseDirectory), options));
            result.AppendLine("OperatingSystem=" + Environment.OSVersion.VersionString);
            result.AppendLine("Runtime=" + Environment.Version);
            result.AppendLine("EngineVersion=" + (status.EngineVersion ?? "missing"));
            result.AppendLine("EngineCompatible=" + status.CorrectEngineVersion);
            result.AppendLine("EngineSha256=" + FileFingerprint.CachedSha256(
                options.BaseDirectory, LauncherPaths.EngineExecutable(options.BaseDirectory)));
            result.AppendLine("MainGamePresent=" + status.MainGamePresent);
            result.AppendLine("MainGameSha256=" + FileFingerprint.CachedSha256(
                options.BaseDirectory, Path.Combine(options.BaseDirectory, "boa.ipk3")));
            result.AppendLine("EngineCapabilities=" + capabilities.Summary);
            result.AppendLine("InterfaceLanguage=" + options.InterfaceLanguage);
            result.AppendLine("GameLanguage=" + options.Language);
            result.AppendLine("Theme=" + options.Theme);
            result.AppendLine("NetworkMode=" + options.NetworkMode);
            result.AppendLine("Map=" + (options.NetworkMode == MultiplayerMode.SinglePlayer
                ? options.SinglePlayerStartMap
                : options.MultiplayerStartMap));
            result.AppendLine("Skill=" + (options.NetworkMode == MultiplayerMode.SinglePlayer
                ? options.SinglePlayerSkill
                : options.MultiplayerSkill));
            result.AppendLine("SafeMode=" + options.SafeMode);
            result.AppendLine("ContinueSave=" + (options.ContinueCampaign &&
                !string.IsNullOrEmpty(options.ContinueSavePath)
                    ? Path.GetFileName(options.ContinueSavePath)
                    : "none"));
            foreach (string saveRoot in SavegameService.GetSaveRoots(options.BaseDirectory)) {
                result.AppendLine("SaveRoot=" + saveRoot);
            }
            result.AppendLine("AddonBinding=" + SavegameService.BuildAddonBinding(options));

            List<AddonDescriptor> addons = new List<AddonDescriptor>();
            if (options.UseAddon) {
                if (options.MultiAddons.Count > 0) addons.AddRange(options.MultiAddons);
                else if (options.SingleAddon != null) addons.Add(options.SingleAddon);
            }
            result.AppendLine("SelectedAddons=" + addons.Count.ToString(CultureInfo.InvariantCulture));
            foreach (AddonDescriptor addon in addons) {
                result.AppendLine("Addon=" + addon.Id + " " + addon.Version + " " +
                    FileFingerprint.Short(FileFingerprint.CachedSha256(
                        options.BaseDirectory, addon.DescriptorPath)));
            }
            foreach (CompatibilityIssue issue in AddonCompatibility.Analyze(
                    options.BaseDirectory, addons)) {
                result.AppendLine("AddonIssue=" + issue.Severity + ": " + issue.Message);
            }
            return Redact(result.ToString(), options);
        }

        private static string SanitizeCommand(string value, LauncherOptions options)
        {
            string result = Regex.Replace(
                value, "(?i)(-password\\s+)(?:\"[^\"]*\"|\\S+)", "$1[REDACTED]");
            return Redact(result, options);
        }

        private static string Redact(string value, LauncherOptions options)
        {
            string result = value ?? string.Empty;
            string profile = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
            if (!string.IsNullOrEmpty(profile)) {
                result = result.Replace(profile, "[USERPROFILE]");
            }
            if (!string.IsNullOrEmpty(options.BaseDirectory)) {
                result = result.Replace(options.BaseDirectory.TrimEnd('\\'), "[GAME]");
            }
            string engineVersion = EngineVersionSupport.ReadProductVersion(
                options.BaseDirectory) ?? string.Empty;
            result = Regex.Replace(result,
                "(?<![0-9])(?:[0-9]{1,3}\\.){3}[0-9]{1,3}(?![0-9])",
                delegate(Match match) {
                    return string.Equals(match.Value, engineVersion,
                        StringComparison.OrdinalIgnoreCase)
                        ? match.Value
                        : "[IP]";
                });
            if (!string.IsNullOrEmpty(options.MultiplayerHost) &&
                    options.MultiplayerHost != "localhost") {
                result = result.Replace(options.MultiplayerHost, "[HOST]");
            }
            return result;
        }

        private static string FindLatestLog(string baseDirectory)
        {
            List<string> candidates = new List<string>();
            foreach (string name in new[] { "uzdoom.log", "gzdoom.log", "boa.log" }) {
                string path = Path.Combine(baseDirectory, name);
                if (File.Exists(path)) candidates.Add(path);
            }
            string logs = Path.Combine(baseDirectory, "logs");
            if (Directory.Exists(logs)) {
                candidates.AddRange(Directory.GetFiles(logs, "*.log"));
            }
            return candidates.OrderByDescending(File.GetLastWriteTimeUtc).FirstOrDefault();
        }

        private static string ReadTail(string path, int maximumBytes)
        {
            byte[] bytes = File.ReadAllBytes(path);
            int offset = Math.Max(0, bytes.Length - maximumBytes);
            return Encoding.UTF8.GetString(bytes, offset, bytes.Length - offset);
        }

        private static void WriteText(ZipArchive archive, string name, string value)
        {
            ZipArchiveEntry entry = archive.CreateEntry(name, CompressionLevel.Optimal);
            using (StreamWriter writer = new StreamWriter(
                    entry.Open(), new UTF8Encoding(false))) {
                writer.Write(value);
            }
        }
    }
}
