using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Text.RegularExpressions;

namespace BladeOfAgonyLauncher
{
    // Resolve a single enclosing source-archive folder, never a recursive
    // basename search (which could select an add-on's metadata).
    internal static class GameArchive
    {
        internal static ZipArchiveEntry FindEntry(ZipArchive archive, string entryName)
        {
            ZipArchiveEntry direct = FindExact(archive, entryName);
            if (direct != null) return direct;
            string prefix = null;
            foreach (ZipArchiveEntry entry in archive.Entries) {
                string name = entry.FullName.Replace('\\', '/');
                if (name.EndsWith("/", StringComparison.Ordinal)) continue;
                int slash = name.IndexOf('/');
                if (slash <= 0) return null;
                string folder = name.Substring(0, slash + 1);
                if (prefix == null) prefix = folder;
                else if (!string.Equals(prefix, folder, StringComparison.OrdinalIgnoreCase)) return null;
            }
            if (prefix == null) return null;
            string reserved = "|acs|colormaps|filter|flats|graphics|hires|maps|music|patches|sounds|sprites|textures|voices|voxels|addons|_addons|";
            if (reserved.Contains("|" + prefix.TrimEnd('/').ToLowerInvariant() + "|")) return null;
            // Require game definitions at the proposed root, not just a README.
            if (FindExact(archive, prefix + "mapinfo.txt") == null &&
                FindExact(archive, prefix + "MAPINFO") == null &&
                FindExact(archive, prefix + "gameinfo.txt") == null &&
                FindExact(archive, prefix + "GAMEINFO") == null) return null;
            return FindExact(archive, prefix + entryName);
        }

        private static ZipArchiveEntry FindExact(ZipArchive archive, string name)
        {
            ZipArchiveEntry found = null;
            foreach (ZipArchiveEntry entry in archive.Entries) {
                if (!string.Equals(entry.FullName.Replace('\\', '/'), name,
                        StringComparison.OrdinalIgnoreCase)) continue;
                if (found != null) throw new InvalidDataException("Ambiguous game metadata: " + name);
                found = entry;
            }
            return found;
        }
    }

    internal sealed class BoaEpisode
    {
        internal string Id;
        internal string StartMap;
        internal string NameKey;
        internal string DisplayName;
        internal List<BoaMap> Maps = new List<BoaMap>();

        public override string ToString()
        {
            return DisplayName;
        }
    }

    internal sealed class BoaMap
    {
        internal string Id;
        internal string NameKey;
        internal string DisplayName;

        public override string ToString()
        {
            return DisplayName + "  [" + Id + "]";
        }
    }

    internal sealed class BoaSkill
    {
        internal int Number;
        internal string Id;
        internal string NameKey;
        internal string DisplayName;

        public override string ToString()
        {
            return Number.ToString(System.Globalization.CultureInfo.InvariantCulture) +
                ". " + DisplayName;
        }
    }

    internal sealed class BoaContentCatalog
    {
        internal List<BoaEpisode> Episodes = new List<BoaEpisode>();
        internal List<BoaSkill> Skills = new List<BoaSkill>();
        internal List<BoaMap> KeenMaps = new List<BoaMap>();
        internal bool HasCheckpointMode;
        internal bool HasLevelRestart;
        internal string RestartLabel;
        internal static bool SupportsLevelRestart(string baseDirectory)
        {
            string source;
            string defs = ReadGameEntry(baseDirectory, "mapinfo/boarestartskills.txt", out source);
            if (defs == null) return false;
            for (int i = 1; i <= 5; i++)
                if (!Regex.IsMatch(defs, @"(?im)^skill\s+BoARestart" + i + @"\s*\{")) return false;
            return true;
        }
        internal string DeathModeTitle, ClassicLabel, CheckpointLabel;

