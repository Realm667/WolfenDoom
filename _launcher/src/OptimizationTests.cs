using System;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Collections.Generic;
using System.Threading;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Threading;

namespace BladeOfAgonyLauncher
{
    internal static class OptimizationTests
    {
        [STAThread]
        private static int Main(string[] args)
        {
            try {
                string root = args[0];
                TestEngineMinimum(root);
                TestAtomicSave(root);
                TestCaches(root);
                TestStartModes();
                TestCampaignIssues(root);
                TestArchiveInvalidation(root);
                TestCampaignLaunch(root);
                return 0;
            } catch (Exception error) {
                Console.Error.WriteLine(error);
                return 1;
            }
        }

        private static void Require(bool condition, string message)
        {
            if (!condition) throw new Exception(message);
        }

        private static void TestEngineMinimum(string root)
        {
            foreach (string version in new[] { "5.0.3", "5.0.3.0", "UZDoom 5.0.3",
                    "5.0.4", "5.1.0", "5.10.0", "6.0.0", "6.0.0-rc.1" }) {
                Require(EngineVersionSupport.IsSupported(version), "Rejected supported version: " + version);
            }
            foreach (string version in new[] { null, "", "unknown", "4.14.3", "4.99.0",
                    "5.0", "5.0.1", "5.0.2", "5.0.0", "5.0.0.99", "5.0.0-rc.1", "5.0.3-pre.1",
                    "5.0.3-rc.1", "5.0.3-beta.2", "5.0.3-dev" }) {
                Require(!EngineVersionSupport.IsSupported(version), "Accepted unsupported version: " + version);
            }

            foreach (string version in new[] { "4.14.3", "5.0.0", "5.0.1", "5.0.2", "5.0.3", "5.1.0", "6.0.0" }) {
                string directory = Path.Combine(root, "engine-" + version);
                Directory.CreateDirectory(directory);
                string source = Path.Combine(directory, "Engine.cs");
                File.WriteAllText(source, "using System.Reflection;" +
                    "[assembly: AssemblyFileVersion(\"" + version + ".0\")]" +
                    "[assembly: AssemblyInformationalVersion(\"" + version + "\")]" +
                    "class Engine { static void Main() {} }");
                string compiler = Path.Combine(System.Runtime.InteropServices.RuntimeEnvironment.GetRuntimeDirectory(), "csc.exe");
                using (var process = System.Diagnostics.Process.Start(new System.Diagnostics.ProcessStartInfo(compiler,
                        "/nologo /target:exe /out:\"" + Path.Combine(directory, "uzdoom.exe") + "\" \"" + source + "\"") {
                        UseShellExecute = false, CreateNoWindow = true })) {
                    process.WaitForExit();
                    Require(process.ExitCode == 0, "Version fixture compilation failed.");
                }
                ZipText(Path.Combine(directory, "boa.ipk3"), "mapinfo.txt", "map C1M1 {}\n");
                bool supported = EngineVersionSupport.IsSupported(version);
                Require(MultiplayerCompatibilityStatus.Inspect(directory).IsReady == supported,
                    "Multiplayer compatibility disagrees with the engine floor: " + version);
                Require(EngineVersionSupport.ReleaseChannel(directory) == (supported
                    ? EngineReleaseChannel.Stable : EngineReleaseChannel.Unsupported), "Incorrect engine channel.");
                foreach (MultiplayerMode mode in Enum.GetValues(typeof(MultiplayerMode))) {
                    foreach (bool safe in new[] { false, true }) {
                        LauncherOptions options = new LauncherOptions { BaseDirectory = directory,
                            NetworkMode = mode, SafeMode = safe, UseAddon = false };
                        Require(LauncherPreflight.Inspect(options, null).CanLaunch == supported,
                            "Preflight engine floor failed: " + version + "/" + mode + "/" + safe);
                        if (supported) continue;
                        foreach (bool resume in new[] { false, true }) {
                            options.ContinueCampaign = resume;
                            options.ContinueSavePath = resume ? "save.zds" : null;
                            bool blocked = false;
                            try {
                                using (var process = LauncherCommand.Start(options)) { process.WaitForExit(); }
                            } catch (InvalidDataException error) {
                                blocked = error.Message.Contains("5.0.3 or newer");
                            }
                            Require(blocked, "Unsupported engine reached process start.");
                        }
                    }
                }
                File.WriteAllText(Path.Combine(directory, "boa-launcher.json"),
                    "{\"formatVersion\":1,\"minimumEngineVersion\":\"4.14.3\"}");
                Require(BoaLauncherManifest.Load(directory, null).MinimumEngineVersion == "5.0.3",
                    "An old manifest lowered the engine floor.");
            }
            Console.WriteLine("UZDoom 5.0.3 floor: version boundaries, preflight, multiplayer, save/safe-mode start guards and old manifests: PASS");
        }

        private static void TestAtomicSave(string root)
        {
            string path = Path.Combine(root, "atomic.ini");
            IniFile ini = new IniFile();
            ini.Set("Test", "Value", "before");
            ini.Save(path);
            using (FileStream reader = File.Open(path, FileMode.Open,
                    FileAccess.Read, FileShare.ReadWrite | FileShare.Delete)) {
                ini.Set("Test", "Value", "after");
                ini.Save(path);
                using (StreamReader text = new StreamReader(reader)) {
                    Require(text.ReadToEnd().Contains("Value=before"),
                        "An existing reader must retain the complete old file.");
                }
            }
            Require(IniFile.Load(path).Get("Test", "Value", "") == "after",
                "New readers must see the complete replacement.");
            Require(Directory.GetFiles(root, "*.tmp").Length == 0,
                "Temporary INI files were not cleaned up.");
            Console.WriteLine("Atomic INI replacement: PASS");
        }

        private static void ZipText(string path, string entryName, string text)
        {
            using (ZipArchive archive = ZipFile.Open(path, ZipArchiveMode.Create))
            using (StreamWriter writer = new StreamWriter(archive.CreateEntry(entryName).Open())) {
                writer.Write(text);
            }
        }

