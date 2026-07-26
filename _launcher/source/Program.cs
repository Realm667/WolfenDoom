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
                    "  --scan-addons         Print discovered addon descriptors and exit.\n" +
                    "  --verify-preview      Verify 16:9 cover-crop geometry and exit.\n" +
                    "  --base-directory DIR Use a game directory other than the executable directory.\n" +
                    "  --detail VALUE        last, default, verylow, low, normal, high, veryhigh.\n" +
                    "  --displacement VALUE  on or off.\n" +
                    "  --language VALUE      en, de, es, ru, ptb/pt/br, it, tr/trk, fr, cs, pl/plk.\n" +
                    "  --commentary VALUE    on or off.\n" +
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
                foreach (AddonDescriptor addon in AddonDescriptor.Scan(baseDirectory, CultureInfo.CurrentUICulture)) {
                    Console.WriteLine(addon.RelativePath + "\t" + addon.Title + "\t" +
                        string.Join(";", addon.LoadFiles.ToArray()));
                }
                return 0;
            }

            if (HasArgument(args, "--print-command")) {
                LauncherOptions options = LauncherOptions.Load(baseDirectory);
                ApplyDiagnosticArguments(options, args, baseDirectory);
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
                } else if (TryReadValue(args, ref index, "--commentary", out value)) {
                    options.DeveloperCommentary = ParseToggle(value);
                } else if (string.Equals(args[index], "--no-addons", StringComparison.OrdinalIgnoreCase)) {
                    options.UseAddon = false;
                    options.SingleAddon = null;
                    options.MultiAddons.Clear();
                } else if (TryReadValue(args, ref index, "--addon", out value)) {
                    options.SingleAddon = AddonDescriptor.Load(ResolveDescriptor(baseDirectory, value), CultureInfo.CurrentUICulture);
                    options.UseAddon = true;
                } else if (TryReadValue(args, ref index, "--multi-addon", out value)) {
                    multi.Add(AddonDescriptor.Load(ResolveDescriptor(baseDirectory, value), CultureInfo.CurrentUICulture));
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

        private static string ResolveDescriptor(string baseDirectory, string value)
        {
            return Path.IsPathRooted(value) ? value : Path.Combine(baseDirectory, value);
        }
    }
}
