using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;
using System.Windows.Forms;

namespace BladeOfAgonyLauncher
{
    internal static class Program
    {
        [STAThread]
        private static int Main(string[] args)
        {
            string baseDirectory = ReadBaseDirectory(args);

            if (HasArgument(args, "--help")) {
                Console.WriteLine(
                    "Blade of Agony Launcher (clean-room rebuild)\n" +
                    "  --print-command       Print the generated boa.exe command and exit.\n" +
                    "  --print-ui            Print localized UI labels and exit.\n" +
                    "  --scan-addons         Print discovered addon descriptors and exit.\n" +
                    "  --verify-preview      Verify 16:9 cover-crop geometry and exit.\n" +
                    "  --base-directory DIR Use a game directory other than the executable directory.\n" +
                    "  --detail VALUE        last, default, verylow, low, normal, high, veryhigh.\n" +
                    "  --displacement VALUE  on or off.\n" +
                    "  --language VALUE      en, de, es, ru, ptb/pt/br, it, tr/trk, fr, cs, pl/plk.\n" +
                    "  --theme VALUE         dark, light, or boa.\n" +
                    "  --commentary VALUE    on or off.\n" +
                    "  --multiplayer MODE    single, host, or join.\n" +
                    "  --players VALUE       Total host player count (2-8).\n" +
                    "  --map VALUE           Host start map, for example C1M1.\n" +
                    "  --host VALUE          Host name or IPv4 address to join.\n" +
                    "  --port VALUE          UDP port (default 5029).\n" +
                    "  --skill VALUE         Host skill level (1-5).\n" +
                    "  --cheats VALUE        Host sv_cheats setting, on or off.\n" +
                    "  --no-addons           Disable all persisted addon selections.\n" +
                    "  --addon FILE          Select one .boa descriptor.\n" +
                    "  --multi-addon FILE    Add a .boa descriptor to the multi-addon load order.");
                return 0;
            }

            if (HasArgument(args, "--verify-preview")) {
                if (!PreviewLayout.SelfTest()) {
                    throw new InvalidOperationException("The 16:9 cover-crop geometry test failed.");
                }
                Console.WriteLine("Preview 16:9 cover-crop tests: PASS");
                return 0;
            }

            if (HasArgument(args, "--scan-addons")) {
                LauncherOptions scanOptions = LauncherOptions.Load(baseDirectory);
                ApplyDiagnosticArguments(scanOptions, args, baseDirectory);
                foreach (AddonDescriptor addon in AddonDescriptor.Scan(baseDirectory, scanOptions.Language)) {
                    Console.WriteLine(addon.RelativePath + "\t" + addon.Title + "\t" +
                        string.Join(";", addon.LoadFiles.ToArray()));
                }
                return 0;
            }

            if (HasArgument(args, "--print-command") || HasArgument(args, "--print-ui")) {
                LauncherOptions options = LauncherOptions.Load(baseDirectory);
                ApplyDiagnosticArguments(options, args, baseDirectory);
                if (HasArgument(args, "--print-ui")) {
                    PoCatalog catalog = PoCatalog.Load(baseDirectory, options.Language);
                    Console.WriteLine("Language=" + options.Language);
                    Console.WriteLine("Theme=" + options.Theme);
                    Console.WriteLine("Play=" + catalog.Get("Play"));
                    Console.WriteLine("NoAddons=" + catalog.Get("No addons"));
                    Console.WriteLine("Multiplayer=" + catalog.Get("Multiplayer"));
                    Console.WriteLine("HostCoop=" + catalog.Get("Host co-op"));
                    Console.WriteLine("Dark=" + catalog.Get("Dark"));
                    Console.WriteLine("Light=" + catalog.Get("Light"));
                    return 0;
                }
                Console.WriteLine(LauncherCommand.BuildDisplayCommand(options));
                return 0;
            }

            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new MainForm(baseDirectory));
            return 0;
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

        private static string ReadBaseDirectory(string[] args)
        {
            for (int index = 0; index + 1 < args.Length; index++) {
                if (string.Equals(args[index], "--base-directory", StringComparison.OrdinalIgnoreCase)) {
                    return Path.GetFullPath(args[index + 1]);
                }
            }
            return AppDomain.CurrentDomain.BaseDirectory;
        }

        private static void ApplyDiagnosticArguments(LauncherOptions options, string[] args, string baseDirectory)
        {
            List<AddonDescriptor> multi = new List<AddonDescriptor>();
            for (int index = 0; index < args.Length; index++) {
                string value;
                if (TryReadValue(args, ref index, "--detail", out value)) {
                    options.DetailPreset = LauncherOptions.ParseDetail(value);
                } else if (TryReadValue(args, ref index, "--displacement", out value)) {
                    options.DisplacementTextures = ParseToggle(value);
                } else if (TryReadValue(args, ref index, "--language", out value)) {
                    options.Language = string.Equals(value, "last", StringComparison.OrdinalIgnoreCase)
                        ? null
                        : LauncherOptions.NormalizeLanguage(value);
                } else if (TryReadValue(args, ref index, "--theme", out value)) {
                    options.Theme = LauncherOptions.ParseTheme(value);
                } else if (TryReadValue(args, ref index, "--commentary", out value)) {
                    options.DeveloperCommentary = ParseToggle(value);
                } else if (TryReadValue(args, ref index, "--multiplayer", out value)) {
                    options.NetworkMode = LauncherOptions.ParseMultiplayerMode(value);
                } else if (TryReadValue(args, ref index, "--players", out value)) {
                    options.MultiplayerPlayers = ParseInteger(value, "--players");
                } else if (TryReadValue(args, ref index, "--map", out value)) {
                    options.MultiplayerStartMap = LauncherOptions.NormalizeMapName(value);
                } else if (TryReadValue(args, ref index, "--host", out value)) {
                    options.MultiplayerHost = LauncherOptions.NormalizeHost(value);
                } else if (TryReadValue(args, ref index, "--port", out value)) {
                    options.MultiplayerPort = ParseInteger(value, "--port");
                } else if (TryReadValue(args, ref index, "--skill", out value)) {
                    options.MultiplayerSkill = ParseInteger(value, "--skill");
                } else if (TryReadValue(args, ref index, "--cheats", out value)) {
                    options.MultiplayerCheats = ParseToggle(value);
                } else if (string.Equals(args[index], "--no-addons", StringComparison.OrdinalIgnoreCase)) {
                    options.UseAddon = false;
                    options.SingleAddon = null;
                    options.MultiAddons.Clear();
                } else if (TryReadValue(args, ref index, "--addon", out value)) {
                    options.SingleAddon = AddonDescriptor.Load(
                        ResolveDescriptor(baseDirectory, value), options.Language);
                    options.MultiAddons.Clear();
                    options.UseAddon = true;
                } else if (TryReadValue(args, ref index, "--multi-addon", out value)) {
                    multi.Add(AddonDescriptor.Load(
                        ResolveDescriptor(baseDirectory, value), options.Language));
                }
            }
            if (multi.Count > 0) {
                options.MultiAddons = multi;
                options.SingleAddon = null;
                options.UseAddon = true;
            }
        }

        private static bool TryReadValue(string[] args, ref int index, string name, out string value)
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
            if (!int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out result)) {
                throw new ArgumentException("Invalid integer for " + name + ": " + value);
            }
            return result;
        }

        private static string ResolveDescriptor(string baseDirectory, string value)
        {
            return Path.IsPathRooted(value) ? value : Path.Combine(baseDirectory, value);
        }
    }
}
