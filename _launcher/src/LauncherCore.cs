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

    internal enum CampaignStartMode { MainMenu, NewCampaign, MissionSelect, ContinueCampaign }

    internal sealed class LauncherOptions
    {
        private CampaignStartMode startMode;
        internal CampaignStartMode StartMode
        {
            get { return startMode; }
            set {
                startMode = value;
                if (value != CampaignStartMode.ContinueCampaign) ContinueSavePath = null;
            }
        }
        private void SelectMode(CampaignStartMode mode, bool selected)
        {
            if (selected) StartMode = mode;
            else if (StartMode == mode) StartMode = CampaignStartMode.MainMenu;
        }
        internal string BaseDirectory;
        internal int DetailPreset;
        internal bool DisplacementTextures;
        internal string Language;
        internal string InterfaceLanguage;
        internal LauncherTheme Theme;
        internal bool DeveloperCommentary;
        internal bool DirectStart
        {
            get { return StartMode == CampaignStartMode.MissionSelect; }
            set { SelectMode(CampaignStartMode.MissionSelect, value); }
        }
        internal bool NewCampaign
        {
            get { return StartMode == CampaignStartMode.NewCampaign; }
            set { SelectMode(CampaignStartMode.NewCampaign, value); }
        }
        internal string SinglePlayerStartMap;
        internal bool DebugKeenMissions;
        internal bool SinglePlayerCheckpoints;
        internal bool RestartLevelOnDeath;
        internal int SinglePlayerSkill;
        internal bool UseAddon;
        internal AddonDescriptor SingleAddon;
        internal List<AddonDescriptor> MultiAddons = new List<AddonDescriptor>();
        internal MultiplayerMode NetworkMode;
        internal MultiplayerMode LastMultiplayerRole = MultiplayerMode.Host;
        internal int MultiplayerPlayers;
        internal string MultiplayerStartMap;
        internal string MultiplayerHost;
        internal int MultiplayerPort;
        internal int MultiplayerSkill;
        internal bool MultiplayerCheats;
        internal string MultiplayerPassword;
        internal Dictionary<string, int> MultiplayerRules = new Dictionary<string, int>();
        internal string MultiplayerSavePath;
        internal string ImportedSaveSha256;
        internal bool ImportedSessionRules;
        internal bool ImportedSessionRequiresPassword;
        internal bool ContinueCampaign
        {
            get { return StartMode == CampaignStartMode.ContinueCampaign; }
            set { SelectMode(CampaignStartMode.ContinueCampaign, value); }
        }
        internal string ContinueSavePath;
        internal bool SafeMode;
        internal double WindowWidth;
        internal double WindowHeight;

        internal static LauncherOptions Load(string baseDirectory)
        {
            IniFile ini = IniFile.Load(LauncherPaths.SettingsFile(baseDirectory));
            LauncherOptions result = new LauncherOptions();
            result.BaseDirectory = baseDirectory;
            result.DetailPreset = 0;
            result.DisplacementTextures = ini.GetBoolean("Launcher", "DisplacementTextures", true);
            result.DeveloperCommentary = ini.GetBoolean("Launcher", "DevCommentary", false);
            result.DirectStart = ini.GetBoolean("Launcher", "DirectStart", false);
            result.NewCampaign = ini.GetBoolean("Launcher", "NewCampaign", false);
            result.SinglePlayerStartMap = NormalizeMapName(
                ini.Get("Launcher", "StartMap", "INTROMAP"));
            result.DebugKeenMissions = ini.GetBoolean("Launcher", "DebugMode",
                ini.GetBoolean("Launcher", "DebugKeenMissions", false));
            result.SinglePlayerCheckpoints = ini.GetBoolean("Launcher", "SinglePlayerCheckpoints", false);
            result.RestartLevelOnDeath = ini.GetBoolean("Launcher", "RestartLevelOnDeath", false);
            if (!result.DebugKeenMissions && BoaContentCatalog.IsKeenMap(result.SinglePlayerStartMap)) {
                result.SinglePlayerStartMap = "INTROMAP";
                result.DirectStart = result.NewCampaign = false;
            }
            result.SinglePlayerSkill = Clamp(
                ParseInteger(ini.Get("Launcher", "Skill", "3"), 3), 1, 5);
            result.UseAddon = ini.GetBoolean("Launcher", "LaunchWithAddon", false);
            result.Language = NormalizeGameLanguage(
                ini.Get("Launcher", "Language", "en-US"));
            result.InterfaceLanguage = NormalizeInterfaceLanguage(
                ini.Get("Launcher", "InterfaceLanguage", "en"));
            result.Theme = ParseTheme(ini.Get("Launcher", "Theme", "BladeOfAgony"));
            bool legacyMultiplayerEnabled = ini.GetBoolean("Launcher co-op", "Enabled", false);
            result.NetworkMode = ParseMultiplayerMode(
                ini.Get("Launcher co-op", "Mode", legacyMultiplayerEnabled ? "Host" : "SinglePlayer"));
            result.LastMultiplayerRole = ParseMultiplayerMode(ini.Get("Launcher co-op", "LastRole",
                result.NetworkMode == MultiplayerMode.SinglePlayer ? "Host" : result.NetworkMode.ToString()));
            if (result.LastMultiplayerRole == MultiplayerMode.SinglePlayer)
                result.LastMultiplayerRole = MultiplayerMode.Host;
            result.MultiplayerPlayers = Clamp(
                ParseInteger(ini.Get("Launcher co-op", "Players", "2"), 2), 2, 4);
            result.MultiplayerStartMap = NormalizeMapName(
                ini.Get("Launcher co-op", "StartMap", "C1M1"));
            result.MultiplayerHost = NormalizeHost(
                ini.Get("Launcher co-op", "Hostname/IP", "localhost"));
            result.MultiplayerPort = Clamp(
                ParseInteger(ini.Get("Launcher co-op", "Port", "5029"), 5029), 1, 65535);
            result.MultiplayerSkill = Clamp(
                ParseInteger(ini.Get("Launcher co-op", "skill", "2"), 2), 1, 5);
            result.MultiplayerCheats = ini.GetBoolean("Launcher co-op", "sv_cheats", true);
            result.MultiplayerPassword = string.Empty;
            foreach (NetworkRule rule in NetworkRule.All) {
                int value;
                if (int.TryParse(ini.Get("Network rules", rule.Key, string.Empty), out value) &&
                        value >= (rule.Key == "ticdup" ? 1 : 0) && value <= rule.Maximum)
                    result.MultiplayerRules[rule.Key] = value;
            }
            result.WindowWidth = Clamp(
                ParseDouble(ini.Get("Window", "Width", "1180"), 1180), 760, 7680);
            result.WindowHeight = Clamp(
                ParseDouble(ini.Get("Window", "Height", "760"), 760), 600, 4320);

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
            string path = LauncherPaths.SettingsFile(BaseDirectory);
            IniFile ini = IniFile.Load(path);
            ini.Set("Launcher", "DevCommentary", DeveloperCommentary ? "1" : "0");
            ini.Set("Launcher", "DirectStart", DirectStart ? "1" : "0");
            ini.Set("Launcher", "NewCampaign", NewCampaign ? "1" : "0");
            ini.Set("Launcher", "StartMap", NormalizeMapName(SinglePlayerStartMap));
            ini.Set("Launcher", "SinglePlayerCheckpoints", SinglePlayerCheckpoints ? "1" : "0");
            ini.Set("Launcher", "RestartLevelOnDeath", RestartLevelOnDeath ? "1" : "0");
            ini.Set("Launcher", "DebugMode", DebugKeenMissions ? "1" : "0");
            ini.Set("Launcher", "Skill",
                Clamp(SinglePlayerSkill, 1, 5)
                    .ToString(System.Globalization.CultureInfo.InvariantCulture));
            ini.Set("Launcher", "DisplacementTextures", DisplacementTextures ? "1" : "0");
            ini.Set("Launcher", "LaunchWithAddon", UseAddon ? "1" : "0");
            ini.Set("Launcher", "Language", NormalizeGameLanguage(Language));
            ini.Set("Launcher", "InterfaceLanguage",
                NormalizeInterfaceLanguage(InterfaceLanguage));
            ini.Set("Launcher", "Theme", Theme.ToString());
            ini.Set("Launcher co-op", "Enabled",
                NetworkMode == MultiplayerMode.SinglePlayer ? "0" : "1");
            ini.Set("Launcher co-op", "Mode", NetworkMode.ToString());
            ini.Set("Launcher co-op", "LastRole", LastMultiplayerRole == MultiplayerMode.Join ? "Join" : "Host");
            ini.Set("Launcher co-op", "Players",
                Clamp(MultiplayerPlayers, 2, 4).ToString(
                    System.Globalization.CultureInfo.InvariantCulture));
            ini.Set("Launcher co-op", "StartMap", NormalizeMapName(MultiplayerStartMap));
            ini.Set("Launcher co-op", "Hostname/IP", NormalizeHost(MultiplayerHost));
            ini.Set("Launcher co-op", "Port",
                Clamp(MultiplayerPort, 1, 65535).ToString(System.Globalization.CultureInfo.InvariantCulture));
            ini.Set("Launcher co-op", "skill",
                Clamp(MultiplayerSkill, 1, 5).ToString(System.Globalization.CultureInfo.InvariantCulture));
            ini.Set("Launcher co-op", "sv_cheats", MultiplayerCheats ? "1" : "0");
            foreach (NetworkRule rule in NetworkRule.All) {
                int value;
                ini.Set("Network rules", rule.Key, MultiplayerRules.TryGetValue(rule.Key, out value)
                    ? value.ToString(System.Globalization.CultureInfo.InvariantCulture) : string.Empty);
            }
            ini.Set("Window", "Width", Clamp(WindowWidth, 760, 7680).ToString(
                "0.##", System.Globalization.CultureInfo.InvariantCulture));
            ini.Set("Window", "Height", Clamp(WindowHeight, 600, 4320).ToString(
                "0.##", System.Globalization.CultureInfo.InvariantCulture));
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

        internal LauncherOptions Snapshot()
        {
            LauncherOptions result = (LauncherOptions)MemberwiseClone();
            result.MultiAddons = new List<AddonDescriptor>(MultiAddons);
            result.MultiplayerRules = new Dictionary<string, int>(MultiplayerRules);
            return result;
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

        internal static string NormalizeGameLanguage(string value)
        {
            string normalized = value == null ? string.Empty : value.Trim().ToLowerInvariant();
            if (normalized == "auto" || normalized == "last") {
                return normalized;
            }
            if (normalized.Length == 0 || normalized == "default" || normalized == "en" ||
                normalized == "enu" || normalized == "en-us" || normalized == "enc" || normalized == "ena" ||
                normalized == "enz" || normalized == "eni" || normalized == "ens" ||
                normalized == "enj" || normalized == "enb" || normalized == "enl" ||
                normalized == "ent" || normalized == "enw") {
                return "en-US";
            }
            if (normalized == "eng" || normalized == "en-gb") {
                return "en-GB";
            }
            if (normalized == "pt" || normalized == "ptg" || normalized == "ptb" || normalized == "br" ||
                    normalized == "pt-br" || normalized == "pt-pt") {
                return "pt-PT";
            }
            if (normalized == "trk") {
                return "tr";
            }
            if (normalized == "plk") {
                return "pl";
            }

            string[] supported = { "de", "es", "ru", "it", "tr", "fr", "cs", "pl" };
            foreach (string language in supported) {
                if (normalized == language) {
                    return language;
                }
            }
            return "en-US";
        }

        internal static string NormalizeInterfaceLanguage(string value)
        {
            string gameLanguage = NormalizeGameLanguage(value);
            if (gameLanguage == "en-US" || gameLanguage == "en-GB" ||
                    gameLanguage == "auto" || gameLanguage == "last") {
                return "en";
            }
            if (gameLanguage == "pt-PT") {
                return "ptb";
            }
            return gameLanguage;
        }

        internal static string NormalizeLanguage(string value)
        {
            return NormalizeInterfaceLanguage(value);
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

        private static double ParseDouble(string value, double fallback)
        {
            double parsed;
            return double.TryParse(
                value, System.Globalization.NumberStyles.Float,
                System.Globalization.CultureInfo.InvariantCulture, out parsed)
                ? parsed
                : fallback;
        }

        private static int Clamp(int value, int minimum, int maximum)
        {
            return Math.Max(minimum, Math.Min(maximum, value));
        }

        private static double Clamp(double value, double minimum, double maximum)
        {
            return Math.Max(minimum, Math.Min(maximum, value));
        }
    }

    internal static class EngineVersionSupport
    {
        internal const string MinimumVersion = "5.0.3";
        private static readonly Version minimumVersion = new Version(5, 0, 3, 0);

        internal static string ReadProductVersion(string baseDirectory)
        {
            string executable = LauncherPaths.EngineExecutable(baseDirectory);
            return File.Exists(executable)
                ? FileVersionInfo.GetVersionInfo(executable).ProductVersion
                : null;
        }

        internal static bool IsSupported(string value)
        {
            Version version;
            if (!TryParse(value, out version)) {
                return false;
            }
            Version normalized = new Version(version.Major, version.Minor,
                Math.Max(0, version.Build), Math.Max(0, version.Revision));
            int comparison = normalized.CompareTo(minimumVersion);
            return comparison > 0 || (comparison == 0 && !IsPreview(value));
        }

        private static bool IsPreview(string value)
        {
            return System.Text.RegularExpressions.Regex.IsMatch(value,
                @"(?:^|[^a-z])(pre|preview|rc|dev|alpha|beta)(?:[^a-z]|$)",
                System.Text.RegularExpressions.RegexOptions.IgnoreCase);
        }

        internal static void RequireSupported(string baseDirectory)
        {
            string detected = ReadProductVersion(baseDirectory);
            if (!IsSupported(detected)) {
                throw new InvalidDataException("UZDoom " + MinimumVersion +
                    " or newer is required. Detected: " +
                    (string.IsNullOrWhiteSpace(detected) ? "unknown version" : detected) + ".");
            }
        }

        internal static int MajorVersion(string baseDirectory)
        {
            Version version;
            return TryParse(ReadProductVersion(baseDirectory), out version)
                ? version.Major
                : 4;
        }

        internal static EngineReleaseChannel ReleaseChannel(string baseDirectory)
        {
            string value = ReadProductVersion(baseDirectory);
            if (string.IsNullOrWhiteSpace(value)) {
                return EngineReleaseChannel.Missing;
            }
            if (!IsSupported(value)) {
                return EngineReleaseChannel.Unsupported;
            }
            return IsPreview(value)
                    ? EngineReleaseChannel.Preview
                    : EngineReleaseChannel.Stable;
        }

        internal static string GameLanguageCode(
            string baseDirectory, string language)
        {
            return LauncherOptions.NormalizeGameLanguage(language);
        }

        private static bool TryParse(string value, out Version version)
        {
            version = null;
            if (string.IsNullOrWhiteSpace(value)) {
                return false;
            }
            System.Text.RegularExpressions.Match match =
                System.Text.RegularExpressions.Regex.Match(
                    value, "[0-9]+(?:\\.[0-9]+){1,3}");
            return match.Success && Version.TryParse(match.Value, out version);
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
            EngineCapabilitySet capabilities = EngineCapabilities.Detect(options.BaseDirectory);
            MultiplayerSettings.Validate(options, capabilities);
            string iwad = "boa.ipk3";
            bool singlePlayer = options.NetworkMode == MultiplayerMode.SinglePlayer;
            if (!options.SafeMode && singlePlayer && options.SingleAddon != null && options.SingleAddon.Iwad.Length > 0) {
                iwad = options.SingleAddon.Iwad;
            } else if (!options.SafeMode && singlePlayer && options.MultiAddons.Count > 0 &&
                    options.MultiAddons[0].Iwad.Length > 0) {
                iwad = options.MultiAddons[0].Iwad;
            }

            arguments.Add("-iwad");
            arguments.Add(iwad);
            if (singlePlayer && !options.SafeMode && options.DebugKeenMissions) {
                arguments.Add("+set");
                arguments.Add("boa_hqdebug");
                arguments.Add("1");
            }
            if (!singlePlayer || options.SafeMode) {
                arguments.Add("-noautoexec");
                arguments.Add("-noautoload");
            }

            if (options.SafeMode) {
                if (!capabilities.Config) throw new InvalidOperationException("Safe Mode requires UZDoom -config support.");
                arguments.Add("-config");
                arguments.Add(EnsureSafeModeConfiguration(options.BaseDirectory));
                arguments.Add("+set");
                arguments.Add("vid_fullscreen");
                arguments.Add("0");
            }

            if (!options.SafeMode && singlePlayer && options.UseAddon) {
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

            if (!options.SafeMode && singlePlayer && options.DisplacementTextures) {
                arguments.Add("-file");
                arguments.Add("boa_dt.pk3");
            }

            if (!options.SafeMode && options.DetailPreset > 0 && options.DetailPreset < DetailConfigs.Length) {
                arguments.Add("+exec");
                arguments.Add(DetailConfigs[options.DetailPreset]);
            }

            // BoA explicitly requires this to remain enabled for Zyklon steam spawners.
            // Keep it after the profile so older low/normal configs cannot disable it.
            arguments.Add("+set");
            arguments.Add("boa_steamswitch");
            arguments.Add("1");

            arguments.Add("+set");
            arguments.Add("boa_devcomswitch");
            arguments.Add(options.DeveloperCommentary ? "1" : "0");

            if (!string.IsNullOrEmpty(options.Language) &&
                    LauncherOptions.NormalizeGameLanguage(options.Language) != "last") {
                arguments.Add("+set");
                arguments.Add("language");
                arguments.Add(EngineVersionSupport.GameLanguageCode(
                    options.BaseDirectory, options.Language));
            }

            if (options.NetworkMode == MultiplayerMode.SinglePlayer &&
                    !options.SafeMode && options.ContinueCampaign &&
                    capabilities.LoadGame &&
                    !string.IsNullOrEmpty(options.ContinueSavePath)) {
                string savePath = Path.IsPathRooted(options.ContinueSavePath)
                    ? options.ContinueSavePath
                    : Path.Combine(options.BaseDirectory, options.ContinueSavePath);
                savePath = Path.GetFullPath(savePath);
                string saveDirectory = Path.GetDirectoryName(savePath);
                string saveFileName = Path.GetFileName(savePath);
                if (string.IsNullOrEmpty(saveDirectory) ||
                        string.IsNullOrEmpty(saveFileName)) {
                    throw new InvalidOperationException(
                        "The selected savegame path is invalid.");
                }
                arguments.Add("-savedir");
                arguments.Add(saveDirectory);
                arguments.Add("-loadgame");
                arguments.Add(saveFileName);
            } else if (!options.SafeMode && options.NetworkMode == MultiplayerMode.SinglePlayer &&
                    (options.NewCampaign || options.DirectStart)) {
                int skillNumber = Math.Max(1, Math.Min(5, options.SinglePlayerSkill));
                if (options.RestartLevelOnDeath && iwad.Equals("boa.ipk3", StringComparison.OrdinalIgnoreCase)
                        && BoaContentCatalog.SupportsLevelRestart(options.BaseDirectory)) skillNumber += 10;
                else if (options.SinglePlayerCheckpoints && iwad.Equals("boa.ipk3", StringComparison.OrdinalIgnoreCase)
                        && BoaContentCatalog.SupportsCheckpoints(options.BaseDirectory)) skillNumber += 5;
                // UZDoom 5.0.3 reads only the first character of -skill.
                // For two-digit BoA skills use the zero-based, non-archived skill cvar.
                if (skillNumber >= 10) {
                    arguments.Add("+set");
                    arguments.Add("skill");
                    skillNumber--;
                } else arguments.Add("-skill");
                arguments.Add(skillNumber
                    .ToString(System.Globalization.CultureInfo.InvariantCulture));
                arguments.Add("+map");
                arguments.Add(LauncherOptions.NormalizeMapName(options.SinglePlayerStartMap));
            } else if (options.NetworkMode == MultiplayerMode.Host) {
                if (capabilities.Coop) {
                    arguments.Add("-coop");
                }
                AddPassword(arguments, capabilities, options.MultiplayerPassword);
                arguments.Add("-host");
                arguments.Add(Math.Max(2, Math.Min(4, options.MultiplayerPlayers))
                    .ToString(System.Globalization.CultureInfo.InvariantCulture));
                arguments.Add("-port");
                arguments.Add(Math.Max(1, Math.Min(65535, options.MultiplayerPort))
                    .ToString(System.Globalization.CultureInfo.InvariantCulture));
                MultiplayerSettings.AppendRules(arguments, options);
                arguments.Add("-skill");
                arguments.Add(Math.Max(1, Math.Min(5, options.MultiplayerSkill))
                    .ToString(System.Globalization.CultureInfo.InvariantCulture));
                arguments.Add("+set");
                arguments.Add("sv_cheats");
                arguments.Add(options.MultiplayerCheats ? "1" : "0");
                if (string.IsNullOrEmpty(options.MultiplayerSavePath)) {
                    arguments.Add("+map");
                    arguments.Add(LauncherOptions.NormalizeMapName(options.MultiplayerStartMap));
                }
            } else if (options.NetworkMode == MultiplayerMode.Join) {
                AddPassword(arguments, capabilities, options.MultiplayerPassword);
                arguments.Add("-join");
                arguments.Add(
                    LauncherOptions.NormalizeHost(options.MultiplayerHost) + ":" +
                    Math.Max(1, Math.Min(65535, options.MultiplayerPort))
                        .ToString(System.Globalization.CultureInfo.InvariantCulture));
            }
            if (!singlePlayer && !string.IsNullOrEmpty(options.MultiplayerSavePath)) {
                arguments.Add("-loadgame");
                arguments.Add(CoopSaveService.LoadName(options));
            }
            return arguments;
        }

        private static void AddPassword(
            List<string> arguments,
            EngineCapabilitySet capabilities,
            string password)
        {
            if (capabilities.Password && !string.IsNullOrEmpty(password)) {
                arguments.Add("-password");
                arguments.Add(password);
            }
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
            return LauncherPaths.EngineExecutableName + " " + BuildArgumentString(options);
        }

        internal static string BuildPrivacySafeDisplayCommand(LauncherOptions options)
        {
            List<string> values;
            try { values = BuildArguments(options); }
            catch (InvalidDataException exception) { return "Launch blocked: " + exception.Message; }
            catch (IOException exception) { return "Launch blocked: " + exception.Message; }
            StringBuilder result = new StringBuilder(LauncherPaths.EngineExecutableName);
            bool redactNext = false;
            foreach (string value in values) {
                result.Append(' ');
                result.Append(Quote(redactNext ? "[REDACTED]" : value));
                redactNext = string.Equals(
                    value, "-password", StringComparison.OrdinalIgnoreCase);
            }
            return result.ToString();
        }

        internal static Process Start(LauncherOptions options)
        {
            string executable = LauncherPaths.EngineExecutable(options.BaseDirectory);
            if (!File.Exists(executable)) {
                throw new FileNotFoundException(
                    LauncherPaths.EngineExecutableName + " was not found next to the launcher.",
                    executable);
            }
            EngineVersionSupport.RequireSupported(options.BaseDirectory);
            if (!File.Exists(Path.Combine(options.BaseDirectory, "boa.ipk3"))) {
                throw new FileNotFoundException("boa.ipk3 was not found next to the launcher.");
            }

            LauncherOptions launchSnapshot = options.Snapshot();
            string arguments = BuildArgumentString(launchSnapshot);
            if (options.NetworkMode != MultiplayerMode.SinglePlayer && !string.IsNullOrEmpty(options.MultiplayerSavePath))
                CoopSaveService.Prepare(launchSnapshot);
            IDictionary<string, DateTime> saveSnapshot =
                SavegameService.CaptureSnapshot(options.BaseDirectory);
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = executable;
            startInfo.Arguments = arguments;
            startInfo.WorkingDirectory = options.BaseDirectory;
            startInfo.UseShellExecute = false;
            Process process = Process.Start(startInfo);
            LaunchRecovery.Track(process, launchSnapshot, saveSnapshot);
            return process;
        }

        private static string EnsureSafeModeConfiguration(string baseDirectory)
        {
            string path = Path.Combine(
                LauncherPaths.DataDirectory(baseDirectory), "safe-mode.ini");
            if (!File.Exists(path)) {
                File.WriteAllText(path,
                    "# Blade of Agony Launcher temporary safe-mode configuration\r\n" +
                    "vid_fullscreen=0\r\n",
                    new UTF8Encoding(false));
            }
            return Path.GetFullPath(path);
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
