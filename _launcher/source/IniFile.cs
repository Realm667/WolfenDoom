using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace BladeOfAgonyLauncher
{
    internal sealed class IniFile
    {
        private readonly List<string> lines = new List<string>();

        internal static IniFile Load(string path)
        {
            IniFile result = new IniFile();
            if (File.Exists(path)) {
                result.lines.AddRange(File.ReadAllLines(path, Encoding.UTF8));
            }
            return result;
        }

        internal string Get(string section, string key, string fallback)
        {
            string currentSection = string.Empty;
            foreach (string line in lines) {
                string trimmed = line.Trim();
                if (trimmed.StartsWith("[") && trimmed.EndsWith("]")) {
                    currentSection = trimmed.Substring(1, trimmed.Length - 2).Trim();
                    continue;
                }
                if (!string.Equals(currentSection, section, StringComparison.OrdinalIgnoreCase)) {
                    continue;
                }
                int separator = line.IndexOf('=');
                if (separator < 0) {
                    continue;
                }
                string candidate = line.Substring(0, separator).Trim();
                if (string.Equals(candidate, key, StringComparison.OrdinalIgnoreCase)) {
                    return line.Substring(separator + 1).Trim();
                }
            }
            return fallback;
        }

        internal bool GetBoolean(string section, string key, bool fallback)
        {
            string value = Get(section, key, fallback ? "1" : "0");
            return value == "1" || value.Equals("true", StringComparison.OrdinalIgnoreCase) ||
                   value.Equals("yes", StringComparison.OrdinalIgnoreCase);
        }

        internal void Set(string section, string key, string value)
        {
            string currentSection = string.Empty;
            int sectionLine = -1;
            int insertLine = lines.Count;

            for (int index = 0; index < lines.Count; index++) {
                string trimmed = lines[index].Trim();
                if (trimmed.StartsWith("[") && trimmed.EndsWith("]")) {
                    string nextSection = trimmed.Substring(1, trimmed.Length - 2).Trim();
                    if (sectionLine >= 0) {
                        insertLine = index;
                        break;
                    }
                    currentSection = nextSection;
                    if (string.Equals(currentSection, section, StringComparison.OrdinalIgnoreCase)) {
                        sectionLine = index;
                    }
                    continue;
                }
                if (sectionLine < 0) {
                    continue;
                }
                int separator = lines[index].IndexOf('=');
                if (separator >= 0 && string.Equals(
                        lines[index].Substring(0, separator).Trim(), key, StringComparison.OrdinalIgnoreCase)) {
                    lines[index] = key + "=" + value;
                    return;
                }
            }

            if (sectionLine < 0) {
                if (lines.Count > 0 && lines[lines.Count - 1].Length > 0) {
                    lines.Add(string.Empty);
                }
                lines.Add("[" + section + "]");
                lines.Add(key + "=" + value);
            } else {
                lines.Insert(insertLine, key + "=" + value);
            }
        }

        internal void Save(string path)
        {
            string temporary = path + ".tmp";
            File.WriteAllLines(temporary, lines.ToArray(), new UTF8Encoding(false));
            File.Copy(temporary, path, true);
            File.Delete(temporary);
        }
    }
}