        internal static bool SupportsCheckpoints(string baseDirectory)
        {
            string source;
            string definitions = ReadGameEntry(baseDirectory, "mapinfo/boacpskills.txt", out source);
            if (definitions == null) return false;
            for (int i = 1; i <= 5; i++) {
                if (!Regex.IsMatch(definitions, @"(?im)^skill\s+BoACheckpoint" + i + @"\s*\{")) return false;
            }
            return true;
        }
        internal string SourceDescription;
        internal string Error;

        internal static BoaContentCatalog Load(string baseDirectory, string language)
        {
            BoaContentCatalog result = new BoaContentCatalog();
            try {
                string source;
                string mapInfo = ReadGameEntry(baseDirectory, "mapinfo.txt", out source);
                if (mapInfo == null) {
                    mapInfo = ReadGameEntry(baseDirectory, "MAPINFO", out source);
                }
                if (mapInfo == null) {
                    throw new FileNotFoundException(
                        "MAPINFO was not found in boa.ipk3 or next to the launcher.");
                }

                string languageSource;
                string languageCsv = ReadGameEntry(
                    baseDirectory, "language.csv", out languageSource);
                Dictionary<string, string> translations = ParseLanguageCsv(
                    languageCsv, ResolveContentLanguage(baseDirectory, language));

                result.ParseMapInfo(mapInfo, translations);
                result.HasCheckpointMode = SupportsCheckpoints(baseDirectory);
                result.HasLevelRestart = SupportsLevelRestart(baseDirectory);
                result.RestartLabel = Translate(translations, "BOA_DEATHRESTART", "Restart the current level");
                result.DeathModeTitle = Translate(translations, "BOA_DEATHMODE", "When you die");
                result.ClassicLabel = Translate(translations, "BOA_DEATHCLASSIC", "Reload the last save");
                result.CheckpointLabel = Translate(translations, "BOA_DEATHCHECKPOINT", "Respawn at a checkpoint");
                result.SourceDescription = source;
                if (result.Episodes.Count == 0 || result.Skills.Count == 0) {
                    throw new InvalidDataException(
                        "MAPINFO did not contain campaign chapters and skills.");
                }
            } catch (Exception exception) {
                result.Error = exception.Message;
                result.AddFallback();
            }
            return result;
        }

        internal static string ResolveContentLanguage(string baseDirectory, string language)
        {
            string selected = LauncherOptions.NormalizeGameLanguage(language);
            if (selected == "last") {
                // Preview only. Never turn this into a command-line override:
                // the engine must retain its own configuration/autoexec choice.
                string path = UZDoomConfiguration.FindExisting(baseDirectory);
                try {
                    selected = string.IsNullOrEmpty(path) ? "auto" :
                        IniFile.Load(path).Get("GlobalSettings", "language", "auto");
                } catch (IOException) { selected = "auto"; }
                  catch (UnauthorizedAccessException) { selected = "auto"; }
            }
            if (selected.Equals("auto", StringComparison.OrdinalIgnoreCase) ||
                    selected.Equals("last", StringComparison.OrdinalIgnoreCase)) {
                selected = System.Globalization.CultureInfo.CurrentUICulture.Name;
                if (!selected.StartsWith("en-", StringComparison.OrdinalIgnoreCase) &&
                        !selected.StartsWith("pt-", StringComparison.OrdinalIgnoreCase)) {
                    selected = System.Globalization.CultureInfo.CurrentUICulture.TwoLetterISOLanguageName;
                }
            }
            return LauncherOptions.NormalizeGameLanguage(selected);
        }

