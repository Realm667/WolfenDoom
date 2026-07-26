using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Text;

namespace BladeOfAgonyLauncher
{
    internal sealed class PoCatalog
    {
        private readonly Dictionary<string, string> translations =
            new Dictionary<string, string>(StringComparer.Ordinal);

        internal static PoCatalog Load(string baseDirectory, CultureInfo culture)
        {
            PoCatalog result = new PoCatalog();
            string language = culture == null ? string.Empty : culture.TwoLetterISOLanguageName;
            if (language.Length == 0 || language.Equals("en", StringComparison.OrdinalIgnoreCase)) {
                return result;
            }

            string directory = Path.Combine(baseDirectory, "language");
            if (!Directory.Exists(directory)) {
                return result;
            }
            string[] candidates = Directory.GetFiles(directory, "*." + language + ".po", SearchOption.TopDirectoryOnly);
            if (candidates.Length > 0) {
                result.Parse(candidates[0]);
            }
            return result;
        }

        internal string Get(string english)
        {
            string translated;
            return translations.TryGetValue(english, out translated) && translated.Length > 0
                ? translated
                : english;
        }

        private void Parse(string path)
        {
            string currentId = null;
            string currentValue = null;
            string active = null;

            foreach (string rawLine in File.ReadAllLines(path, Encoding.UTF8)) {
                string line = rawLine.Trim();
                if (line.StartsWith("msgid ")) {
                    Store(currentId, currentValue);
                    currentId = DecodeQuoted(line.Substring(6));
                    currentValue = null;
                    active = "id";
                } else if (line.StartsWith("msgstr ")) {
                    currentValue = DecodeQuoted(line.Substring(7));
                    active = "value";
                } else if (line.StartsWith("\"")) {
                    if (active == "id") {
                        currentId = (currentId ?? string.Empty) + DecodeQuoted(line);
                    } else if (active == "value") {
                        currentValue = (currentValue ?? string.Empty) + DecodeQuoted(line);
                    }
                } else if (line.Length == 0) {
                    Store(currentId, currentValue);
                    currentId = null;
                    currentValue = null;
                    active = null;
                }
            }
            Store(currentId, currentValue);
        }

        private void Store(string id, string value)
        {
            if (!string.IsNullOrEmpty(id) && value != null) {
                translations[id] = value;
            }
        }

        private static string DecodeQuoted(string value)
        {
            string trimmed = value.Trim();
            if (trimmed.Length >= 2 && trimmed[0] == '"' && trimmed[trimmed.Length - 1] == '"') {
                trimmed = trimmed.Substring(1, trimmed.Length - 2);
            }
            StringBuilder result = new StringBuilder();
            bool escaped = false;
            foreach (char current in trimmed) {
                if (escaped) {
                    if (current == 'n') {
                        result.Append('\n');
                    } else if (current == 'r') {
                        result.Append('\r');
                    } else if (current == 't') {
                        result.Append('\t');
                    } else {
                        result.Append(current);
                    }
                    escaped = false;
                } else if (current == '\\') {
                    escaped = true;
                } else {
                    result.Append(current);
                }
            }
            if (escaped) {
                result.Append('\\');
            }
            return result.ToString();
        }
    }
}
