using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace BladeOfAgonyLauncher
{
    internal sealed class LauncherOptions
    {
        internal string BaseDirectory;
        internal int DetailPreset;
        internal bool DisplacementTextures;
        internal string Language;
        internal bool DeveloperCommentary;
        internal bool UseAddon;
        internal AddonDescriptor SingleAddon;
        internal List<AddonDescriptor> MultiAddons = new List<AddonDescriptor>();

        internal static LauncherOptions Load(string baseDirectory)
        {
            IniFile ini = IniFile.Load(Path.Combine(baseDirectory, "boa-launcher.ini"));
            LauncherOptions result = new LauncherOptions();
            result.BaseDirectory = baseDirectory;
            result.DetailPreset = 0;
            result.DisplacementTextures = ini.GetBoolean("Launcher", "DisplacementTextures", true);
            result.DeveloperCommentary = ini.GetBoolean("Launcher", "DevCommentary", false);
            result.UseAddon = ini.GetBoolean("Launcher", "LaunchWithAddon", false);

            string addonFile = ini.Get("Launcher", "addonFileName", string.Empty);
            if (addonFile.Length > 0) {
                string descriptorPath = Path.Combine(baseDirectory, addonFile);
                if (File.Exists(descriptorPath)) {
                    try {
                        result.SingleAddon = AddonDescriptor.Load(descriptorPath, System.Globalization.CultureInfo.CurrentUICulture);
                    } catch {
                        result.SingleAddon = null;
                    }
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
            if (SingleAddon != null && MultiAddons.Count == 0) {
                ini.Set("Launcher", "addonTitle", SingleAddon.Title);
                ini.Set("Launcher", "addonFileName", SingleAddon.FileName);
            } else {
                ini.Set("Launcher", "addonTitle", string.Empty);
                ini.Set("Launcher", "addonFileName", string.Empty);
            }
            ini.Save(path);
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
                    arguments.Add(options.SingleAddon.FileName);
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