        private void ParseMapInfo(
            string text, Dictionary<string, string> translations)
        {
            Dictionary<string, BoaMap> maps =
                new Dictionary<string, BoaMap>(StringComparer.OrdinalIgnoreCase);
            MatchCollection mapMatches = Regex.Matches(
                text,
                "(?im)^\\s*map\\s+([A-Za-z0-9_]+)(?:\\s+lookup\\s+\"([^\"]+)\")?");
            foreach (Match match in mapMatches) {
                string id = match.Groups[1].Value.ToUpperInvariant();
                if (!IsCampaignMap(id) && !IsKeenMap(id)) {
                    continue;
                }
                string key = match.Groups[2].Success
                    ? match.Groups[2].Value
                    : id;
                BoaMap map = new BoaMap();
                map.Id = id;
                map.NameKey = key;
                map.DisplayName = Translate(translations, key, id);
                if (IsKeenMap(id)) KeenMaps.Add(map);
                else maps[id] = map;
            }

            MatchCollection episodeMatches = Regex.Matches(
                text,
                "(?ims)^\\s*episode\\s+([A-Za-z0-9_]+).*?\\{(.*?)^\\s*\\}");
            foreach (Match match in episodeMatches) {
                string startMap = match.Groups[1].Value.ToUpperInvariant();
                Match nameMatch = Regex.Match(
                    match.Groups[2].Value,
                    "(?im)^\\s*name\\s*=\\s*\"?\\$?([^\"\\s/]+)");
                string key = nameMatch.Success
                    ? nameMatch.Groups[1].Value
                    : startMap;
                BoaEpisode episode = new BoaEpisode();
                episode.Id = "episode-" + (Episodes.Count + 1).ToString(
                    System.Globalization.CultureInfo.InvariantCulture);
                episode.StartMap = startMap;
                episode.NameKey = key;
                episode.DisplayName = Translate(
                    translations, key, "Chapter " + (Episodes.Count + 1));
                foreach (BoaMap map in maps.Values) {
                    if (BelongsToEpisode(map.Id, startMap, Episodes.Count + 1)) {
                        episode.Maps.Add(map);
                    }
                }
                episode.Maps.Sort(CompareMaps);
                if (episode.Maps.Count == 0) {
                    BoaMap start;
                    if (maps.TryGetValue(startMap, out start)) {
                        episode.Maps.Add(start);
                    }
                }
                Episodes.Add(episode);
            }

            MatchCollection skillMatches = Regex.Matches(
                text,
                "(?ims)^\\s*skill\\s+([A-Za-z0-9_]+).*?\\{(.*?)^\\s*\\}");
            foreach (Match match in skillMatches) {
                Match keyMatch = Regex.Match(
                    match.Groups[2].Value,
                    "(?im)^\\s*key\\s*=\\s*([1-9][0-9]*)");
                Match nameMatch = Regex.Match(
                    match.Groups[2].Value,
                    "(?im)^\\s*name\\s*=\\s*\"?\\$?([^\"\\s/]+)");
                int number;
                if (!keyMatch.Success || !int.TryParse(
                        keyMatch.Groups[1].Value, out number)) {
                    number = Skills.Count + 1;
                }
                string key = nameMatch.Success
                    ? nameMatch.Groups[1].Value
                    : match.Groups[1].Value;
                BoaSkill skill = new BoaSkill();
                skill.Number = number;
                skill.Id = match.Groups[1].Value;
                skill.NameKey = key;
                skill.DisplayName = Translate(
                    translations, key, match.Groups[1].Value);
                Skills.Add(skill);
            }
            Skills.Sort(delegate(BoaSkill left, BoaSkill right) {
                return left.Number.CompareTo(right.Number);
            });
        }

