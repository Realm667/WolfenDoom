using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace BladeOfAgonyLauncher
{
    internal enum CompatibilitySeverity
    {
        Information,
        Warning,
        Error
    }

    internal sealed class CompatibilityIssue
    {
        internal CompatibilitySeverity Severity;
        internal string Message;
        internal string SummaryKey;
        internal string[] SummaryArguments = new string[0];
        internal readonly HashSet<string> AffectedAddonIds =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        internal void Summary(string key, params string[] args)
        {
            SummaryKey = key;
            SummaryArguments = args;
        }

        public override string ToString()
        {
            return Message;
        }
    }

    internal static class AddonCompatibility
    {
        private static readonly FileMemo<string[]> archiveCache = new FileMemo<string[]>(64);
        private static readonly FileMemo<string> versionCache = new FileMemo<string>(8);

        private static string[] ReadArchiveEntries(string path)
        {
            return archiveCache.Get(path, string.Empty, delegate {
                using (ZipArchive archive = ZipFile.OpenRead(path)) {
                    return archive.Entries.Select(delegate(ZipArchiveEntry entry) {
                        return entry.FullName.Replace('\\', '/');
                    }).ToArray();
                }
            });
        }
        private static readonly HashSet<string> MergeableRootEntries =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase) {
                "mapinfo", "mapinfo.txt", "zscript", "zscript.zs",
                "zscript.txt", "sndinfo", "gameinfo", "loadacs",
                "animdefs", "gldefs"
            };

        internal static List<CompatibilityIssue> Analyze(
            string baseDirectory, IList<AddonDescriptor> selected)
        {
            List<CompatibilityIssue> issues = new List<CompatibilityIssue>();
            if (selected.Count == 0) return issues;
            Dictionary<string, AddonDescriptor> byId =
                new Dictionary<string, AddonDescriptor>(StringComparer.OrdinalIgnoreCase);
            foreach (AddonDescriptor addon in selected) {
                byId[addon.Id] = addon;
            }
            HashSet<string> reportedConflicts = new HashSet<string>(
                StringComparer.OrdinalIgnoreCase);

            for (int index = 0; index < selected.Count; index++) {
                AddonDescriptor addon = selected[index];
                foreach (string payload in addon.LoadFiles) {
                    string fullPath = SafePayloadPath(baseDirectory, payload);
                    if (fullPath == null || !File.Exists(fullPath)) {
                        Add(issues, CompatibilitySeverity.Error,
                            addon.Title + ": missing payload " + payload,
                            addon).Summary("{0}: missing {1}", addon.Title, payload);
                    }
                }
                foreach (string dependency in addon.RequiredAddons) {
                    if (!byId.ContainsKey(dependency)) {
                        Add(issues, CompatibilitySeverity.Error,
                            addon.Title + ": requires " + dependency,
                            addon).Summary("{0}: requires {1}", addon.Title, dependency);
                    }
                }
                foreach (string conflict in addon.ConflictingAddons) {
                    AddDeclaredConflict(
                        issues, reportedConflicts, byId, addon, conflict);
                }
                foreach (string predecessor in addon.LoadAfter) {
                    int predecessorIndex = IndexOf(selected, predecessor);
                    if (predecessorIndex < 0) {
                        Add(issues, CompatibilitySeverity.Warning,
                            addon.Title + ": load-after target is missing: " + predecessor,
                            addon);
                    } else if (predecessorIndex > index) {
                        Add(issues, CompatibilitySeverity.Warning,
                            addon.Title + " must load after " + predecessor,
                            addon, selected[predecessorIndex]);
                    }
                }
                if (addon.NewCampaignRequired) {
                    Add(issues, CompatibilitySeverity.Information,
                        addon.Title + ": start a new campaign after enabling this add-on.",
                        addon);
                }
                CheckEngineVersion(baseDirectory, addon, issues);
                CheckBoaVersion(baseDirectory, addon, issues);
            }
            BoaLauncherManifest manifest = BoaLauncherManifest.Load(
                baseDirectory, null);
            foreach (KeyValuePair<string, List<string>> pair in
                    manifest.AddonConflicts) {
                AddonDescriptor addon;
                if (!byId.TryGetValue(pair.Key, out addon)) continue;
                foreach (string conflict in pair.Value) {
                    AddDeclaredConflict(
                        issues, reportedConflicts, byId, addon, conflict);
                }
            }
            AnalyzeArchiveOverlaps(baseDirectory, selected, issues);
            return issues;
        }

        private static void AddDeclaredConflict(
            List<CompatibilityIssue> issues,
            HashSet<string> reportedConflicts,
            Dictionary<string, AddonDescriptor> byId,
            AddonDescriptor addon, string conflictId)
        {
            AddonDescriptor conflict;
            if (!byId.TryGetValue(conflictId, out conflict)) return;
            string[] ids = { addon.Id, conflict.Id };
            Array.Sort(ids, StringComparer.OrdinalIgnoreCase);
            if (!reportedConflicts.Add(ids[0] + "|" + ids[1])) return;
            Add(issues, CompatibilitySeverity.Error,
                addon.Title + " conflicts with " + conflict.Title + ".",
                addon, conflict).Summary("{0} conflicts with {1}.", addon.Title, conflict.Title);
        }

        private static void CheckEngineVersion(
            string baseDirectory, AddonDescriptor addon,
            List<CompatibilityIssue> issues)
        {
            if (addon.MinimumEngineVersion.Length == 0) {
                return;
            }
            string executable = LauncherPaths.EngineExecutable(baseDirectory);
            if (!File.Exists(executable)) {
                return;
            }
            Version required;
            Version actual;
            string version = FileVersionInfo.GetVersionInfo(executable).ProductVersion;
            if (Version.TryParse(NormalizeVersion(addon.MinimumEngineVersion), out required) &&
                    Version.TryParse(NormalizeVersion(version), out actual) &&
                    actual < required) {
                Add(issues, CompatibilitySeverity.Error,
                    addon.Title + ": requires UZDoom " + required + " or newer.",
                    addon).Summary("{0}: requires {1}", addon.Title, "UZDoom " + required + "+");
            }
        }

        private static void CheckBoaVersion(
            string baseDirectory, AddonDescriptor addon,
            List<CompatibilityIssue> issues)
        {
            if (addon.MinimumBoaVersion.Length == 0) {
                return;
            }
            string current = ReadBoaVersion(baseDirectory);
            Version required;
            Version actual;
            if (string.IsNullOrWhiteSpace(current) || !Version.TryParse(NormalizeVersion(current), out actual)) {
                Add(issues, CompatibilitySeverity.Error,
                    addon.Title + ": cannot determine the Blade of Agony version; " +
                    "rebuild boa.ipk3 with build.bat or restore its version metadata. " +
                    "The required minimum is " + addon.MinimumBoaVersion + ".", addon).Summary("{0}: unknown version of {1}", addon.Title, "Blade of Agony");
                return;
            }
            if (Version.TryParse(NormalizeVersion(addon.MinimumBoaVersion), out required) &&
                    Version.TryParse(NormalizeVersion(current), out actual) &&
                    actual < required) {
                Add(issues, CompatibilitySeverity.Error,
                    addon.Title + ": requires Blade of Agony " + required + " or newer.",
                    addon).Summary("{0}: requires {1}", addon.Title, "Blade of Agony " + required + "+");
            }
        }

        private static string ReadBoaVersion(string baseDirectory)
        {
            string unpacked = Path.Combine(baseDirectory, "wolf_boa.txt");
            string source = File.Exists(unpacked) ? unpacked : Path.Combine(baseDirectory, "boa.ipk3");
            return versionCache.Get(source, string.Empty,
                delegate { return ReadBoaVersionUncached(baseDirectory); });
        }

        private static string ReadBoaVersionUncached(string baseDirectory)
        {
            string unpacked = Path.Combine(baseDirectory, "wolf_boa.txt");
            if (File.Exists(unpacked)) {
                return ParseBoaVersion(File.ReadAllText(unpacked, Encoding.UTF8));
            }
            string archivePath = Path.Combine(baseDirectory, "boa.ipk3");
            if (!File.Exists(archivePath)) {
                return string.Empty;
            }
            try {
                using (ZipArchive archive = ZipFile.OpenRead(archivePath)) {
                    ZipArchiveEntry entry = GameArchive.FindEntry(archive, "wolf_boa.txt");
                    if (entry != null) {
                        using (StreamReader reader = new StreamReader(
                                entry.Open(), Encoding.UTF8, true)) {
                            return ParseBoaVersion(reader.ReadToEnd());
                        }
                    }
                }
            } catch {
                return string.Empty;
            }
            return string.Empty;
        }

        private static string ParseBoaVersion(string text)
        {
            Match match = Regex.Match(text ?? string.Empty,
                "(?im)^\\s*Version\\s*:\\s*v?([0-9]+(?:\\.[0-9]+){1,3})");
            return match.Success ? match.Groups[1].Value : string.Empty;
        }

        private static void AnalyzeArchiveOverlaps(
            string baseDirectory, IList<AddonDescriptor> selected,
            List<CompatibilityIssue> issues)
        {
            Dictionary<string, AddonDescriptor> entries =
                new Dictionary<string, AddonDescriptor>(StringComparer.OrdinalIgnoreCase);
            HashSet<string> reported = new HashSet<string>(
                StringComparer.OrdinalIgnoreCase);
            foreach (AddonDescriptor addon in selected) {
                foreach (string payload in addon.LoadFiles) {
                    string fullPath = SafePayloadPath(baseDirectory, payload);
                    if (fullPath == null || !File.Exists(fullPath)) {
                        continue;
                    }
                    try {
                        {
                            foreach (string entry in ReadArchiveEntries(fullPath)) {
                                string normalized = entry.Trim('/');
                                if (normalized.Length == 0 ||
                                        entry.EndsWith("/", StringComparison.Ordinal) ||
                                        MergeableRootEntries.Contains(normalized)) {
                                    continue;
                                }
                                AddonDescriptor owner;
                                if (entries.TryGetValue(normalized, out owner) &&
                                        owner != addon) {
                                    string key = owner.Id + "|" + addon.Id + "|" + normalized;
                                    if (reported.Add(key)) {
                                        bool zscriptCollision = normalized.EndsWith(
                                            ".zs", StringComparison.OrdinalIgnoreCase);
                                        Add(issues,
                                            zscriptCollision
                                                ? CompatibilitySeverity.Error
                                                : CompatibilitySeverity.Warning,
                                            zscriptCollision
                                                ? owner.Title + " and " + addon.Title +
                                                    " contain the same ZScript path " + normalized +
                                                    " and cannot be loaded together."
                                                : owner.Title + " and " + addon.Title +
                                                    " both replace " + normalized,
                                            owner, addon).Summary("{0} conflicts with {1}.", owner.Title, addon.Title);
                                    }
                                } else {
                                    entries[normalized] = addon;
                                }
                            }
                        }
                    } catch (InvalidDataException) {
                        Add(issues, CompatibilitySeverity.Error,
                            addon.Title + ": invalid payload archive " + payload,
                            addon).Summary("Cannot read: {0}", addon.Title + " / " + payload);
                    }
                }
            }
        }

        private static int IndexOf(IList<AddonDescriptor> addons, string id)
        {
            for (int index = 0; index < addons.Count; index++) {
                if (string.Equals(addons[index].Id, id,
                        StringComparison.OrdinalIgnoreCase)) {
                    return index;
                }
            }
            return -1;
        }

        private static string SafePayloadPath(string baseDirectory, string value)
        {
            if (string.IsNullOrEmpty(value) || Path.IsPathRooted(value)) {
                return null;
            }
            string root = Path.GetFullPath(baseDirectory)
                .TrimEnd(Path.DirectorySeparatorChar) + Path.DirectorySeparatorChar;
            string fullPath = Path.GetFullPath(Path.Combine(
                baseDirectory, value.Replace('/', Path.DirectorySeparatorChar)));
            return fullPath.StartsWith(root, StringComparison.OrdinalIgnoreCase)
                ? fullPath
                : null;
        }

        private static string NormalizeVersion(string value)
        {
            if (string.IsNullOrEmpty(value)) {
                return "0.0";
            }
            int separator = value.IndexOfAny(new[] { ' ', '-', '+' });
            return separator > 0 ? value.Substring(0, separator) : value;
        }

        private static CompatibilityIssue Add(
            List<CompatibilityIssue> issues,
            CompatibilitySeverity severity,
            string message,
            params AddonDescriptor[] affectedAddons)
        {
            CompatibilityIssue issue = new CompatibilityIssue();
            issue.Severity = severity;
            issue.Message = message;
            foreach (AddonDescriptor addon in affectedAddons) {
                if (addon != null && !string.IsNullOrEmpty(addon.Id)) {
                    issue.AffectedAddonIds.Add(addon.Id);
                }
            }
            issues.Add(issue);
            return issue;
        }
    }

    internal sealed class AddonLoadOrderResult
    {
        internal readonly List<AddonDescriptor> Ordered =
            new List<AddonDescriptor>();
        internal readonly List<string> Messages = new List<string>();
        internal bool Changed;
        internal bool CanResolve;
    }

    internal static class AddonLoadOrderResolver
    {
        internal static AddonLoadOrderResult Resolve(
            IList<AddonDescriptor> selected)
        {
            AddonLoadOrderResult result = new AddonLoadOrderResult();
            Dictionary<string, AddonDescriptor> byId =
                new Dictionary<string, AddonDescriptor>(StringComparer.OrdinalIgnoreCase);
            Dictionary<string, int> original =
                new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);
            Dictionary<string, HashSet<string>> edges =
                new Dictionary<string, HashSet<string>>(StringComparer.OrdinalIgnoreCase);
            Dictionary<string, int> incoming =
                new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase);

            for (int index = 0; index < selected.Count; index++) {
                AddonDescriptor addon = selected[index];
                byId[addon.Id] = addon;
                original[addon.Id] = index;
                edges[addon.Id] = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                incoming[addon.Id] = 0;
            }
            foreach (AddonDescriptor addon in selected) {
                List<string> predecessors = new List<string>();
                predecessors.AddRange(addon.RequiredAddons);
                predecessors.AddRange(addon.LoadAfter);
                foreach (string predecessor in predecessors) {
                    if (!byId.ContainsKey(predecessor) ||
                            string.Equals(predecessor, addon.Id,
                                StringComparison.OrdinalIgnoreCase)) continue;
                    if (edges[predecessor].Add(addon.Id)) {
                        incoming[addon.Id]++;
                    }
                }
            }

            List<string> ready = incoming.Where(delegate(KeyValuePair<string, int> item) {
                return item.Value == 0;
            }).Select(delegate(KeyValuePair<string, int> item) {
                return item.Key;
            }).OrderBy(delegate(string id) { return original[id]; }).ToList();

            while (ready.Count > 0) {
                string id = ready[0];
                ready.RemoveAt(0);
                result.Ordered.Add(byId[id]);
                foreach (string successor in edges[id]) {
                    incoming[successor]--;
                    if (incoming[successor] == 0) {
                        ready.Add(successor);
                        ready.Sort(delegate(string left, string right) {
                            return original[left].CompareTo(original[right]);
                        });
                    }
                }
            }

            result.CanResolve = result.Ordered.Count == selected.Count;
            if (!result.CanResolve) {
                result.Ordered.Clear();
                result.Ordered.AddRange(selected);
                result.Messages.Add(
                    "The declared add-on dependencies contain a load-order cycle.");
                return result;
            }
            for (int index = 0; index < selected.Count; index++) {
                if (!string.Equals(selected[index].Id, result.Ordered[index].Id,
                        StringComparison.OrdinalIgnoreCase)) {
                    result.Changed = true;
                    break;
                }
            }
            if (result.Changed) {
                result.Messages.Add(
                    "Load order was adjusted to satisfy requires and loadAfter metadata.");
            } else {
                result.Messages.Add("The selected add-on load order is already valid.");
            }
            return result;
        }

        internal static List<string> ValidatePairwiseMatrix(
            string baseDirectory, IList<AddonDescriptor> addons)
        {
            List<string> lines = new List<string>();
            for (int left = 0; left < addons.Count; left++) {
                ValidateCombination(baseDirectory,
                    new List<AddonDescriptor> { addons[left] }, lines);
                for (int right = left + 1; right < addons.Count; right++) {
                    ValidateCombination(baseDirectory,
                        new List<AddonDescriptor> { addons[left], addons[right] }, lines);
                }
            }
            return lines;
        }

        private static void ValidateCombination(
            string baseDirectory, IList<AddonDescriptor> addons,
            List<string> lines)
        {
            List<CompatibilityIssue> issues =
                AddonCompatibility.Analyze(baseDirectory, addons);
            List<CompatibilityIssue> blocking = issues.FindAll(
                delegate(CompatibilityIssue issue) {
                    return issue.Severity == CompatibilitySeverity.Error;
                });
            string names = string.Join(" + ", addons.Select(
                delegate(AddonDescriptor addon) { return addon.Id; }).ToArray());
            lines.Add((blocking.Count == 0 ? "PASS " : "BLOCK ") + names +
                (blocking.Count == 0 ? string.Empty : ": " +
                    string.Join(" | ", blocking.Select(
                        delegate(CompatibilityIssue issue) {
                            return issue.Message;
                        }).ToArray())));
        }
    }

    internal sealed class MultiplayerCompatibilityStatus
    {
        internal bool EnginePresent;
        internal bool MainGamePresent;
        internal bool CorrectEngineVersion;
        internal string EngineVersion;
        internal string MainGameDescription;

        internal bool IsReady
        {
            get {
                return EnginePresent && MainGamePresent && CorrectEngineVersion;
            }
        }

        internal static MultiplayerCompatibilityStatus Inspect(string baseDirectory)
        {
            MultiplayerCompatibilityStatus result =
                new MultiplayerCompatibilityStatus();
            string executable = LauncherPaths.EngineExecutable(baseDirectory);
            string game = Path.Combine(baseDirectory, "boa.ipk3");
            result.EnginePresent = File.Exists(executable);
            result.MainGamePresent = File.Exists(game);
            result.EngineVersion = result.EnginePresent
                ? EngineVersionSupport.ReadProductVersion(baseDirectory)
                : "missing";
            result.CorrectEngineVersion = result.EnginePresent &&
                EngineVersionSupport.IsSupported(result.EngineVersion);
            result.MainGameDescription = result.MainGamePresent
                ? new FileInfo(game).Length.ToString(
                    System.Globalization.CultureInfo.InvariantCulture) + " bytes"
                : "missing";
            return result;
        }
    }
}