        private static void TestCampaignIssues(string root)
        {
            var opt = LauncherOptions.Load(root);
            var addon = new AddonDescriptor { NewCampaignRequired = true, Iwad = "" };
            opt.UseAddon = true;
            opt.SingleAddon = addon;
            opt.NewCampaign = opt.DirectStart = opt.ContinueCampaign = false;
            Require(ModernMainWindow.ShouldWarnNewCampaignAddon(opt), "Missing main-menu add-on warning.");
            opt.NewCampaign = true;
            Require(!ModernMainWindow.ShouldWarnNewCampaignAddon(opt), "New Campaign asks twice.");
            opt.NewCampaign = false;
            opt.DirectStart = true;
            Require(!ModernMainWindow.ShouldWarnNewCampaignAddon(opt), "Direct mission start asks twice.");
            opt.UseAddon = false;
            opt.SingleAddon = null;
            opt.OnDeath = LauncherOptions.DeathAction.StayDead;
            opt.Save();
            Require(LauncherOptions.Load(root).OnDeath == opt.OnDeath, "Death preference did not persist.");
            for (int i = 1; i <= 5; i++) {
                opt.SinglePlayerSkill = i;
                var args = LauncherCommand.BuildArguments(opt);
                Require(args.Contains("sv_norespawn") && args[args.IndexOf("sv_norespawn")+1] == "1" &&
                    args[args.IndexOf("-skill")+1] == i.ToString(), "Incorrect manual death arguments.");
            }
            opt.DirectStart = false;
            Require(!LauncherCommand.BuildArguments(opt).Contains("sv_norespawn"), "Main menu inherited death rule.");
            opt.ContinueCampaign = true;
            opt.ContinueSavePath = "save00.zds";
            Require(!LauncherCommand.BuildArguments(opt).Contains("sv_norespawn"), "Continue overrides saved rule.");
            opt.ContinueCampaign = false;
            opt.NetworkMode = MultiplayerMode.Host;
            Require(!LauncherCommand.BuildArguments(opt).Contains("sv_norespawn"), "Co-op inherited death rule.");
            opt.NetworkMode = MultiplayerMode.SinglePlayer;
            opt.OnDeath = LauncherOptions.DeathAction.Reload;
            opt.Save();
            Console.WriteLine("Campaign confirmation, death rule, skill preservation and isolation: PASS");
        }

        private static void TestStartModes()
        {
            LauncherOptions options = new LauncherOptions();
            options.NewCampaign = true;
            options.DirectStart = true;
            Require(options.DirectStart && !options.NewCampaign, "Mission selection retained New Campaign.");
            options.ContinueCampaign = true;
            options.ContinueSavePath = "saved game.zds";
            options.DirectStart = false;
            options.NewCampaign = false;
            Require(options.ContinueCampaign && options.ContinueSavePath != null,
                "Clearing inactive legacy flags lost Continue.");
            options.NewCampaign = true;
            Require(!options.ContinueCampaign && options.ContinueSavePath == null,
                "New Campaign retained a stale save target.");
            LauncherOptions snapshot = options.Snapshot();
            options.DirectStart = true;
            Require(snapshot.NewCampaign, "Changing UI state modified a pending launch snapshot.");
            Console.WriteLine("Exclusive campaign modes and independent launch snapshots: PASS");
        }

        private static void TestCaches(string root)
        {
            string path = Path.Combine(root, "cache.txt");
            File.WriteAllText(path, "one");
            FileMemo<string> cache = new FileMemo<string>(2);
            int reads = 0;
            Func<string> read = delegate { reads++; return File.ReadAllText(path); };
            Require(cache.Get(path, "", read) == "one" && cache.Get(path, "", read) == "one" && reads == 1,
                "An unchanged file was reread.");
            File.WriteAllText(path, "two-updated");
            Require(cache.Get(path, "", read) == "two-updated" && reads == 2,
                "A changed file retained stale cached data.");
            cache.Get(path, "variant-a", read);
            cache.Get(path, "variant-b", read);
            int previous = reads;
            cache.Get(path, "", read);
            Require(reads == previous + 1, "The cache did not evict its oldest entry.");
            File.Delete(path);
            bool missing = false;
            try { cache.Get(path, "", read); } catch (FileNotFoundException) { missing = true; }
            Require(missing, "A deleted file remained readable through the cache.");
            File.WriteAllText(path, "recreated");
            Require(cache.Get(path, "", read) == "recreated", "A failed read poisoned the cache.");

            string save = Path.Combine(root, "metadata.zds");
            ZipText(save, "info.json", "{\"Title\":\"First\",\"Game WAD\":\"boa.ipk3\"}");
            Require(SavegameService.Read(save).Title == "First", "Save metadata read failed.");
            File.Delete(save);
            ZipText(save, "info.json", "{\"Title\":\"Updated title\",\"Game WAD\":\"boa.ipk3\"}");
            Require(SavegameService.Read(save).Title == "Updated title", "A replaced save retained old metadata.");
            string hash = FileFingerprint.CachedSha256(root, path);
            File.WriteAllText(path, "changed fingerprint");
            Require(FileFingerprint.CachedSha256(root, path) != hash, "A modified file retained its fingerprint.");
            FileFingerprint.Flush();
            Require(File.Exists(Path.Combine(LauncherPaths.DataDirectory(root), "file-fingerprints.ini")),
                "Pending fingerprints were not persisted.");
            Console.WriteLine("Cache hits, invalidation, eviction, recovery and fingerprint flush: PASS");
        }

        private static void TestArchiveInvalidation(string root)
        {
            string firstPath = Path.Combine(root, "first.pk3");
            string secondPath = Path.Combine(root, "second.pk3");
            ZipText(firstPath, "zscript/shared.zs", "class First {}");
            ZipText(secondPath, "zscript/separate.zs", "class Second {}");
            AddonDescriptor first = new AddonDescriptor { Id = "first", Title = "First",
                MinimumBoaVersion = "", MinimumEngineVersion = "" };
            AddonDescriptor second = new AddonDescriptor { Id = "second", Title = "Second",
                MinimumBoaVersion = "", MinimumEngineVersion = "" };
            first.LoadFiles.Add("first.pk3");
            second.LoadFiles.Add("second.pk3");
            AddonDescriptor[] pair = { first, second };
            Require(!AddonCompatibility.Analyze(root, pair).Any(
                delegate(CompatibilityIssue issue) { return issue.Severity == CompatibilitySeverity.Error; }),
                "Separate archives were incorrectly blocked.");
            File.Delete(secondPath);
            ZipText(secondPath, "zscript/shared.zs", "class SecondUpdated {}");
            Require(AddonCompatibility.Analyze(root, pair).Any(
                delegate(CompatibilityIssue issue) { return issue.Severity == CompatibilitySeverity.Error; }),
                "Replacing an archive did not invalidate the compatibility index.");
            Console.WriteLine("Archive cache invalidation after payload replacement: PASS");
        }