        private static string ReadGameEntry(
            string baseDirectory, string entryName, out string source)
        {
            string developmentFile = Path.Combine(baseDirectory, entryName);
            if (File.Exists(developmentFile)) {
                source = developmentFile;
                return textCache.Get(developmentFile, string.Empty,
                    delegate { return File.ReadAllText(developmentFile, Encoding.UTF8); });
            }

            List<string> archives = new List<string>();
            string expected = Path.Combine(baseDirectory, "boa.ipk3");
            if (File.Exists(expected)) {
                archives.Add(expected);
            }
            if (Directory.Exists(baseDirectory)) {
                foreach (string archive in Directory.GetFiles(
                        baseDirectory, "*.ipk3", SearchOption.TopDirectoryOnly)) {
                    if (!archives.Contains(archive)) {
                        archives.Add(archive);
                    }
                }
            }
            foreach (string archivePath in archives) {
                try {
                    string currentArchive = archivePath;
                    string entrySource = null;
                    string value = textCache.Get(currentArchive, entryName, delegate {
                    using (ZipArchive archive = ZipFile.OpenRead(currentArchive)) {
                        ZipArchiveEntry entry = GameArchive.FindEntry(archive, entryName);
                        if (entry != null) {
                            using (Stream stream = entry.Open())
                            using (StreamReader reader = new StreamReader(
                                    stream, Encoding.UTF8, true)) {
                                entrySource = Path.GetFileName(currentArchive) + "/" + entry.FullName;
                                return reader.ReadToEnd();
                            }
                        }
                    }
                    return null;
                    });
                    if (value != null) {
                        source = entrySource ?? Path.GetFileName(currentArchive) + "/" + entryName;
                        return value;
                    }
                } catch (InvalidDataException) {
                    // Try another game archive if this one is incomplete.
                }
            }
            source = string.Empty;
            return null;
        }

        private static readonly FileMemo<string> textCache = new FileMemo<string>(24);

        private static Dictionary<string, string> ParseLanguageCsv(
            string csv, string language)
        {
            Dictionary<string, string> result =
                new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            if (string.IsNullOrEmpty(csv)) {
                return result;
            }
            using (StringReader reader = new StringReader(csv)) {
                string headerLine = reader.ReadLine();
                if (headerLine == null) {
                    return result;
                }
                List<string> headers = ParseCsvLine(headerLine);
                int column = FindLanguageColumn(headers, language);
                string line;
                while ((line = reader.ReadLine()) != null) {
                    List<string> cells = ParseCsvLine(line);
                    if (cells.Count <= column || cells.Count == 0) {
                        continue;
                    }
                    string key = cells[0].Trim();
                    string value = cells[column].Trim();
                    if (key.Length > 0 && value.Length > 0) {
                        result[key] = value;
                    }
                }
            }
            return result;
        }

