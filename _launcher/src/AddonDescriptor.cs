using System;
using System.Collections.Generic;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;

namespace BladeOfAgonyLauncher
{
    internal sealed class AddonDescriptor
    {
        internal string DescriptorPath;
        internal string FileName;
        internal string RelativePath;
        internal string Title;
        internal string Credits;
        internal string CreditsFull;
        internal string Description;
        internal string Requirements;
        internal string Id;
        internal string Version;
        internal string MinimumBoaVersion;
        internal string MinimumEngineVersion;
        internal List<string> RequiredAddons = new List<string>();
        internal List<string> ConflictingAddons = new List<string>();
        internal List<string> LoadAfter = new List<string>();
        internal bool MultiplayerSafe;
        internal bool NewCampaignRequired;
        internal string Category;
        internal string Iwad = "boa.ipk3";
        internal List<string> LoadFiles = new List<string>();
        internal List<string> PreviewImages = new List<string>();
        internal int PreviewImageCount;

        public override string ToString()
        {
            return Title;
        }

        internal static List<AddonDescriptor> Scan(string directory, string language)
        {
            List<AddonDescriptor> result = new List<AddonDescriptor>();
            string addonDirectory = Path.Combine(directory, "addons");
            if (!Directory.Exists(addonDirectory)) {
                return result;
            }
            foreach (string path in Directory.GetFiles(addonDirectory, "*.boa", SearchOption.TopDirectoryOnly)) {
                try {
                    result.Add(Load(path, language));
                } catch {
                    // A malformed descriptor should not prevent valid addons from being listed.
                }
            }
            result.Sort(delegate(AddonDescriptor left, AddonDescriptor right) {
                return string.Compare(left.Title, right.Title, StringComparison.CurrentCultureIgnoreCase);
            });
            return result;
        }

        internal static AddonDescriptor Load(string path, string language)
        {
            string normalized = LauncherOptions.NormalizeInterfaceLanguage(language);
            return descriptorCache.Get(path, normalized,
                delegate { return ReadDescriptor(path, normalized); });
        }

        private static readonly FileMemo<AddonDescriptor> descriptorCache =
            new FileMemo<AddonDescriptor>(128);

        private static AddonDescriptor ReadDescriptor(string path, string language)
        {
            if (!File.Exists(path)) {
                throw new FileNotFoundException("Addon descriptor not found.", path);
            }

            AddonDescriptor result = new AddonDescriptor();
            result.DescriptorPath = Path.GetFullPath(path);
            result.FileName = Path.GetFileName(path);
            result.RelativePath = "addons/" + result.FileName;

            using (ZipArchive archive = ZipFile.OpenRead(path)) {
                string addonInfo = ReadTextEntry(archive, "addoninfo.txt");
                string gameInfo = ReadTextEntry(archive, "gameinfo.txt");
                Dictionary<string, string> metadata = ParseKeyValues(addonInfo);
                language = LauncherOptions.NormalizeInterfaceLanguage(language);

                result.Title = Localized(metadata, "title", language, Path.GetFileNameWithoutExtension(path));
                result.Credits = Localized(metadata, "credits", language, string.Empty);
                result.CreditsFull = Unescape(Localized(metadata, "creditsFull", language, result.Credits));
                result.Description = Unescape(Localized(metadata, "description", language, string.Empty));
                result.Requirements = Unescape(Localized(metadata, "requirements", language, string.Empty));
                result.Id = GetValue(metadata, "id", Path.GetFileNameWithoutExtension(path));
                result.Version = GetValue(metadata, "version", string.Empty);
                result.MinimumBoaVersion = GetValue(metadata, "minBoAVersion", string.Empty);
                result.MinimumEngineVersion = GetValue(metadata, "minEngineVersion", string.Empty);
                result.RequiredAddons.AddRange(ParseList(GetValue(metadata, "requires", string.Empty)));
                result.ConflictingAddons.AddRange(ParseList(GetValue(metadata, "conflicts", string.Empty)));
                result.LoadAfter.AddRange(ParseList(GetValue(metadata, "loadAfter", string.Empty)));
                result.MultiplayerSafe = ParseBoolean(
                    GetValue(metadata, "multiplayerSafe", "false"));
                result.NewCampaignRequired = ParseBoolean(
                    GetValue(metadata, "newCampaignRequired", "false"));
                result.Category = GetValue(metadata, "category", string.Empty);

                int previewCount;
                if (int.TryParse(GetValue(metadata, "previewImages", "0"), out previewCount)) {
                    result.PreviewImageCount = Math.Max(0, previewCount);
                }
                DiscoverPreviewImages(archive, result);
                if (result.PreviewImages.Count > 0) {
                    result.PreviewImageCount = result.PreviewImages.Count;
                }
                ParseGameInfo(gameInfo, result);
            }
            return result;
        }