        private static void TestCampaignLaunch(string root)
        {
            // The fixture engine records the actual argv and never starts a game.
            string source = Path.Combine(root, "Engine.cs");
            File.WriteAllText(source,
                "using System; using System.IO; using System.Reflection; using System.Threading;" +
                "[assembly: AssemblyFileVersion(\"5.0.3.0\")]" +
                "[assembly: AssemblyInformationalVersion(\"5.0.3\")]" +
                "class Engine { static void Main(string[] a) {" +
                "if (Array.IndexOf(a,\"-help-all\")>=0) {" +
                "Thread t = new Thread(delegate() { for(int i=0;i<1000;i++) Console.Error.WriteLine(\"-password -config\"); });" +
                "t.Start(); for(int i=0;i<1000;i++) Console.WriteLine(\"-loadgame -episode -coop -optfile\"); t.Join(); return; }" +
                "File.AppendAllText(\"launch-count.txt\",\"launch\\n\"); File.WriteAllLines(\"actual-argv.txt\",a); }}");
            string compiler = Path.Combine(System.Runtime.InteropServices.RuntimeEnvironment.GetRuntimeDirectory(), "csc.exe");
            System.Diagnostics.Process compilerProcess = System.Diagnostics.Process.Start(
                new System.Diagnostics.ProcessStartInfo(compiler,
                    "/nologo /target:exe /out:\"" + Path.Combine(root, "uzdoom.exe") + "\" \"" + source + "\"") {
                    UseShellExecute = false, CreateNoWindow = true
                });
            compilerProcess.WaitForExit();
            Require(compilerProcess.ExitCode == 0, "Engine fixture compilation failed.");
            compilerProcess.Dispose();
            ZipText(Path.Combine(root, "boa.ipk3"), "mapinfo.txt",
                "map C1M1 { levelnum = 1 name = \"Test\" }\nmap C1M2 { levelnum = 2 name = \"Second\" }\nmap C2M1 { levelnum = 3 name = \"Third\" }\nepisode C1M1\n{\nname = \"Chapter One\"\n}\nepisode C2M1\n{\nname = \"Chapter Two\"\n}\nskill normal\n{\nname = \"Normal\"\n}\n");
            string saveDirectory = Path.Combine(root, "save");
            Directory.CreateDirectory(saveDirectory);
            string savePath = Path.Combine(saveDirectory, "save00.zds");
            ZipText(savePath, "info.json",
                "{\"Title\":\"Fixture save\",\"Current Map\":\"C1M1\",\"Game WAD\":\"boa.ipk3\"}");
            using (ZipArchive zip = ZipFile.Open(savePath, ZipArchiveMode.Update)) {
                var picture = System.Windows.Media.Imaging.BitmapFrame.Create(new Uri(Path.GetFullPath(Path.Combine(root, "..", "..", "assets", "launcher.jpg"))), System.Windows.Media.Imaging.BitmapCreateOptions.None, System.Windows.Media.Imaging.BitmapCacheOption.OnLoad);
                var encoder = new System.Windows.Media.Imaging.PngBitmapEncoder();
                encoder.Frames.Add(picture);
                using (Stream stream = zip.CreateEntry("savepic.png").Open()) encoder.Save(stream);
            }
            for (int i=1; i<=12; i++) {
                string older = Path.Combine(saveDirectory, "save" + i.ToString("00") + ".zds");
                File.Copy(savePath, older);
                File.SetLastWriteTimeUtc(older, DateTime.UtcNow.AddDays(-i));
            }
            IniFile engineConfig = new IniFile();
            engineConfig.Set("GlobalSettings", "save_dir", saveDirectory);
            engineConfig.Save(Path.Combine(root, "uzdoom_portable.ini"));
            LauncherOptions options = LauncherOptions.Load(root);
            options.DisplacementTextures = false;
            options.SinglePlayerStartMap = "C1M1";
            options.Save();
            EngineCapabilitySet capabilities = EngineCapabilities.Detect(root);
            Require(capabilities.Probed && capabilities.Password && capabilities.LoadGame && capabilities.Config,
                "Concurrent stdout/stderr collection lost engine capabilities.");
            LauncherOptions recovery = options.Snapshot();
            recovery.SafeMode = recovery.UseAddon = true;
            recovery.MultiAddons.Add(new AddonDescriptor { Iwad = "wrong.wad" });
            recovery.MultiAddons.Add(new AddonDescriptor { Iwad = "other.wad" });
            var safeArgs = LauncherCommand.BuildArguments(recovery);
            string config = safeArgs[safeArgs.IndexOf("-config") + 1];
            Require(config == Path.Combine(LauncherPaths.DataDirectory(root), "safe-mode.ini") && File.Exists(config)
                && safeArgs[safeArgs.IndexOf("-iwad") + 1] == "boa.ipk3" && !safeArgs.Contains("-file")
                && safeArgs.Contains("-noautoload") && safeArgs.Contains("-noautoexec"), "Safe Mode leaked content/config.");
            var paths = (System.Collections.Generic.Dictionary<string, string>)typeof(LauncherPaths)
                .GetField("dataDirectories", BindingFlags.NonPublic | BindingFlags.Static).GetValue(null);
            string alternate = Directory.CreateDirectory(Path.Combine(root, "simulated user data")).FullName;
            string normalData = LauncherPaths.DataDirectory(root);
            try {
                // Exercise the consumer of the resolved path without changing the user's ACLs or AppData.
                paths[Path.GetFullPath(root)] = alternate;
                var redirected = LauncherCommand.BuildArguments(recovery);
                string path = redirected[redirected.IndexOf("-config") + 1];
                Require(path == Path.Combine(alternate, "safe-mode.ini") && File.Exists(path), "Ignored redirected data directory.");
            } finally { paths[Path.GetFullPath(root)] = normalData; }
            Console.WriteLine("Concurrent engine stdout/stderr and isolated/redirected Safe Mode argv: PASS");
            IniFile binding = new IniFile();
            binding.Set("Files", "EngineSha256", FileFingerprint.Sha256(Path.Combine(root, "uzdoom.exe")));
            binding.Set("Files", "MainGameSha256", FileFingerprint.Sha256(Path.Combine(root, "boa.ipk3")));
            binding.Set("Addons", "Selection", "");
            binding.Save(savePath + ".boa-launcher.ini");

            Application app = new Application { ShutdownMode = ShutdownMode.OnExplicitShutdown };
            SynchronizationContext.SetSynchronizationContext(
                new DispatcherSynchronizationContext(Dispatcher.CurrentDispatcher));
            TestStartupProgress(root);
            ModernMainWindow window = new ModernMainWindow(root);
            try {
                Require(window.Content is ProgressBar && ((SolidColorBrush)((ProgressBar)window.Content).Foreground).Color == ((SolidColorBrush)ThemePalette.Create(options.Theme).Accent).Color, "Startup does not use the saved theme accent.");
                window.Show();
                PumpUntil(delegate {
                    FrameworkElement action = Find(window, "ContinueCampaign");
                    return action != null && action.IsEnabled;
                });
                Require(((ComboBox)Find(window,"CampaignSavePicker")).Items.Count == 12, "Recent list is not compact.");
                Click(window, "SaveListScope");
                var allSaves = (ComboBox)Find(window, "CampaignSavePicker");
                Require(allSaves.Items.Count >= 13, "Older save is missing.");
                allSaves.SelectedIndex = allSaves.Items.Count - 1;
                Pump();
                Require(((ComboBox)Find(window,"CampaignSavePicker")).SelectedIndex >= 12, "Lost older save selection.");
                Click(window, "SaveListScope");
                Require(((ComboBox)Find(window,"CampaignSavePicker")).SelectedIndex == 0, "Recent picker disagrees with selected save.");
                PumpUntil(delegate { return Find(window,"ContinueCampaign").IsEnabled; });
                Button play = (Button)Find(window, "StartNewCampaign");
                Require(AutomationProperties.GetName(Find(window, "Nav_start")) == "Start" &&
                    ((TextBlock)Find(window, "HeadingQuickLaunch")).Text == "Start",
                    "Start page and sidebar must use the localized Start label (#1696).");
                CheckCampaignLayout(window, true);
                Require(Find(window, "StartMode") == null && Find(window, "NewCampaignAction") == null, "An obsolete footer mode or campaign radio control remains.");
                Require(IsWithin(Find(window, "CampaignDestination"), Find(window, "NewCampaignSection")), "Start selection is not in New Campaign.");
                Require(IsWithin(Find(window, "GameLanguage"), Find(window, "SharedSettings")), "Game language is not shared.");
                Require(AutomationProperties.GetName(play) == "Open Main Menu", "Main-menu action is mislabeled.");
                Require(Find(window, "HeadingDiagnostics") == null && Find(window, "ModeHost") == null,
                    "Hidden pages were built during startup.");
                ComboBox goal = (ComboBox)Find(window, "PerformanceGoal");
                goal.SelectedIndex = 2;
                Pump();
                goal = (ComboBox)Find(window, "PerformanceGoal");
                var textures = (CheckBox)Find(window, "DisplacementTextures");
                Require(IsWithin(textures, (FrameworkElement)((FrameworkElement)goal.Parent).Parent), "Textures are outside Graphics.");
                textures.IsChecked = false;
                Require(goal.SelectedIndex == 0, "Manual texture toggle retained Balanced.");
                textures.IsChecked = true;
                Require(goal.SelectedIndex == 2, "Restoring textures did not restore Balanced.");
                ((ComboBox)Find(window, "DetailPreset")).SelectedIndex = 6;
                Require(goal.SelectedIndex == 3, "Manual detail change did not derive Quality.");
                ((ComboBox)Find(window, "DetailPreset")).SelectedIndex = 0;
                textures.IsChecked = false;
                var languages = (ComboBox)Find(window, "GameLanguage");
                Require(languages.Items[0].ToString() == "Use last settings" &&
                    languages.Items[1].ToString() == "Auto", "#1730 missing language modes.");
                var hiddenChapter = Find(window, "SingleEpisode");
                Require(hiddenChapter == null || !hiddenChapter.IsVisible, "Main menu exposes chapter settings.");
                Require(Find(window, "LaunchProfilesAccordion") == null && Find(window, "LaunchProfile") == null && Find(window, "LaunchButton") == null, "Removed profile/footer controls remain.");
                Require(IsWithin(play, Find(window, "NewCampaignSection")) && !IsWithin(play, Find(window, "LaunchFooter")), "Campaign action is outside its pane.");
                Capture(window, Path.Combine(root, "v268-quick-launch.png"));
                window.Activate();
                Click(window, "ContinueCampaign");
                Require(object.ReferenceEquals(play, Find(window, "StartNewCampaign")),
                    "A campaign selection rebuilt the permanent Play control.");
                string recorded = Path.Combine(root, "actual-argv.txt");
                PumpUntil(delegate { return File.Exists(recorded); });
                PumpUntil(delegate { return play.IsEnabled; });
                string[] argv = File.ReadAllLines(recorded);
                int index = Array.IndexOf(argv, "-loadgame");
                Require(index >= 0 && argv[index + 1] == "save00.zds",
                    "Continue did not send the selected save filename to UZDoom.");
                Require(!argv.Contains("+map"), "Continue also started a new map.");
                Require(AutomationProperties.GetItemStatus(play) == "MainMenu", "Continue changed the normal Play target.");
                File.Delete(recorded);
                Click(window, "StartNewCampaign");
                PumpUntil(delegate { return File.Exists(recorded); });
                PumpUntil(delegate { return play.IsEnabled; });
                Require(!File.ReadAllLines(recorded).Contains("-loadgame"), "Play unexpectedly loaded a save.");
                File.Delete(recorded);
                ComboBox mode = (ComboBox)Find(window, "CampaignDestination");
                mode.SelectedIndex = 1;
                Require(AutomationProperties.GetName(play) == "Start New Campaign", "Chapter action is mislabeled.");
                Pump();
                var advanced = (Expander)Find(window, "AdvancedLaunchOptions");
                Require(advanced.IsVisible && !advanced.IsExpanded, "Advanced settings not collapsed by default.");
                advanced.IsExpanded = true;
                Pump();
                var debug = (CheckBox)Find(window, "MissionDebugMode");
                var debugNote = (TextBlock)((Panel)debug.Parent).Children[((Panel)debug.Parent).Children.IndexOf(debug)+1];
                Require(!debugNote.IsVisible, "Debug hint visible while off.");
                debug.IsChecked = true;
                Require(debugNote.IsVisible, "Debug hint missing.");
                debug.IsChecked = false;
                Require(((ComboBox)Find(window, "SingleMission")).SelectedIndex == 0, "Unexpected default mission.");
                Require(Find(window, "SingleEpisode").IsEnabled && Find(window, "SingleDifficulty").IsEnabled && Find(window, "SingleMission").IsEnabled, "Episode selection did not enable campaign settings.");
                Click(window, "StartNewCampaign");
                PumpUntil(delegate { return File.Exists(recorded); });
                PumpUntil(delegate { return play.IsEnabled; });
                argv = File.ReadAllLines(recorded);
                Require(!argv.Contains("-loadgame") &&
                    (argv.Contains("+map") || argv.Contains("-episode")),
                    "New Campaign retained the old save target.");
                Require(argv.Contains("C1M1"), "From the beginning did not start the selected episode.");
                File.Delete(recorded);
                ComboBox mission = (ComboBox)Find(window, "SingleMission");
                var deathMode = (ComboBox)Find(window, "SingleDeathMode");
                Require(deathMode != null && deathMode.Items.Count == 2, "Even a classic-only game package must offer manual death.");
                deathMode.SelectedValue = LauncherOptions.DeathAction.StayDead;
                mission.SelectedIndex = 2;
                Require(AutomationProperties.GetItemStatus(play) == "MissionSelect", "Explicit mission did not select the direct start path.");
                Click(window, "StartNewCampaign");
                PumpUntil(delegate { return File.Exists(recorded); });
                PumpUntil(delegate { return play.IsEnabled; });
                argv = File.ReadAllLines(recorded);
                Require(argv.Contains("+map") && argv.Contains("C1M2") && !argv.Contains("-loadgame"), "Explicit mission launch arguments are wrong.");
                Require(argv.Contains("sv_norespawn") && argv[Array.IndexOf(argv, "sv_norespawn")+1] == "1", "Death selection did not reach engine.");
                deathMode.SelectedValue = LauncherOptions.DeathAction.Reload;
                File.Delete(recorded);
                LauncherOptions windowOptions = (LauncherOptions)typeof(ModernMainWindow).GetField("options", BindingFlags.Instance | BindingFlags.NonPublic).GetValue(window);
                windowOptions.Save();
                LauncherOptions restored = LauncherOptions.Load(root);
                Require(restored.DirectStart && restored.SinglePlayerStartMap == "C1M2", "Ordinary settings did not preserve the mission.");
                typeof(ModernMainWindow).GetMethod("BuildShell", BindingFlags.Instance | BindingFlags.NonPublic).Invoke(window, null);
                PumpUntil(delegate { FrameworkElement action = Find(window, "ContinueCampaign"); return action != null && action.IsEnabled; });
                play = (Button)Find(window, "StartNewCampaign");
                mode = (ComboBox)Find(window, "CampaignDestination");
                mission = (ComboBox)Find(window, "SingleMission");
                Require(mode.SelectedIndex == 1 && mission.SelectedItem is BoaMap && ((BoaMap)mission.SelectedItem).Id == "C1M2", "Shell rebuild did not restore the mission.");
                Click(window, "ContinueCampaign");
                PumpUntil(delegate { return File.Exists(recorded); });
                PumpUntil(delegate { return play.IsEnabled; });
                Require(File.ReadAllLines(recorded).Contains("-loadgame") && AutomationProperties.GetItemStatus(play) == "MissionSelect" && mission.SelectedIndex == 2, "Continue altered the mission selection.");
                File.Delete(recorded);
                ComboBox episode = (ComboBox)Find(window, "SingleEpisode");
                episode.SelectedIndex = 1;
                Require(mission.SelectedIndex == 0 && mission.Items.Count == 2 && windowOptions.NewCampaign && windowOptions.SinglePlayerStartMap == "C2M1", "Episode change did not reset the mission to the correct beginning.");
                Click(window, "StartNewCampaign");
                PumpUntil(delegate { return File.Exists(recorded); });
                PumpUntil(delegate { return play.IsEnabled; });
                Require(File.ReadAllLines(recorded).Contains("C2M1"), "Second episode starts the wrong map.");
                File.Delete(recorded);
                episode.SelectedIndex = 0;
                Require(mission.SelectedIndex == 0 && windowOptions.SinglePlayerStartMap == "C1M1", "Returning to the first episode retained a stale mission.");
                mode.SelectedIndex = 0;
                Require(!mission.IsEnabled && mission.SelectedIndex == 0 && AutomationProperties.GetItemStatus(play) == "MainMenu", "Main menu retained a direct mission target.");
                Click(window, "StartNewCampaign");
                PumpUntil(delegate { return File.Exists(recorded); });
                PumpUntil(delegate { return play.IsEnabled; });
                argv = File.ReadAllLines(recorded);
                Require(!argv.Contains("+map") && !argv.Contains("-loadgame"), "Main menu did not clear the launch target.");
                mode.SelectedIndex = 1;
                Require(mission.SelectedIndex == 0, "Episode launch retained an advanced mission selection.");
                Console.WriteLine("Contextual campaign argv: main menu, episode beginning, explicit mission and independent Continue: PASS");
                File.Delete(recorded);
                window.Width = 760;
                window.Height = 900;
                Pump();
                CheckCampaignLayout(window, false);
                Capture(window, Path.Combine(root, "v268-narrow-save.png"));
                Find(window, "NewCampaignSection").BringIntoView();
                Pump();
                Capture(window, Path.Combine(root, "v268-narrow-campaign.png"));
                window.Width = 1180;
                window.FontSize = 21;
                Pump();
                CheckCampaignLayout(window, false);
                Capture(window, Path.Combine(root, "v268-large-text.png"));
                Find(window, "NewCampaignSection").BringIntoView();
                Pump();
                Capture(window, Path.Combine(root, "v268-large-text-campaign.png"));
                window.FontSize = 14;
                window.Width = 1440;
                window.Height = 1100;
                Pump();
                CheckCampaignLayout(window, true);
                Find(window, "HeadingQuickLaunch").BringIntoView();
                Pump();
                Capture(window, Path.Combine(root, "v268-desktop.png"));
                foreach (LauncherTheme theme in new[] { LauncherTheme.Light, LauncherTheme.Dark, LauncherTheme.Wolfenstein3D, LauncherTheme.BladeOfAgony }) {
                    windowOptions.Theme = theme;
                    windowOptions.InterfaceLanguage = theme == LauncherTheme.Light ? "de" : "en";
                    typeof(ModernMainWindow).GetMethod("BuildShell", BindingFlags.Instance | BindingFlags.NonPublic).Invoke(window, null);
                    PumpUntil(delegate { FrameworkElement action = Find(window, "ContinueCampaign"); return action != null && action.IsEnabled; });
                    CheckCampaignLayout(window, true);
                    ((Expander)Find(window, "AdvancedLaunchOptions")).IsExpanded = true;
                    Pump();
                    Require(((ComboBox)Find(window, "CampaignDestination")).SelectedIndex == 1 && ((ComboBox)Find(window, "SingleMission")).SelectedIndex == 0, "Shell rebuild desynchronized campaign choices.");
                    string chapter = ModernLocalization.Load(windowOptions.InterfaceLanguage).Get("Chapter");
                    Require(AutomationProperties.GetName(Find(window, "SingleEpisode")) == chapter, "Campaign chapter label is not localized.");
                    Capture(window, Path.Combine(root, "v268-theme-" + theme + ".png"));
                    Click(window, "Nav_multiplayer");
                    PumpUntil(delegate { return Find(window, "MultiplayerChapter") != null; });
                    Require(AutomationProperties.GetName(Find(window, "MultiplayerChapter")) == chapter, "Multiplayer chapter label is not localized.");
                    Click(window, "Nav_start");
                }
                foreach (string language in new[] { "en", "de", "es", "ru", "ptb", "it", "tr", "fr", "cs", "pl" }) {
                    foreach (string key in new[] { "Chapter", "Start New Campaign", "Start Multiplayer Session" })
                        Require(language == "en" || ModernLocalization.Load(language).Get(key) != key, "Missing action translation: " + language);
                    string translated = ModernLocalization.Load(language).Get("Shared settings");
                    Require(language == "en" || translated != "Shared settings", "Missing shared-settings translation: " + language);
                    Require(language == "en" || ModernLocalization.Load(language).Get("From the beginning") != "From the beginning", "Missing campaign-beginning translation: " + language);
                    Require(language == "en" || ModernLocalization.Load(language).Get("Mission select (optional)") != "Mission select (optional)", "Missing optional-mission translation: " + language);
                }
                using (ZipArchive zip = ZipFile.Open(savePath, ZipArchiveMode.Update)) {
                    zip.GetEntry("savepic.png").Delete();
                    using (var writer = new StreamWriter(zip.CreateEntry("savepic.png").Open())) writer.Write("broken PNG");
                }
                Click(window, "Nav_diagnostics");
                Click(window, "RefreshDiagnostics");
                Click(window, "Nav_start");
                PumpUntil(delegate { FrameworkElement v = Find(window, "CampaignPreview");
                    return v != null && v.Visibility == Visibility.Collapsed && Find(window, "ContinueCampaign").IsEnabled; });
                Console.WriteLine("Unreadable thumbnail does not block the selected save: PASS");
                for (int i=1; i<=12; i++) File.Delete(Path.Combine(saveDirectory, "save" + i.ToString("00") + ".zds"));
                File.Delete(savePath);
                Click(window, "Nav_diagnostics");
                Click(window, "RefreshDiagnostics");
                Click(window, "Nav_start");
                Require(Find(window, "ContinueCampaign") == null &&
                    AutomationProperties.GetItemStatus(Find(window, "StartNewCampaign")) == "NewCampaign",
                    "Removing the final save left a detached Continue action or stale launch target.");
                Console.WriteLine("Last-save removal clears campaign controls and launch target: PASS");
                window.Width = 760;
                window.Height = 900;
                Pump();
                Require(Find(window, "NewCampaignSection").TranslatePoint(new Point(), window).Y <
                    Find(window, "ContinueCampaignSection").TranslatePoint(new Point(), window).Y, "Empty Continue precedes New Campaign.");
                Capture(window, Path.Combine(root, "v268-compact.png"));
                Click(window, "Nav_multiplayer");
                Button multiplayer = (Button)Find(window, "StartMultiplayerSession");
                Require(multiplayer != null && multiplayer.IsEnabled && multiplayer.IsVisible && Find(window, "ModeSingle") == null, "Multiplayer should offer only host/join with an enabled action.");
                Require(((RadioButton)Find(window, "ModeHost")).IsChecked == true && windowOptions.NetworkMode == MultiplayerMode.Host, "First multiplayer visit did not default to host.");
                window.Width = 1440;
                window.Height = 1100;
                Pump();
                Capture(window, Path.Combine(root, "v268-multiplayer-idle.png"));
                RadioButton host = (RadioButton)Find(window, "ModeHost");
                host.IsChecked = true;
                Require(!Find(window, "StartNewCampaign").IsVisible && multiplayer.IsEnabled, "Launch actions are not scoped to the multiplayer page.");
                int launches = File.ReadAllLines(Path.Combine(root, "launch-count.txt")).Length;
                Click(window, "StartMultiplayerSession");
                // A second event while preflight is pending must not launch a second process.
                multiplayer.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
                PumpUntil(delegate { return File.Exists(recorded); });
                PumpUntil(delegate { return multiplayer.IsEnabled; });
                argv = File.ReadAllLines(recorded);
                Require(argv.Contains("-host") && argv.Contains("2") && !argv.Contains("-file") && !argv.Contains("-loadgame"), "Host button generated incorrect arguments.");
                Require(File.ReadAllLines(Path.Combine(root, "launch-count.txt")).Length == launches + 1, "A repeated launch event created a second engine process.");
                File.Delete(recorded);
                ((RadioButton)Find(window, "ModeJoin")).IsChecked = true;
                Click(window, "StartMultiplayerSession");
                PumpUntil(delegate { return File.Exists(recorded); });
                PumpUntil(delegate { return multiplayer.IsEnabled; });
                argv = File.ReadAllLines(recorded);
                Require(argv.Contains("-join") && !argv.Contains("-host") && !argv.Contains("-file"), "Join button generated incorrect arguments.");
                File.Delete(recorded);
                windowOptions.ImportedSessionRules = true;
                windowOptions.ImportedSessionRequiresPassword = true;
                Click(window, "Nav_start");
                Require(windowOptions.NetworkMode == MultiplayerMode.SinglePlayer && windowOptions.LastMultiplayerRole == MultiplayerMode.Join, "Campaign navigation lost the last multiplayer role.");
                windowOptions.Save();
                Require(LauncherOptions.Load(root).LastMultiplayerRole == MultiplayerMode.Join, "Last multiplayer role was not persisted.");
                multiplayer.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
                Pump();
                Require(!File.Exists(recorded), "A hidden multiplayer action launched from the campaign page.");
                Click(window, "Nav_multiplayer");
                Require(((RadioButton)Find(window, "ModeJoin")).IsChecked == true && windowOptions.NetworkMode == MultiplayerMode.Join && multiplayer.IsEnabled, "Returning to multiplayer did not restore join.");
                Require(windowOptions.ImportedSessionRules && windowOptions.ImportedSessionRequiresPassword, "Navigation cleared imported session requirements.");
                host.IsChecked = true;
                Expander network = (Expander)Find(window, "NetworkOptionsAccordion");
                Require(network != null && network.Visibility == Visibility.Visible, "Host network settings missing.");
                network.Focus();
                Pump();
                typeof(ModernMainWindow).GetMethod("HandleGamepadAction", BindingFlags.Instance | BindingFlags.NonPublic)
                    .Invoke(window, new object[] { GamepadAction.Accept });
                Require(network.IsExpanded, "Controller Accept did not expand network settings.");
                window.Width = 1180;
                window.Height = 1400;
                Pump();
                Capture(window, Path.Combine(root, "v268-multiplayer.png"));
                Click(window, "Nav_start");
                Require(Find(window, "StartNewCampaign").IsEnabled && !Find(window, "StartMultiplayerSession").IsVisible, "Return to campaign left stale multiplayer state.");
                Click(window, "Nav_addons");
                Require(!Find(window, "StartNewCampaign").IsVisible && !Find(window, "StartMultiplayerSession").IsVisible && Find(window, "LaunchButton") == null, "An unrelated page exposes a launch action.");
                Console.WriteLine("Contextual multiplayer host/join, persisted role and navigation: PASS");
                Click(window, "Nav_start");
                windowOptions.InterfaceLanguage = "de";
                string marker = Path.Combine(LauncherPaths.DataDirectory(root), "active-run.ini");
                PumpUntil(delegate { return !File.Exists(marker); });
                File.WriteAllText(marker, "[Run]\nProcessId=0\n");
                typeof(ModernMainWindow).GetField("recoveryStatus", BindingFlags.Instance | BindingFlags.NonPublic)
                    .SetValue(window, LaunchRecovery.Inspect(root));
                typeof(ModernMainWindow).GetMethod("BuildShell", BindingFlags.Instance | BindingFlags.NonPublic).Invoke(window, null);
                File.Delete(recorded);
                using (FileStream hold = File.Open(Path.Combine(root, "boa.ipk3"), FileMode.Open, FileAccess.Read, FileShare.None)) {
                    Click(window, "SafeModeLaunch");
                    PumpUntil(delegate { return Find(window, "ReviewDiagnosticFinding") != null && Find(window, "SafeModeLaunch").IsEnabled; });
                    var bar = (Border)Find(window, "CampaignReadiness");
                    Require(((TextBlock)((StackPanel)bar.Child).Children[0]).Text.Contains("Nicht lesbar: boa.ipk3"),
                        "Missing localized, concrete preflight reason.");
                    Require(File.Exists(marker) && !File.Exists(recorded) && !windowOptions.SafeMode, "Failed recovery changed normal settings or dismissed the marker.");
                }
                Click(window, "SafeModeLaunch");
                PumpUntil(delegate { return File.Exists(recorded) && Find(window, "SafeModeLaunch") == null; });
                Require(File.ReadAllLines(recorded).Contains("-config") && !windowOptions.SafeMode, "Recovery was not one-shot.");
                File.Delete(recorded);
                Click(window, "StartNewCampaign");
                PumpUntil(delegate { return File.Exists(recorded); });
                Require(!File.ReadAllLines(recorded).Contains("-config"), "Subsequent normal launch inherited Safe Mode.");
                PumpUntil(delegate { return Find(window, "StartNewCampaign").IsEnabled; });
                var first = new AddonDescriptor { Id = "confiscated", Title = "Confiscated Weapons" };
                var second = new AddonDescriptor { Id = "more", Title = "More Weapons" };
                first.MinimumEngineVersion = second.MinimumEngineVersion = first.MinimumBoaVersion = second.MinimumBoaVersion = string.Empty;
                first.ConflictingAddons.Add(second.Id);
                LauncherOptions conflicting = windowOptions.Snapshot();
                conflicting.UseAddon = true;
                PreflightResult conflict = LauncherPreflight.Inspect(conflicting, new[] { first, second });
                Border notice = (Border)Find(window, "CampaignReadiness");
                typeof(ModernMainWindow).GetMethod("SetReadiness", BindingFlags.Instance | BindingFlags.NonPublic)
                    .Invoke(window, new object[] { notice, conflict });
                Require(!conflict.CanLaunch && ((TextBlock)((StackPanel)notice.Child).Children[0]).Text.Contains(
                    "Confiscated Weapons und More Weapons sind inkompatibel."), "Localized preflight lost the conflict pair.");
                Click(window, "ReviewAddonFinding");
                Require(Find(window, "HeadingAddons").IsVisible, "Conflict action did not navigate to add-ons.");
                var list = (List<AddonListEntry>)typeof(ModernMainWindow).GetField("addonEntries", BindingFlags.Instance | BindingFlags.NonPublic).GetValue(window);
                var maker = typeof(ModernMainWindow).GetMethod("CreateAddonEntry", BindingFlags.Instance | BindingFlags.NonPublic);
                foreach (var descriptor in new[] { first, second }) {
                    var entry = (AddonListEntry)maker.Invoke(window, new object[] { descriptor, descriptor.Title });
                    entry.Item.IsSelected = true;
                    list.Add(entry);
                }
                var issue = new CompatibilityIssue { Severity = CompatibilitySeverity.Error };
                issue.AffectedAddonIds.UnionWith(new[] { first.Id, second.Id });
                issue.Summary("{0} conflicts with {1}.",first.Title,second.Title);
                var paint = typeof(ModernMainWindow).GetMethod("UpdateAddonEntryStates", BindingFlags.Instance | BindingFlags.NonPublic);
                paint.Invoke(window,new object[] { new[] { issue } });
                foreach(var entry in list.Where(e => e.Addon == first || e.Addon == second))
                    Require(((TextBlock)entry.CheckBox.Content).Text.Contains("Confiscated Weapons und More Weapons"), "Missing inline conflict reason.");
                paint.Invoke(window,new object[] { new CompatibilityIssue[0] });
                foreach(var entry in list.Where(e => e.Addon == first || e.Addon == second))
                    Require(((TextBlock)entry.CheckBox.Content).Text == entry.Label, "Stale conflict text.");
                Console.WriteLine("Inline conflict labels and clearing: PASS");
                Console.WriteLine("Failed and successful recovery, localized inline feedback and next normal launch: PASS");
            } finally {
                window.Close();
                app.Shutdown();
            }
        }