        private static int FindLanguageColumn(List<string> headers, string language)
        {
            string wanted = language.StartsWith(
                "en-", StringComparison.OrdinalIgnoreCase)
                ? "default"
                : language == "pt-PT" ? "pt" : language.ToLowerInvariant();
            for (int index = 0; index < headers.Count; index++) {
                string[] aliases = headers[index].ToLowerInvariant().Split(
                    new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (string alias in aliases) {
                    if (alias == wanted) {
                        return index;
                    }
                }
            }
            return Math.Min(3, Math.Max(0, headers.Count - 1));
        }

        private static List<string> ParseCsvLine(string line)
        {
            List<string> result = new List<string>();
            StringBuilder cell = new StringBuilder();
            bool quoted = false;
            for (int index = 0; index < line.Length; index++) {
                char current = line[index];
                if (current == '"') {
                    if (quoted && index + 1 < line.Length && line[index + 1] == '"') {
                        cell.Append('"');
                        index++;
                    } else {
                        quoted = !quoted;
                    }
                } else if (current == ',' && !quoted) {
                    result.Add(cell.ToString());
                    cell.Length = 0;
                } else {
                    cell.Append(current);
                }
            }
            result.Add(cell.ToString());
            return result;
        }

        private static string Translate(
            Dictionary<string, string> translations, string key, string fallback)
        {
            string value;
            return translations.TryGetValue(key.TrimStart('$'), out value) &&
                value.Length > 0 ? value : fallback;
        }

        internal static bool IsKeenMap(string id)
        {
            return id == "SM01" || id == "SM02" || id == "SM03";
        }

        private static bool IsCampaignMap(string id)
        {
            return id == "INTROMAP" || id == "C3INTRO" ||
                Regex.IsMatch(id, "^C[123]M[0-9]+(?:_[A-Z])?$");
        }

        private static bool BelongsToEpisode(string map, string startMap, int number)
        {
            if (map == startMap) {
                return true;
            }
            return map.StartsWith("C" + number.ToString(
                System.Globalization.CultureInfo.InvariantCulture),
                StringComparison.OrdinalIgnoreCase);
        }

        private static int CompareMaps(BoaMap left, BoaMap right)
        {
            if (left.Id == "INTROMAP" || left.Id == "C3INTRO") {
                return -1;
            }
            if (right.Id == "INTROMAP" || right.Id == "C3INTRO") {
                return 1;
            }
            Match leftMap = Regex.Match(
                left.Id, "^C(?<chapter>\\d+)M(?<mission>\\d+)(?:_(?<part>[A-Z]))?$",
                RegexOptions.IgnoreCase);
            Match rightMap = Regex.Match(
                right.Id, "^C(?<chapter>\\d+)M(?<mission>\\d+)(?:_(?<part>[A-Z]))?$",
                RegexOptions.IgnoreCase);
            if (leftMap.Success && rightMap.Success) {
                int byChapter = int.Parse(leftMap.Groups["chapter"].Value)
                    .CompareTo(int.Parse(rightMap.Groups["chapter"].Value));
                if (byChapter != 0) {
                    return byChapter;
                }

                int leftMission = int.Parse(leftMap.Groups["mission"].Value);
                int rightMission = int.Parse(rightMap.Groups["mission"].Value);
                int byMission = (leftMission == 0 ? int.MaxValue : leftMission)
                    .CompareTo(rightMission == 0 ? int.MaxValue : rightMission);
                if (byMission != 0) {
                    return byMission;
                }

                int byPart = string.Compare(
                    leftMap.Groups["part"].Value,
                    rightMap.Groups["part"].Value,
                    StringComparison.OrdinalIgnoreCase);
                if (byPart != 0) {
                    return byPart;
                }
            }
            return NaturalCompare(left.Id, right.Id);
        }

        private static int NaturalCompare(string left, string right)
        {
            Match leftNumber = Regex.Match(left, "\\d+");
            Match rightNumber = Regex.Match(right, "\\d+");
            if (leftNumber.Success && rightNumber.Success) {
                int byNumber = int.Parse(leftNumber.Value).CompareTo(
                    int.Parse(rightNumber.Value));
                if (byNumber != 0) {
                    return byNumber;
                }
            }
            return string.Compare(left, right, StringComparison.OrdinalIgnoreCase);
        }

        private void AddFallback()
        {
            string[][] episodeData = {
                new[] { "The Staff of Kings", "INTROMAP", "C1M1" },
                new[] { "Shadows of the Reich", "C2M1", "C2M1" },
                new[] { "The Final Confrontation", "C3INTRO", "C3M1_A" }
            };
            foreach (string[] data in episodeData) {
                BoaEpisode episode = new BoaEpisode();
                episode.Id = data[1];
                episode.StartMap = data[1];
                episode.NameKey = data[1];
                episode.DisplayName = data[0];
                BoaMap map = new BoaMap();
                map.Id = data[1];
                map.NameKey = data[1];
                map.DisplayName = data[0];
                episode.Maps.Add(map);
                Episodes.Add(episode);
            }
            string[] names = {
                "Warming-Up", "Morning Stroll", "Ordinary",
                "This is a Blazkowicz Job", "Mein Leben!"
            };
            for (int index = 0; index < names.Length; index++) {
                BoaSkill skill = new BoaSkill();
                skill.Number = index + 1;
                skill.Id = "Nazis" + (index + 1).ToString(
                    System.Globalization.CultureInfo.InvariantCulture);
                skill.NameKey = "BOASKILL" + (index + 1).ToString(
                    System.Globalization.CultureInfo.InvariantCulture);
                skill.DisplayName = names[index];
                Skills.Add(skill);
            }
            SourceDescription = "built-in compatibility fallback";
        }
    }
}