        internal Image LoadIcon()
        {
            return LoadImageEntry("preview/icon.png");
        }

        internal Image LoadPreview(int oneBasedIndex)
        {
            if (oneBasedIndex < 1) {
                return null;
            }
            if (oneBasedIndex <= PreviewImages.Count) {
                return LoadImageEntry(PreviewImages[oneBasedIndex - 1]);
            }
            return LoadImageEntry("preview/" + oneBasedIndex.ToString(CultureInfo.InvariantCulture) + ".jpg");
        }

        private static void DiscoverPreviewImages(
            ZipArchive archive, AddonDescriptor addon)
        {
            foreach (ZipArchiveEntry entry in archive.Entries) {
                string name = entry.FullName.Replace('\\', '/');
                if (Regex.IsMatch(
                        name,
                        "^preview/[0-9]+\\.(?:jpg|jpeg|png)$",
                        RegexOptions.IgnoreCase)) {
                    addon.PreviewImages.Add(name);
                }
            }
            addon.PreviewImages.Sort(delegate(string left, string right) {
                int leftNumber = PreviewNumber(left);
                int rightNumber = PreviewNumber(right);
                int byNumber = leftNumber.CompareTo(rightNumber);
                return byNumber != 0
                    ? byNumber
                    : string.Compare(
                        left, right, StringComparison.OrdinalIgnoreCase);
            });
        }

        private static int PreviewNumber(string path)
        {
            Match match = Regex.Match(path, "[0-9]+");
            int number;
            return match.Success &&
                int.TryParse(
                    match.Value, NumberStyles.None,
                    CultureInfo.InvariantCulture, out number)
                ? number
                : int.MaxValue;
        }

        private Image LoadImageEntry(string name)
        {
            using (ZipArchive archive = ZipFile.OpenRead(DescriptorPath)) {
                ZipArchiveEntry entry = FindEntry(archive, name);
                if (entry == null) {
                    return null;
                }
                using (Stream stream = entry.Open())
                using (Image source = Image.FromStream(stream)) {
                    return new Bitmap(source);
                }
            }
        }

        private static string ReadTextEntry(ZipArchive archive, string name)
        {
            ZipArchiveEntry entry = FindEntry(archive, name);
            if (entry == null) {
                throw new InvalidDataException("Required entry is missing: " + name);
            }
            using (Stream stream = entry.Open())
            using (StreamReader reader = new StreamReader(stream, Encoding.UTF8, true)) {
                return reader.ReadToEnd();
            }
        }

        private static ZipArchiveEntry FindEntry(ZipArchive archive, string name)
        {
            foreach (ZipArchiveEntry entry in archive.Entries) {
                if (string.Equals(entry.FullName.Replace('\\', '/'), name, StringComparison.OrdinalIgnoreCase)) {
                    return entry;
                }
            }
            return null;
        }