        private static void TestStartupProgress(string root)
        {
            foreach (LauncherTheme theme in new[] { LauncherTheme.BladeOfAgony, LauncherTheme.Dark, LauncherTheme.Light, LauncherTheme.Wolfenstein3D }) {
                ThemePalette colors = ThemePalette.Create(theme);
                ProgressBar bar = ModernMainWindow.CreateStartupProgress(colors);
                Grid surface = new Grid { Background = colors.Background };
                surface.Children.Add(bar);
                Window host = new Window { Width = 800, Height = 240, Content = surface };
                try {
                    host.Show();
                    Pump();
                    Border fill = (Border)bar.Template.FindName("StartupSegment", bar);
                    TranslateTransform movement = (TranslateTransform)fill.RenderTransform;
                    Require(fill.ActualWidth > 0 && fill.ActualHeight == 4 && movement.HasAnimatedProperties, "Startup indicator is blank or not animated.");
                    for (int state = 0; state < 3; state++) {
                        // Startup work disables the surface; its visual feedback must keep moving.
                        if (state == 1) surface.IsEnabled = false;
                        if (state == 2) host.Width = 520;
                        Pump();
                        double minimum = double.MaxValue, maximum = double.MinValue;
                        for (int frame = 0; frame < 4; frame++) {
                            Thread.Sleep(160);
                            Pump();
                            double center = CaptureStartupFrame(surface, bar,
                                Path.Combine(root, "startup-" + theme + "-" + state + "-" + frame + ".png"));
                            minimum = Math.Min(minimum, center);
                            maximum = Math.Max(maximum, center);
                        }
                        Require(maximum - minimum > 20, "Rendered startup segment is stationary: " + theme + ", state " + state);
                        Require(Math.Abs(fill.ActualWidth - bar.ActualWidth * 0.25) < 1, "Resized startup segment has the wrong width.");
                    }
                    host.Close();
                    Pump();
                    Require(!movement.HasAnimatedProperties, "Startup animation was not stopped on unload.");
                } finally { host.Close(); }
            }
            Console.WriteLine("Startup progress: moving pixels in all themes, disabled surface, resize and cleanup: PASS");
        }

