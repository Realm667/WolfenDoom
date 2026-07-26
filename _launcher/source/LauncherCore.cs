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
            result.Language = NormalizeLanguage(ini.Get("Launcher", "Language", "en"));

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
                            descriptorPath, System.Globalization.CultureInfo.CurrentUICulture));
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