        private static Dictionary<string, string> ParseKeyValues(string text)
        {
            Dictionary<string, string> result = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            using (StringReader reader = new StringReader(text)) {
                string line;
                while ((line = reader.ReadLine()) != null) {
                    string trimmed = line.Trim();
                    if (trimmed.Length == 0 || trimmed.StartsWith("//") || trimmed.StartsWith("#")) {
                        continue;
                    }
                    int separator = trimmed.IndexOf('=');
                    if (separator <= 0) {
                        continue;
                    }
                    string key = trimmed.Substring(0, separator).Trim();
                    string value = trimmed.Substring(separator + 1).Trim();
                    result[key] = TrimQuotes(RemoveInlineComment(value));
                }
            }
            return result;
        }

        private static void ParseGameInfo(string text, AddonDescriptor addon)
        {
            using (StringReader reader = new StringReader(text)) {
                string line;
                while ((line = reader.ReadLine()) != null) {
                    string trimmed = line.Trim();
                    if (trimmed.Length == 0 || trimmed.StartsWith("//")) {
                        continue;
                    }
                    Match match = Regex.Match(trimmed, "^(IWAD|LOAD)\\s*=\\s*\"([^\"]+)\"", RegexOptions.IgnoreCase);
                    if (!match.Success) {
                        continue;
                    }
                    string key = match.Groups[1].Value;
                    string value = NormalizeSafeRelativePath(match.Groups[2].Value);
                    if (key.Equals("IWAD", StringComparison.OrdinalIgnoreCase)) {
                        addon.Iwad = value;
                    } else {
                        addon.LoadFiles.Add(value);
                    }
                }
            }
        }

        private static string NormalizeSafeRelativePath(string value)
        {
            string normalized = value.Trim().Replace('\\', '/');
            if (normalized.Length == 0 || Path.IsPathRooted(normalized)) {
                throw new InvalidDataException("Addon contains an invalid absolute or empty path.");
            }
            string[] parts = normalized.Split('/');
            foreach (string part in parts) {
                if (part == ".." || part == ".") {
                    throw new InvalidDataException("Addon contains an unsafe relative path.");
                }
            }
            return normalized;
        }

        private static string Localized(
            Dictionary<string, string> values, string key, string language, string fallback)
        {
            string localized;
            if (language.Length > 0 && values.TryGetValue(key + "_" + language, out localized)) {
                return localized;
            }
            string alias = null;
            if (language == "ptb") {
                alias = "pt";
            } else if (language == "tr") {
                alias = "trk";
            } else if (language == "pl") {
                alias = "plk";
            }
            if (alias != null && values.TryGetValue(key + "_" + alias, out localized)) {
                return localized;
            }
            return GetValue(values, key, fallback);
        }

        private static string GetValue(Dictionary<string, string> values, string key, string fallback)
        {
            string value;
            return values.TryGetValue(key, out value) ? value : fallback;
        }

        private static string RemoveInlineComment(string value)
        {
            bool quoted = false;
            for (int index = 0; index + 1 < value.Length; index++) {
                if (value[index] == '"') {
                    quoted = !quoted;
                }
                if (!quoted && value[index] == '/' && value[index + 1] == '/') {
                    return value.Substring(0, index).Trim();
                }
            }
            return value;
        }

        private static string TrimQuotes(string value)
        {
            if (value.Length >= 2 && value[0] == '"' && value[value.Length - 1] == '"') {
                return value.Substring(1, value.Length - 2);
            }
            return value;
        }

        private static string Unescape(string value)
        {
            return value.Replace("\\n", Environment.NewLine).Replace("\\t", "\t");
        }

        private static List<string> ParseList(string value)
        {
            List<string> result = new List<string>();
            foreach (string item in value.Split(new[] { ',', ';' },
                    StringSplitOptions.RemoveEmptyEntries)) {
                string normalized = item.Trim();
                if (normalized.Length > 0) {
                    result.Add(normalized);
                }
            }
            return result;
        }

        private static bool ParseBoolean(string value)
        {
            string normalized = value == null ? string.Empty : value.Trim().ToLowerInvariant();
            return normalized == "1" || normalized == "true" ||
                normalized == "yes" || normalized == "on";
        }
    }
}