        private static double CaptureStartupFrame(Grid surface, ProgressBar bar, string path)
        {
            var bitmap = new System.Windows.Media.Imaging.RenderTargetBitmap((int)surface.ActualWidth, (int)surface.ActualHeight, 96, 96, PixelFormats.Pbgra32);
            bitmap.Render(surface);
            Point start = bar.TranslatePoint(new Point(0, 2), surface);
            int width = (int)bar.ActualWidth;
            byte[] pixels = new byte[width * 4];
            bitmap.CopyPixels(new Int32Rect((int)start.X, (int)start.Y, width, 1), pixels, width * 4, 0);
            Color accent = ((SolidColorBrush)bar.Foreground).Color, track = ((SolidColorBrush)bar.Background).Color;
            byte[] foreground = { accent.B, accent.G, accent.R }, background = { track.B, track.G, track.R };
            int first = -1, last = -1;
            for (int x = 0; x < width; x++) {
                bool isAccent = true;
                for (int channel = 0; channel < 3; channel++) {
                    int value = pixels[x * 4 + channel];
                    Require(value >= Math.Min(foreground[channel], background[channel]) - 1 && value <= Math.Max(foreground[channel], background[channel]) + 1, "Startup contains a non-theme color.");
                    isAccent &= Math.Abs(value - foreground[channel]) <= 1;
                }
                if (isAccent) { if (first < 0) first = x; last = x; }
            }
            Require(first >= 0 && last - first > width * 0.20 && last - first < width * 0.30, "Startup must render a bounded moving segment, not a full-width fill.");
            var encoder = new System.Windows.Media.Imaging.PngBitmapEncoder();
            encoder.Frames.Add(System.Windows.Media.Imaging.BitmapFrame.Create(bitmap));
            using (Stream output = File.Create(path)) encoder.Save(output);
            return (first + last) / 2.0;
        }

