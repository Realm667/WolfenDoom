using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace BladeOfAgonyLauncher
{
    internal enum MultiplayerMode
    {
        SinglePlayer,
        Host,
        Join
    }

    internal enum LauncherTheme
    {
        Dark,
        Light,
        BladeOfAgony,
        Wolfenstein3D
    }

    internal sealed class LauncherOptions
    {
        internal string BaseDirectory;
        internal int DetailPreset;
        internal bool DisplacementTextures;
        internal string Language;
        internal string InterfaceLanguage;
        internal LauncherTheme Theme;
        internal bool DeveloperCommentary;
        internal bool UseAddon;
        internal AddonDescriptor SingleAddon;
        internal List<AddonDescriptor> MultiAddons = new List<AddonDescriptor>();
        internal MultiplayerMode NetworkMode;
        internal int MultiplayerPlayers;
        internal string MultiplayerStartMap;
        internal string MultiplayerHost;
        internal int MultiplayerPort;
        internal int MultiplayerSkill;
        internal bool MultiplayerCheats;

        internal static LauncherOptions Load(string baseDirectory)
        {
            IniFile ini = IniFile.Load(Path.Combine(baseDirectory, "boa-launcher.ini"));
            LauncherOptions result = new LauncherOptions();
            result.BaseDirectory = baseDirectory;
            result.DetailPreset = 0;
            result.DisplacementTextures = ini.GetBoolean("Launcher", "DisplacementTextures", true);
            result.DeveloperCommentary = ini.GetBoolean("Launcher", "DevCommentary", false);
            result.UseAddon = ini.GetBoolean("Launcher", "LaunchWithAddon", false);
            result.Language = NormalizeLanguage(ini.Get("Launcher", "Language", "en"));
            result.InterfaceLanguage = NormalizeLanguage(
                ini.Get("Launcher", "InterfaceLanguage", "en"));
            result.Theme = ParseTheme(ini.Get("Launcher", "Theme", "BladeOfAgony"));
            bool legacyMultiplayerEnabled = ini.GetBoolean("Launcher co-op", "Enabled", false);
            result.NetworkMode = ParseMultiplayerMode(
                ini.Get("Launcher co-op", "Mode", legacyMultiplayerEnabled ? "Host" : "SinglePlayer"));
            result.MultiplayerPlayers = Clamp(
                ParseInteger(ini.Get("Launcher co-op", "Players", "2"), 2), 2, 8);
            result.MultiplayerStartMap = NormalizeMapName(
                ini.Get("Launcher co-op", "StartMap", "C1M1"));
            result.MultiplayerHost = NormalizeHost(
                ini.Get("Launcher co-op", "Hostname/IP", "localhost"));
            result.MultiplayerPort = Clamp(
                ParseInteger(ini.Get("Launcher co-op", "Port", "5029"), 5029), 1, 65535);
            result.MultiplayerSkill = Clamp(
                ParseInteger(ini.Get("Launcher co-op", "skill", "2"), 2), 1, 5);
            result.MultiplayerCheats = ini.GetBoolean("Launcher co-op", "sv_cheats", true);

            string addonFiles = ini.Get("Launcher", "addonFileName", string.Empty).Trim().Trim('"');
            if (addonFiles.Length > 0) {
                string[] storedPaths = addonFiles.IndexOf(';') >= 0
                    ? addonFiles.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries)
                    : addonFiles.Split(new[] { ':' }, StringSplitOptions.RemoveEmptyEntries);
                List<AddonDescriptor> selected = new List<AddonDescriptor>();
                foreach (string storedPath in storedPaths) {
                    string descriptorPath = ResolveDescriptorPath(baseDirectory, storedPath);
                    if (descriptorPath == null || !File.Exists(descriptorPath)) {
                        continue;
                    }
                    try {
                        selected.Add(AddonDescriptor.Load(
                            descriptorPath, result.InterfaceLanguage));
                    } catch {
                        // Ignore stale or malformed persisted descriptors.
                    }
                }
                if (selected.Count == 1) {
                    result.SingleAddon = selected[0];
                } else if (selected.Count > 1) {
                    result.MultiAddons.AddRange(selected);
                }
            }
            return result;
        }

        internal void Save()
        {
            string path = Path.Combine(BaseDirectory, "boa-launcher.ini");
            IniFile ini = IniFile.Load(path);
            ini.Set("Launcher", "DevCommentary", DeveloperCommentary ? "1" : "0");
            ini.Set("Launcher", "DisplacementTextures", DisplacementTextures ? "1" : "0");
            ini.Set("Launcher", "LaunchWithAddon", UseAddon ? "1" : "0");
            ini.Set("Launcher", "Language", NormalizeLanguage(Language));
            ini.Set("Launcher", "InterfaceLanguage", NormalizeLanguage(InterfaceLanguage));
            ini.Set("Launcher", "Theme", Theme.ToString());
            ini.Set("Launcher co-op", "Enabled",
                NetworkMode == MultiplayerMode.SinglePlayer ? "0" : "1");
            ini.Set("Launcher co-op", "Mode", NetworkMode.ToString());
            ini.Set("Launcher co-op", "Players",
                Clamp(MultiplayerPlayers, 2, 8).ToString(System.Globalization.CultureInfo.InvariantCulture));
            ini.Set("Launcher co-op", "StartMap", NormalizeMapName(MultiplayerStartMap));
            ini.Set("Launcher co-op", "Hostname/IP", NormalizeHost(MultiplayerHost));
            ini.Set("Launcher co-op", "Port",
                Clamp(MultiplayerPort, 1, 65535).ToString(System.Globalization.CultureInfo.InvariantCulture));
            ini.Set("Launcher co-op", "skill",
                Clamp(MultiplayerSkill, 1, 5).ToString(System.Globalization.CultureInfo.InvariantCulture));
            ini.Set("Launcher co-op", "sv_cheats", MultiplayerCheats ? "1" : "0");
            List<AddonDescriptor> selected = new List<AddonDescriptor>();
            if (UseAddon) {
                if (MultiAddons.Count > 0) {
                    selected.AddRange(MultiAddons);
                } else if (SingleAddon != null) {
                    selected.Add(SingleAddon);
                }
            }
            if (selected.Count > 0) {
                List<string> titles = new List<string>();
                List<string> paths = new List<string>();
                foreach (AddonDescriptor addon in selected) {
                    titles.Add(addon.Title);
                    paths.Add(addon.RelativePath);
                }
                ini.Set("Launcher", "addonTitle", string.Join(", ", titles.ToArray()));
                ini.Set("Launcher", "addonFileName", string.Join(";", paths.ToArray()));
            } else {
                ini.Set("Launcher", "addonTitle", string.Empty);
                ini.Set("Launcher", "addonFileName", string.Empty);
            }
            ini.Save(path);
        }

        private static string ResolveDescriptorPath(string baseDirectory, string storedPath)
        {
            string normalized = storedPath.Trim().Trim('"').Replace('\\', '/');
            if (normalized.Length == 0 || Path.IsPathRooted(normalized)) {
                return null;
            }
            if (normalized.IndexOf('/') < 0) {
                normalized = "addons/" + normalized;
            }
            string addonDirectory = Path.GetFullPath(Path.Combine(baseDirectory, "addons"));
            string fullPath = Path.GetFullPath(Path.Combine(baseDirectory, normalized.Replace('/', Path.DirectorySeparatorChar)));
            string prefix = addonDirectory.TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            return fullPath.StartsWith(prefix, StringComparison.OrdinalIgnoreCase) ? fullPath : null;
        }

        internal static int ParseDetail(string value)
        {
            string normalized = value == null ? string.Empty : value.Trim().ToLowerInvariant();
            string[] names = { "last", "default", "verylow", "low", "normal", "high", "veryhigh" };
            for (int index = 0; index < names.Length; index++) {
                if (normalized == names[index]) {
                    return index;
                }
            }
            throw new ArgumentException("Unknown detail preset: " + value);
        }

        internal static string NormalizeLanguage(string value)
        {
            string normalized = value == null ? string.Empty : value.Trim().ToLowerInvariant();
            if (normalized.Length == 0 || normalized == "default" || normalized == "enu" ||
                normalized == "eng" || normalized == "enc" || normalized == "ena" ||
                normalized == "enz" || normalized == "eni" || normalized == "ens" ||
                normalized == "enj" || normalized == "enb" || normalized == "enl" ||
                normalized == "ent" || normalized == "enw") {
                return "en";
            }
            if (normalized == "pt" || normalized == "br") {
                return "ptb";
            }
            if (normalized == "trk") {
                return "tr";
            }
            if (normalized == "plk") {
                return "pl";
            }

            string[] supported = { "en", "de", "es", "ru", "ptb", "it", "tr", "fr", "cs", "pl" };
            foreach (string language in supported) {
                if (normalized == language) {
                    return language;
                }
            }
            return "en";
        }

        internal static MultiplayerMode ParseMultiplayerMode(string value)
        {
            string normalized = value == null ? string.Empty : value.Trim().ToLowerInvariant();
            if (normalized == "host" || normalized == "hostcoop" || normalized == "host-coop") {
                return MultiplayerMode.Host;
            }
            if (normalized == "join" || normalized == "joincoop" || normalized == "join-coop") {
                return MultiplayerMode.Join;
            }
            return MultiplayerMode.SinglePlayer;
        }

        internal static LauncherTheme ParseTheme(string value)
        {
            string normalized = value == null ? string.Empty : value.Trim().ToLowerInvariant();
            if (normalized == "dark") {
                return LauncherTheme.Dark;
            }
            if (normalized == "light") {
                return LauncherTheme.Light;
            }
            if (normalized == "bladeofagony" || normalized == "blade-of-agony" ||
                normalized == "boa") {
                return LauncherTheme.BladeOfAgony;
            }
            if (normalized == "wolfenstein3d" || normalized == "wolfenstein-3d" ||
                normalized == "wolf3d") {
                return LauncherTheme.Wolfenstein3D;
            }
            return LauncherTheme.BladeOfAgony;
        }

        internal static string NormalizeMapName(string value)
        {
            string normalized = value == null ? string.Empty : value.Trim().ToUpperInvariant();
            if (!IsValidMapName(normalized)) {
                return "C1M1";
            }
            return normalized;
        }

        internal static bool IsValidMapName(string value)
        {
            string normalized = value == null ? string.Empty : value.Trim();
            return normalized.Length > 0 &&
                System.Text.RegularExpressions.Regex.IsMatch(normalized, "^[A-Za-z0-9_]+$");
        }

        internal static string NormalizeHost(string value)
        {
            string normalized = value == null ? string.Empty : value.Trim();
            if (!IsValidHost(normalized)) {
                return "localhost";
            }
            return normalized;
        }

        internal static bool IsValidHost(string value)
        {
            string normalized = value == null ? string.Empty : value.Trim();
            return normalized.Length > 0 &&
                System.Text.RegularExpressions.Regex.IsMatch(normalized, "^[A-Za-z0-9.-]+$");
        }

        private static int ParseInteger(string value, int fallback)
        {
            int parsed;
            return int.TryParse(value, out parsed) ? parsed : fallback;
        }

        private static int Clamp(int value, int minimum, int maximum)
        {
            return Math.Max(minimum, Math.Min(maximum, value));
        }
    }

    internal static class LauncherCommand
    {
        private static readonly string[] DetailConfigs = {
            null,
            "launcher-resource/detail-default.cfg",
            "launcher-resource/detail-verylow.cfg",
            "launcher-resource/detail-low.cfg",
            "launcher-resource/detail-normal.cfg",
            "launcher-resource/detail-high.cfg",
            "launcher-resource/detail-veryhigh.cfg"
        };

        internal static List<string> BuildArguments(LauncherOptions options)
        {
            List<string> arguments = new List<string>();
            string iwad = "boa.ipk3";
            if (options.SingleAddon != null && options.SingleAddon.Iwad.Length > 0) {
                iwad = options.SingleAddon.Iwad;
            } else if (options.MultiAddons.Count > 0 && options.MultiAddons[0].Iwad.Length > 0) {
                iwad = options.MultiAddons[0].Iwad;
            }

            arguments.Add("-iwad");
            arguments.Add(iwad);

            if (options.UseAddon) {
                if (options.MultiAddons.Count > 0) {
                    List<string> loadFiles = new List<string>();
                    foreach (AddonDescriptor addon in options.MultiAddons) {
                        loadFiles.AddRange(addon.LoadFiles);
                    }
                    if (loadFiles.Count > 0) {
                        arguments.Add("-file");
                        arguments.AddRange(loadFiles);
                    }
                } else if (options.SingleAddon != null) {
                    arguments.Add("-file");
                    arguments.Add(options.SingleAddon.RelativePath);
                }
            }

            if (options.DisplacementTextures) {
                arguments.Add("-file");
                arguments.Add("boa_dt.pk3");
            }

            if (options.DetailPreset > 0 && options.DetailPreset < DetailConfigs.Length) {
                arguments.Add("+exec");
                arguments.Add(DetailConfigs[options.DetailPreset]);
            }

            arguments.Add("+set");
            arguments.Add("boa_devcomswitch");
            arguments.Add(options.DeveloperCommentary ? "1" : "0");

            if (!string.IsNullOrEmpty(options.Language)) {
                arguments.Add("+set");
                arguments.Add("language");
                arguments.Add(options.Language);
            }

            if (options.NetworkMode == MultiplayerMode.Host) {
                arguments.Add("-host");
                arguments.Add(Math.Max(2, Math.Min(8, options.MultiplayerPlayers))
                    .ToString(System.Globalization.CultureInfo.InvariantCulture));
                arguments.Add("-port");
                arguments.Add(Math.Max(1, Math.Min(65535, options.MultiplayerPort))
                    .ToString(System.Globalization.CultureInfo.InvariantCulture));
                arguments.Add("-skill");
                arguments.Add(Math.Max(1, Math.Min(5, options.MultiplayerSkill))
                    .ToString(System.Globalization.CultureInfo.InvariantCulture));
                arguments.Add("+set");
                arguments.Add("sv_cheats");
                arguments.Add(options.MultiplayerCheats ? "1" : "0");
                arguments.Add("+map");
                arguments.Add(LauncherOptions.NormalizeMapName(options.MultiplayerStartMap));
            } else if (options.NetworkMode == MultiplayerMode.Join) {
                arguments.Add("-join");
                arguments.Add(
                    LauncherOptions.NormalizeHost(options.MultiplayerHost) + ":" +
                    Math.Max(1, Math.Min(65535, options.MultiplayerPort))
                        .ToString(System.Globalization.CultureInfo.InvariantCulture));
            }
            return arguments;
        }

        internal static string BuildArgumentString(LauncherOptions options)
        {
            List<string> values = BuildArguments(options);
            StringBuilder result = new StringBuilder();
            foreach (string value in values) {
                if (result.Length > 0) {
                    result.Append(' ');
                }
                result.Append(Quote(value));
            }
            return result.ToString();
        }

        internal static string BuildDisplayCommand(LauncherOptions options)
        {
            return "boa.exe " + BuildArgumentString(options);
        }

        internal static Process Start(LauncherOptions options)
        {
            string executable = Path.Combine(options.BaseDirectory, "boa.exe");
            if (!File.Exists(executable)) {
                throw new FileNotFoundException("boa.exe was not found next to the launcher.", executable);
            }
            if (!File.Exists(Path.Combine(options.BaseDirectory, "boa.ipk3"))) {
                throw new FileNotFoundException("boa.ipk3 was not found next to the launcher.");
            }

            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = executable;
            startInfo.Arguments = BuildArgumentString(options);
            startInfo.WorkingDirectory = options.BaseDirectory;
            startInfo.UseShellExecute = false;
            return Process.Start(startInfo);
        }

        private static string Quote(string value)
        {
            if (value.Length > 0 && value.IndexOfAny(new[] { ' ', '\t', '"' }) < 0) {
                return value;
            }
            StringBuilder result = new StringBuilder("\"");
            int slashCount = 0;
            foreach (char current in value) {
                if (current == '\\') {
                    slashCount++;
                } else if (current == '"') {
                    result.Append('\\', slashCount * 2 + 1);
                    result.Append('"');
                    slashCount = 0;
                } else {
                    result.Append('\\', slashCount);
                    result.Append(current);
                    slashCount = 0;
                }
            }
            result.Append('\\', slashCount * 2);
            result.Append('"');
            return result.ToString();
        }
    }
}
