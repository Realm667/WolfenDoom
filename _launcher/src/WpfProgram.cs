using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Windows;

namespace BladeOfAgonyLauncher
{
    internal static class WpfProgram
    {
        [STAThread]
        private static int Main(string[] args)
        {
            string baseDirectory = ReadBaseDirectory(args);
            try {
                if (HasArgument(args, "--help")) {
                    PrintHelp();
                    return 0;
                }
                if (HasArgument(args, "--scan-addons")) {
                    LauncherOptions scanOptions = LauncherOptions.Load(baseDirectory);
                    ApplyDiagnosticArguments(scanOptions, args, baseDirectory);
                    foreach (AddonDescriptor addon in AddonDescriptor.Scan(
                            baseDirectory, scanOptions.InterfaceLanguage)) {
                        Console.WriteLine(addon.RelativePath + "\t" + addon.Id + "\t" +
                            addon.Title + "\t" + string.Join(
                                ";", addon.LoadFiles.ToArray()) +
                            "\tPreviews=" + addon.PreviewImageCount);
                    }
                    return 0;
                }
                if (HasArgument(args, "--print-content")) {
                    LauncherOptions contentOptions = LauncherOptions.Load(baseDirectory);
                    ApplyDiagnosticArguments(contentOptions, args, baseDirectory);
                    BoaContentCatalog content = BoaContentCatalog.Load(
                        baseDirectory, contentOptions.Language);
                    Console.WriteLine("Source=" + content.SourceDescription);
                    foreach (BoaEpisode episode in content.Episodes) {
                        Console.WriteLine("Chapter=" + episode.StartMap + "\t" +
                            episode.DisplayName + "\tMaps=" + episode.Maps.Count);
                        foreach (BoaMap map in episode.Maps) {
                            Console.WriteLine("Map=" + episode.StartMap + "\t" +
                                map.Id + "\t" + map.DisplayName);
                        }
                    }
                    foreach (BoaSkill skill in content.Skills) {
                        Console.WriteLine("Skill=" + skill.Number + "\t" +
                            skill.Id + "\t" + skill.DisplayName);
                    }
                    return 0;
                }
                if (HasArgument(args, "--check-multiplayer")) {
                    MultiplayerCompatibilityStatus status =
                        MultiplayerCompatibilityStatus.Inspect(baseDirectory);
                    Console.WriteLine("EnginePresent=" + status.EnginePresent);
                    Console.WriteLine("EngineVersion=" + status.EngineVersion);
                    Console.WriteLine("MinimumEngineVersion=" + EngineVersionSupport.MinimumVersion);
                    Console.WriteLine("EngineCompatible=" + status.CorrectEngineVersion);
                    Console.WriteLine("MainGamePresent=" + status.MainGamePresent);
                    Console.WriteLine("MainGame=" + status.MainGameDescription);
                    return status.IsReady ? 0 : 2;
                }
                if (HasArgument(args, "--check-addons")) {
                    LauncherOptions addonOptions = LauncherOptions.Load(baseDirectory);
                    ApplyDiagnosticArguments(
                        addonOptions, args, baseDirectory);
                    List<AddonDescriptor> selected =
                        new List<AddonDescriptor>();
                    if (addonOptions.UseAddon) {
                        if (addonOptions.MultiAddons.Count > 0) {
                            selected.AddRange(addonOptions.MultiAddons);
                        } else if (addonOptions.SingleAddon != null) {
                            selected.Add(addonOptions.SingleAddon);
                        }
                    }
                    List<CompatibilityIssue> issues =
                        AddonCompatibility.Analyze(baseDirectory, selected);
                    bool hasErrors = false;
                    foreach (CompatibilityIssue issue in issues) {
                        if (issue.Severity == CompatibilitySeverity.Error) {
                            hasErrors = true;
                        }
                        Console.WriteLine(
                            issue.Severity.ToString().ToUpperInvariant() +
                            "\t" + issue.Message);
                    }
                    Console.WriteLine("Selected=" + selected.Count);
                    Console.WriteLine("Issues=" + issues.Count);
                    return hasErrors ? 2 : 0;
                }
                if (HasArgument(args, "--print-capabilities")) {
                    EngineCapabilitySet capabilities = EngineCapabilities.Detect(baseDirectory);
                    Console.WriteLine("Version=" + capabilities.Version);
                    Console.WriteLine("Probed=" + capabilities.Probed);
                    Console.WriteLine("LoadGame=" + capabilities.LoadGame);
                    Console.WriteLine("Episode=" + capabilities.Episode);
                    Console.WriteLine("Coop=" + capabilities.Coop);
                    Console.WriteLine("Password=" + capabilities.Password);
                    Console.WriteLine("OptionalFile=" + capabilities.OptionalFile);
                    Console.WriteLine("Config=" + capabilities.Config);
                    Console.WriteLine("CoopResume=" + capabilities.CoopResume);
                    Console.WriteLine("NetworkRules=" + string.Join(",", capabilities.NetworkRules));
                    return 0;
                }
                if (HasArgument(args, "--scan-saves")) {
                    foreach (SavegameInfo save in SavegameService.Scan(baseDirectory)) {
                        Console.WriteLine(Path.GetFileName(save.Path) + "\t" +
                            save.CurrentMap + "\t" + save.CreationTime.ToString("s") +
                            "\t" + save.DisplayTitle);
                    }
                    return 0;
                }
                if (HasArgument(args, "--print-save-roots")) {
                    foreach (string root in SavegameService.GetSaveRoots(baseDirectory)) {
                        Console.WriteLine(root);
                    }
                    return 0;
                }
                string checkSave = ReadArgumentValue(args, "--check-save");
                if (checkSave != null) {
                    LauncherOptions saveOptions = LauncherOptions.Load(baseDirectory);
                    ApplyDiagnosticArguments(saveOptions, args, baseDirectory);
                    string savePath = Path.IsPathRooted(checkSave)
                        ? checkSave
                        : Path.Combine(baseDirectory, checkSave);
                    SaveCompatibilityResult saveStatus = SavegameService.Check(
                        SavegameService.Read(savePath), saveOptions);
                    foreach (SaveCompatibilityIssue issue in saveStatus.Issues) {
                        Console.WriteLine(issue.Severity.ToString().ToUpperInvariant() +
                            "\t" + issue.Message);
                    }
                    Console.WriteLine("Compatible=" + saveStatus.CanLaunch);
                    return saveStatus.CanLaunch ? 0 : 2;
                }
                string sessionPath = ReadArgumentValue(args, "--validate-session");
                if (sessionPath != null) {
                    BoaMultiplayerSession session = MultiplayerSessionFile.Load(
                        Path.GetFullPath(sessionPath));
                    SessionValidation validation = MultiplayerSessionFile.Validate(
                        baseDirectory, session);
                    foreach (string error in validation.Errors) Console.WriteLine("ERROR\t" + error);
                    foreach (string warning in validation.Warnings) Console.WriteLine("WARNING\t" + warning);
                    return validation.IsCompatible ? 0 : 2;
                }
                string createSession = ReadArgumentValue(args, "--create-session");
                if (createSession != null) {
                    LauncherOptions sessionOptions = LauncherOptions.Load(baseDirectory);
                    ApplyDiagnosticArguments(sessionOptions, args, baseDirectory);
                    MultiplayerSessionFile.Save(
                        Path.GetFullPath(createSession),
                        MultiplayerSessionFile.Create(sessionOptions));
                    return 0;
                }
                string diagnosticsPath = ReadArgumentValue(args, "--create-diagnostics");
                if (diagnosticsPath != null) {
                    LauncherOptions diagnosticOptions = LauncherOptions.Load(baseDirectory);
                    ApplyDiagnosticArguments(diagnosticOptions, args, baseDirectory);
                    DiagnosticsPackage.Create(Path.GetFullPath(diagnosticsPath), diagnosticOptions);
                    return 0;
                }
                if (HasArgument(args, "--preflight")) {
                    LauncherOptions preflightOptions = LauncherOptions.Load(baseDirectory);
                    ApplyDiagnosticArguments(preflightOptions, args, baseDirectory);
                    List<AddonDescriptor> selected = SelectedAddons(preflightOptions);
                    PreflightResult preflight = LauncherPreflight.Inspect(
                        preflightOptions, selected);
                    foreach (PreflightFinding finding in preflight.Findings) {
                        Console.WriteLine(finding.ToString());
                    }
                    Console.WriteLine("CanLaunch=" + preflight.CanLaunch);
                    return preflight.CanLaunch ? 0 : 2;
                }
                if (HasArgument(args, "--print-launcher-manifest")) {
                    LauncherOptions manifestOptions = LauncherOptions.Load(baseDirectory);
                    BoaContentCatalog catalog = BoaContentCatalog.Load(
                        baseDirectory, manifestOptions.Language);
                    BoaLauncherManifest manifest = BoaLauncherManifest.Load(
                        baseDirectory, catalog);
                    Console.WriteLine("Source=" + manifest.Source);
                    Console.WriteLine("FormatVersion=" + manifest.FormatVersion);
                    Console.WriteLine("BoaVersion=" + manifest.BoaVersion);
                    Console.WriteLine("MinimumEngineVersion=" + manifest.MinimumEngineVersion);
                    Console.WriteLine("Languages=" + string.Join(",", manifest.SupportedLanguages.ToArray()));
                    Console.WriteLine("Missions=" + string.Join(",", manifest.Missions.ToArray()));
                    return 0;
                }
                string generateManifest = ReadArgumentValue(args, "--generate-launcher-manifest");
                if (generateManifest != null) {
                    LauncherOptions manifestOptions = LauncherOptions.Load(baseDirectory);
                    BoaContentCatalog catalog = BoaContentCatalog.Load(
                        baseDirectory, manifestOptions.Language);
                    File.WriteAllText(Path.GetFullPath(generateManifest),
                        BoaLauncherManifest.CreateJson(string.Empty, catalog),
                        new System.Text.UTF8Encoding(false));
                    return 0;
                }
                if (HasArgument(args, "--validate-addon-matrix")) {
                    LauncherOptions matrixOptions = LauncherOptions.Load(baseDirectory);
                    List<AddonDescriptor> addons = AddonDescriptor.Scan(
                        baseDirectory, matrixOptions.InterfaceLanguage);
                    List<string> lines = AddonLoadOrderResolver.ValidatePairwiseMatrix(
                        baseDirectory, addons);
                    foreach (string line in lines) Console.WriteLine(line);
                    return 0;
                }
                if (HasArgument(args, "--resolve-addon-order")) {
                    LauncherOptions orderOptions = LauncherOptions.Load(baseDirectory);
                    ApplyDiagnosticArguments(orderOptions, args, baseDirectory);
                    AddonLoadOrderResult order = AddonLoadOrderResolver.Resolve(
                        SelectedAddons(orderOptions));
                    foreach (AddonDescriptor addon in order.Ordered) {
                        Console.WriteLine(addon.RelativePath);
                    }
                    foreach (string message in order.Messages) {
                        Console.WriteLine("INFO\t" + message);
                    }
                    return order.CanResolve ? 0 : 2;
                }
                if (HasArgument(args, "--analyze-last-crash")) {
                    CrashDiagnosis diagnosis = CrashLogAnalyzer.AnalyzeLatest(baseDirectory);
                    if (diagnosis == null) {
                        Console.WriteLine("No recognized crash signature found.");
                    } else {
                        Console.WriteLine("Category=" + diagnosis.Category);
                        Console.WriteLine("Summary=" + diagnosis.Summary);
                        Console.WriteLine("Recommendation=" + diagnosis.Recommendation);
                        Console.WriteLine("Log=" + diagnosis.LogPath);
                    }
                    return 0;
                }
                if (HasArgument(args, "--print-command") ||
                        HasArgument(args, "--print-ui")) {
                    LauncherOptions options = LauncherOptions.Load(baseDirectory);
                    ApplyDiagnosticArguments(options, args, baseDirectory);
                    if (HasArgument(args, "--print-ui")) {
                        ModernLocalization text =
                            ModernLocalization.Load(options.InterfaceLanguage);
                        Console.WriteLine("GameLanguage=" + options.Language);
                        Console.WriteLine(
                            "InterfaceLanguage=" + options.InterfaceLanguage);
                        Console.WriteLine("Theme=" + options.Theme);
                        Console.WriteLine(
                            "QuickLaunch=" + text.Get("Quick launch"));
                        Console.WriteLine("Addons=" + text.Get("Add-ons"));
                        Console.WriteLine("Multiplayer=" + text.Get("Multiplayer"));
                        Console.WriteLine("Chapter=" + text.Get("Chapter"));
                        Console.WriteLine("Diagnostics=" + text.Get("Diagnostics"));
                        Console.WriteLine("StartNewCampaign=" + text.Get("Start New Campaign"));
                        Console.WriteLine("StartMultiplayerSession=" + text.Get("Start Multiplayer Session"));
                        Console.WriteLine("ContinueCampaign=" + text.Get("Continue Campaign"));
                        Console.WriteLine("SafeMode=" + text.Get("Start in Safe Mode"));
                        Console.WriteLine("SupportPackage=" + text.Get("Create support package"));
                    } else {
                        Console.WriteLine(LauncherCommand.BuildDisplayCommand(options));
                    }
                    return 0;
                }

                if (HasArgument(args, "--software-rendering")) {
                    System.Windows.Media.RenderOptions.ProcessRenderMode =
                        System.Windows.Interop.RenderMode.SoftwareOnly;
                }
                Application application = new Application();
                application.ShutdownMode = ShutdownMode.OnMainWindowClose;
                application.DispatcherUnhandledException += delegate(
                        object sender,
                        System.Windows.Threading.DispatcherUnhandledExceptionEventArgs eventArgs) {
                    MessageBox.Show(
                        eventArgs.Exception.Message,
                        "Blade of Agony",
                        MessageBoxButton.OK,
                        MessageBoxImage.Error);
                    eventArgs.Handled = true;
                };
                application.Run(new ModernMainWindow(baseDirectory));
                return 0;
            } catch (Exception exception) {
                Console.Error.WriteLine(exception);
                if (!Environment.UserInteractive || args.Length > 0) {
                    return 1;
                }
                MessageBox.Show(
                    exception.Message,
                    "Blade of Agony",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
                return 1;
            }
        }

        private static void PrintHelp()
        {
            Console.WriteLine(
                "Blade of Agony Launcher 2\n" +
                "  --print-command          Print the generated UZDoom command.\n" +
                "  --print-ui               Print localized navigation labels.\n" +
                "  --print-content          Parse MAPINFO and language.csv.\n" +
                "  --scan-addons            List descriptors found in /addons.\n" +
                "  --check-multiplayer      Check uzdoom.exe 5.0.3 or newer and boa.ipk3.\n" +
                "  --check-addons          Analyze selected add-on metadata and overlaps.\n" +
                "  --print-capabilities     Probe and print UZDoom command capabilities.\n" +
                "  --scan-saves             List readable Blade of Agony savegames.\n" +
                "  --print-save-roots       List local and UZDoom user save directories.\n" +
                "  --check-save FILE        Verify a save against files and selected add-ons.\n" +
                "  --validate-session FILE  Validate a .boa-session file.\n" +
                "  --create-session FILE    Export the current host settings.\n" +
                "  --create-diagnostics ZIP Create a redacted support package.\n" +
                "  --preflight              Validate files, paths, engine, and add-ons.\n" +
                "  --print-launcher-manifest Read boa-launcher.json or MAPINFO fallback.\n" +
                "  --generate-launcher-manifest FILE Create a manifest from current content.\n" +
                "  --validate-addon-matrix  Validate all official add-ons pairwise.\n" +
                "  --resolve-addon-order    Print dependency-correct selected add-on order.\n" +
                "  --analyze-last-crash     Classify the latest recognized engine failure.\n" +
                "  --base-directory DIR     Use a separate game directory.\n" +
                "  --detail VALUE           last/default/verylow/low/normal/high/veryhigh.\n" +
                "  --displacement on|off    Select displacement textures.\n" +
                "  --language CODE          Game language, including en-US/en-GB.\n" +
                "  --interface-language CODE Set the launcher language.\n" +
                "  --theme VALUE            dark/light/boa/wolfenstein3d.\n" +
                "  --direct-start on|off    Start the selected campaign map directly.\n" +
                "  --map MAP                Select the start map.\n" +
                "  --skill 1-5              Select the difficulty.\n" +
                "  --multiplayer MODE       single/host/join.\n" +
                "  --players 2-4            Total players for hosting.\n" +
                "  --host HOST --port PORT  Join target or host port.\n" +
                "  --cheats on|off          Host sv_cheats setting.\n" +
                "  --password VALUE         UZDoom 5 lobby password (maximum 255 UTF-8 bytes).\n" +
                "  --network-rule KEY=VALUE Set a supported host network rule.\n" +
                "  --coop-save PATH         Resume/select a local co-op save for host/join.\n" +
                "  --continue FILE          Continue a specific .zds savegame.\n" +
                "  --safe-mode              Use an isolated config without add-ons.\n" +
                "  --no-addons               Disable all selected add-ons.\n" +
                "  --multi-addon FILE        Append an add-on descriptor.");
        }

        private static bool HasArgument(string[] args, string expected)
        {
            foreach (string arg in args) {
                if (string.Equals(arg, expected, StringComparison.OrdinalIgnoreCase)) {
                    return true;
                }
            }
            return false;
        }

        private static List<AddonDescriptor> SelectedAddons(LauncherOptions options)
        {
            List<AddonDescriptor> result = new List<AddonDescriptor>();
            if (!options.UseAddon) return result;
            if (options.MultiAddons.Count > 0) {
                result.AddRange(options.MultiAddons);
            } else if (options.SingleAddon != null) {
                result.Add(options.SingleAddon);
            }
            return result;
        }

        private static string ReadBaseDirectory(string[] args)
        {
            for (int index = 0; index + 1 < args.Length; index++) {
                if (string.Equals(
                        args[index], "--base-directory",
                        StringComparison.OrdinalIgnoreCase)) {
                    return Path.GetFullPath(args[index + 1]);
                }
            }
            return AppDomain.CurrentDomain.BaseDirectory;
        }

        private static void ApplyDiagnosticArguments(
            LauncherOptions options, string[] args, string baseDirectory)
        {
            List<AddonDescriptor> multi = new List<AddonDescriptor>();
            for (int index = 0; index < args.Length; index++) {
                string value;
                if (TryReadValue(args, ref index, "--detail", out value)) {
                    options.DetailPreset = LauncherOptions.ParseDetail(value);
                } else if (TryReadValue(
                        args, ref index, "--displacement", out value)) {
                    options.DisplacementTextures = ParseToggle(value);
                } else if (TryReadValue(
                        args, ref index, "--language", out value)) {
                    options.Language = LauncherOptions.NormalizeGameLanguage(value);
                } else if (TryReadValue(
                        args, ref index, "--interface-language", out value)) {
                    options.InterfaceLanguage =
                        LauncherOptions.NormalizeInterfaceLanguage(value);
                } else if (TryReadValue(args, ref index, "--theme", out value)) {
                    options.Theme = LauncherOptions.ParseTheme(value);
                } else if (TryReadValue(
                        args, ref index, "--commentary", out value)) {
                    options.DeveloperCommentary = ParseToggle(value);
                } else if (TryReadValue(
                        args, ref index, "--direct-start", out value)) {
                    options.DirectStart = ParseToggle(value);
                } else if (TryReadValue(
                        args, ref index, "--multiplayer", out value)) {
                    options.NetworkMode =
                        LauncherOptions.ParseMultiplayerMode(value);
                } else if (TryReadValue(
                        args, ref index, "--players", out value)) {
                    options.MultiplayerPlayers = ParseInteger(value, "--players");
                } else if (TryReadValue(args, ref index, "--map", out value)) {
                    string map = LauncherOptions.NormalizeMapName(value);
                    options.SinglePlayerStartMap = map;
                    options.MultiplayerStartMap = map;
                } else if (TryReadValue(args, ref index, "--host", out value)) {
                    options.MultiplayerHost = LauncherOptions.NormalizeHost(value);
                } else if (TryReadValue(args, ref index, "--port", out value)) {
                    options.MultiplayerPort = ParseInteger(value, "--port");
                } else if (TryReadValue(args, ref index, "--skill", out value)) {
                    int skill = ParseInteger(value, "--skill");
                    options.SinglePlayerSkill = skill;
                    options.MultiplayerSkill = skill;
                } else if (TryReadValue(args, ref index, "--cheats", out value)) {
                    options.MultiplayerCheats = ParseToggle(value);
                } else if (TryReadValue(args, ref index, "--network-rule", out value)) {
                    string[] pair = value.Split('=');
                    int setting;
                    if (pair.Length != 2 || !int.TryParse(pair[1], out setting))
                        throw new ArgumentException("Use --network-rule KEY=VALUE.");
                    options.MultiplayerRules[pair[0]] = setting;
                    MultiplayerSettings.ValidateRules(options.MultiplayerRules);
                } else if (TryReadValue(args, ref index, "--coop-save", out value)) {
                    options.MultiplayerSavePath = Path.GetFullPath(Path.IsPathRooted(value)
                        ? value : Path.Combine(baseDirectory, value));
                } else if (TryReadValue(args, ref index, "--password", out value)) {
                    options.MultiplayerPassword = value;
                } else if (TryReadValue(args, ref index, "--continue", out value)) {
                    options.ContinueCampaign = true;
                    options.ContinueSavePath = Path.IsPathRooted(value)
                        ? value
                        : Path.Combine(baseDirectory, value);
                } else if (string.Equals(
                        args[index], "--safe-mode",
                        StringComparison.OrdinalIgnoreCase)) {
                    options.SafeMode = true;
                } else if (string.Equals(
                        args[index], "--no-addons",
                        StringComparison.OrdinalIgnoreCase)) {
                    options.UseAddon = false;
                    options.SingleAddon = null;
                    options.MultiAddons.Clear();
                } else if (TryReadValue(
                        args, ref index, "--multi-addon", out value)) {
                    multi.Add(AddonDescriptor.Load(
                        ResolveDescriptor(baseDirectory, value),
                        options.InterfaceLanguage));
                }
            }
            if (multi.Count > 0) {
                options.MultiAddons = multi;
                options.SingleAddon = null;
                options.UseAddon = true;
            }
        }

        private static bool TryReadValue(
            string[] args, ref int index, string name, out string value)
        {
            value = null;
            if (!string.Equals(args[index], name, StringComparison.OrdinalIgnoreCase)) {
                return false;
            }
            if (index + 1 >= args.Length) {
                throw new ArgumentException("Missing value for " + name + ".");
            }
            index++;
            value = args[index];
            return true;
        }

        private static bool ParseToggle(string value)
        {
            return string.Equals(value, "on", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(value, "1", StringComparison.OrdinalIgnoreCase) ||
                string.Equals(value, "true", StringComparison.OrdinalIgnoreCase);
        }

        private static int ParseInteger(string value, string name)
        {
            int result;
            if (!int.TryParse(
                    value, NumberStyles.Integer,
                    CultureInfo.InvariantCulture, out result)) {
                throw new ArgumentException("Invalid integer for " + name + ": " + value);
            }
            return result;
        }

        private static string ResolveDescriptor(string baseDirectory, string value)
        {
            return Path.IsPathRooted(value)
                ? value
                : Path.Combine(baseDirectory, value);
        }

        private static string ReadArgumentValue(string[] args, string name)
        {
            for (int index = 0; index + 1 < args.Length; index++) {
                if (string.Equals(args[index], name, StringComparison.OrdinalIgnoreCase)) {
                    return args[index + 1];
                }
            }
            return null;
        }
    }
}