        private static FrameworkElement Find(DependencyObject parent, string id)
        {
            FrameworkElement element = parent as FrameworkElement;
            if (element != null && AutomationProperties.GetAutomationId(element) == id) return element;
            for (int i = 0; i < VisualTreeHelper.GetChildrenCount(parent); i++) {
                FrameworkElement found = Find(VisualTreeHelper.GetChild(parent, i), id);
                if (found != null) return found;
            }
            return null;
        }

        private static bool IsWithin(DependencyObject child, DependencyObject ancestor)
        {
            while (child != null) { if (child == ancestor) return true; child = VisualTreeHelper.GetParent(child); }
            return false;
        }

        private static void CheckCampaignLayout(Window window, bool columns)
        {
            window.UpdateLayout();
            FrameworkElement left = Find(window, "ContinueCampaignSection"), right = Find(window, "NewCampaignSection");
            Point l = left.TranslatePoint(new Point(), window), r = right.TranslatePoint(new Point(), window);
            if (columns) {
                Require(Math.Abs(l.Y - r.Y) < 1 && Math.Abs(left.ActualWidth - right.ActualWidth) < 1 && Math.Abs(left.ActualHeight - right.ActualHeight) < 1, "Campaign panes do not share a row, width and height.");
                Require(Math.Abs(r.X - l.X - left.ActualWidth - 24) < 1, "Campaign column gap is not 24 DIP.");
            } else Require(r.Y >= l.Y + left.ActualHeight + 23 && Math.Abs(r.X - l.X) < 1, "Narrow campaign panes overlap or fail to stack.");
            FrameworkElement preview = Find(window, "CampaignPreview");
            if (preview != null && preview.IsVisible) Require(Math.Abs(preview.ActualHeight - preview.ActualWidth * 9 / 16) < 1, "Save preview is not 16:9.");
            FrameworkElement action = Find(window, "StartNewCampaign");
            Point position = action.TranslatePoint(new Point(), right);
            Require(position.Y + action.ActualHeight <= right.ActualHeight && position.X >= 0 && position.X + action.ActualWidth <= right.ActualWidth, "Campaign button overflows its pane.");
            Require(Math.Abs(right.ActualHeight - position.Y - action.ActualHeight - 19) < 1, "Campaign button is not bottom-aligned.");

        }

        private static void Click(Window window, string id)
        {
            Console.WriteLine("Invoking " + id);
            PumpUntil(delegate {
                FrameworkElement action = Find(window, id);
                return action != null && action.IsEnabled;
            });
            Button button = Find(window, id) as Button;
            Require(button != null && button.IsEnabled, "Missing/disabled action: " + id);
            button.RaiseEvent(new RoutedEventArgs(Button.ClickEvent));
            Pump();
        }

        private static void Capture(Window window, string path)
        {
            DateTime settle = DateTime.UtcNow.AddMilliseconds(700);
            while (DateTime.UtcNow < settle) { Pump(); Thread.Sleep(10); }
            FrameworkElement visual = (FrameworkElement)window.Content;
            visual.UpdateLayout();
            var bitmap = new System.Windows.Media.Imaging.RenderTargetBitmap(
                (int)Math.Ceiling(visual.ActualWidth), (int)Math.Ceiling(visual.ActualHeight),
                96, 96, System.Windows.Media.PixelFormats.Pbgra32);
            bitmap.Render(visual);
            var encoder = new System.Windows.Media.Imaging.PngBitmapEncoder();
            encoder.Frames.Add(System.Windows.Media.Imaging.BitmapFrame.Create(bitmap));
            using (var file = File.Create(path)) encoder.Save(file);
            Console.WriteLine("Rendered " + path);
        }

        private static void Pump()
        {
            DispatcherFrame frame = new DispatcherFrame();
            Dispatcher.CurrentDispatcher.BeginInvoke(DispatcherPriority.ApplicationIdle,
                new Action(delegate { frame.Continue = false; }));
            Dispatcher.PushFrame(frame);
        }

        private static void PumpUntil(Func<bool> condition)
        {
            DateTime deadline = DateTime.UtcNow.AddSeconds(15);
            while (!condition()) {
                if (DateTime.UtcNow > deadline) throw new TimeoutException("UI/engine fixture timed out.");
                Pump();
                Thread.Sleep(20);
            }
        }
    }
}
