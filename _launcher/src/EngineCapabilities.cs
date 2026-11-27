using System;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace BladeOfAgonyLauncher
{
    internal sealed class EngineCapabilitySet
    {
        internal string Version;
        internal string ExecutableSha256;
        internal bool Probed;
        internal bool HelpAll;
        internal bool LoadGame;
        internal bool Episode;
        internal bool Coop;
        internal bool Password;
        internal bool OptionalFile;
        internal bool Config;
        internal bool CoopResume;
        internal readonly HashSet<string> NetworkRules = new HashSet<string>(StringComparer.Ordinal);

        internal string Summary
        {
            get { return Describe(null); }
        }

        internal string Describe(ModernLocalization text)
        {
                StringBuilder result = new StringBuilder();
                Append(result, LoadGame, "loadgame");
                Append(result, Episode, "episode");
                Append(result, Coop, "coop");
                Append(result, Password, "password");
                Append(result, OptionalFile, "optfile");
                Append(result, Config, "config");
                string key = Probed ? "Probed" : "Version fallback";
                return (text == null ? key : text.Get(key)) + ": " + result + "; " + (text == null ? "network rules (binary signatures)" : text.Get("Network rules")) + ": " + NetworkRules.Count;
        }

        private static void Append(StringBuilder target, bool enabled, string name)
        {
            if (!enabled) {
                return;
            }
            if (target.Length > 0) {
                target.Append(", ");
            }
            target.Append(name);
        }
    }

    internal static class EngineCapabilities
    {
        internal static EngineCapabilitySet Detect(string baseDirectory)
        {
            string executable = LauncherPaths.EngineExecutable(baseDirectory);
            EngineCapabilitySet fallback = CreateFallback(baseDirectory);
            if (!File.Exists(executable)) {
                return fallback;
            }
            string hash = FileFingerprint.CachedSha256(baseDirectory, executable);
            string cachePath = Path.Combine(
                LauncherPaths.DataDirectory(baseDirectory), "engine-capabilities.ini");
            IniFile cache = IniFile.Load(cachePath);
            if (cache.Get("Engine", "Sha256", string.Empty) == hash &&
                    cache.Get("Engine", "Schema", string.Empty) == "2") {
                return ReadCache(cache, fallback, hash);
            }

            EngineCapabilitySet detected = Probe(executable, fallback);
            DetectNetworkRules(executable, detected);
            detected.ExecutableSha256 = hash;
            IniFile output = new IniFile();
            output.Set("Engine", "Sha256", hash);
            output.Set("Engine", "Schema", "2");
            output.Set("Capabilities", "NetworkRules", string.Join(",", detected.NetworkRules));
            output.Set("Capabilities", "CoopResume", detected.CoopResume ? "1" : "0");
            output.Set("Engine", "Version", detected.Version ?? string.Empty);
            output.Set("Engine", "Probed", detected.Probed ? "1" : "0");
            output.Set("Capabilities", "HelpAll", detected.HelpAll ? "1" : "0");
            output.Set("Capabilities", "LoadGame", detected.LoadGame ? "1" : "0");
            output.Set("Capabilities", "Episode", detected.Episode ? "1" : "0");
            output.Set("Capabilities", "Coop", detected.Coop ? "1" : "0");
            output.Set("Capabilities", "Password", detected.Password ? "1" : "0");
            output.Set("Capabilities", "OptionalFile", detected.OptionalFile ? "1" : "0");
            output.Set("Capabilities", "Config", detected.Config ? "1" : "0");
            output.Save(cachePath);
            return detected;
        }

        internal static void Invalidate(string baseDirectory)
        {
            string path = Path.Combine(
                LauncherPaths.DataDirectory(baseDirectory), "engine-capabilities.ini");
            if (File.Exists(path)) {
                File.Delete(path);
            }
        }

        private static EngineCapabilitySet Probe(
            string executable,
            EngineCapabilitySet fallback)
        {
            if (EngineVersionSupport.MajorVersion(
                    Path.GetDirectoryName(executable)) < 5) {
                return fallback;
            }
            StringBuilder output = new StringBuilder();
            object outputLock = new object();
            try {
                ProcessStartInfo start = new ProcessStartInfo {
                    FileName = executable,
                    Arguments = "-help-all",
                    WorkingDirectory = Path.GetDirectoryName(executable),
                    UseShellExecute = false,
                    CreateNoWindow = true,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true
                };
                using (Process process = new Process()) {
                    process.StartInfo = start;
                    process.OutputDataReceived += delegate(object sender, DataReceivedEventArgs args) {
                        if (args.Data != null) {
                            lock (outputLock) output.AppendLine(args.Data);
                        }
                    };
                    process.ErrorDataReceived += delegate(object sender, DataReceivedEventArgs args) {
                        if (args.Data != null) {
                            lock (outputLock) output.AppendLine(args.Data);
                        }
                    };
                    process.Start();
                    process.BeginOutputReadLine();
                    process.BeginErrorReadLine();
                    if (!process.WaitForExit(6000)) {
                        process.Kill();
                        process.WaitForExit();
                        return fallback;
                    }
                    process.WaitForExit();
                }
            } catch {
                return fallback;
            }

            string help = output.ToString();
            if (help.Length < 20) {
                return fallback;
            }
            EngineCapabilitySet result = new EngineCapabilitySet();
            result.Version = fallback.Version;
            result.Probed = true;
            result.HelpAll = true;
            result.LoadGame = ContainsArgument(help, "-loadgame");
            result.Episode = ContainsArgument(help, "-episode");
            result.Coop = ContainsArgument(help, "-coop");
            result.Password = ContainsArgument(help, "-password");
            result.OptionalFile = ContainsArgument(help, "-optfile");
            result.Config = ContainsArgument(help, "-config");
            if (ContainsArgument(help, "-dup")) result.NetworkRules.Add("ticdup");
            return result;
        }

        private static bool ContainsArgument(string help, string argument)
        {
            return Regex.IsMatch(help, @"(?<![\w-])" + Regex.Escape(argument) + @"(?![\w-])", RegexOptions.IgnoreCase);
        }

        private static void DetectNetworkRules(string executable, EngineCapabilitySet result)
        {
            // CLI help does not enumerate CVars. Null-delimited compiled identifiers
            // are a conservative capability signal, not a claim of a runtime CVar probe.
            try {
                string binary = Encoding.GetEncoding(28591).GetString(File.ReadAllBytes(executable));
                foreach (NetworkRule rule in NetworkRule.All) {
                    string identifier = rule.Key == "ticdup" ? "dup" : rule.Key;
                    if (binary.IndexOf("\0" + identifier + "\0", StringComparison.Ordinal) >= 0)
                        result.NetworkRules.Add(rule.Key);
                }
                result.CoopResume = result.LoadGame && result.NetworkRules.Contains("net_limitsaves");
            } catch (IOException) { } catch (UnauthorizedAccessException) { }
        }

        private static EngineCapabilitySet CreateFallback(string baseDirectory)
        {
            int major = EngineVersionSupport.MajorVersion(baseDirectory);
            return new EngineCapabilitySet {
                Version = EngineVersionSupport.ReadProductVersion(baseDirectory),
                Probed = false,
                HelpAll = major >= 5,
                LoadGame = true,
                Episode = major >= 5,
                Coop = major >= 5,
                Password = major >= 5,
                OptionalFile = major >= 5,
                Config = true
            };
        }

        private static EngineCapabilitySet ReadCache(
            IniFile cache,
            EngineCapabilitySet fallback,
            string hash)
        {
            fallback.ExecutableSha256 = hash;
            fallback.Version = cache.Get("Engine", "Version", fallback.Version);
            fallback.Probed = cache.GetBoolean("Engine", "Probed", false);
            fallback.HelpAll = cache.GetBoolean("Capabilities", "HelpAll", fallback.HelpAll);
            fallback.LoadGame = cache.GetBoolean("Capabilities", "LoadGame", fallback.LoadGame);
            fallback.Episode = cache.GetBoolean("Capabilities", "Episode", fallback.Episode);
            fallback.Coop = cache.GetBoolean("Capabilities", "Coop", fallback.Coop);
            fallback.Password = cache.GetBoolean("Capabilities", "Password", fallback.Password);
            fallback.OptionalFile = cache.GetBoolean("Capabilities", "OptionalFile", fallback.OptionalFile);
            fallback.Config = cache.GetBoolean("Capabilities", "Config", fallback.Config);
            foreach (string key in cache.Get("Capabilities", "NetworkRules", string.Empty).Split(','))
                if (NetworkRule.Find(key) != null) fallback.NetworkRules.Add(key);
            fallback.CoopResume = cache.GetBoolean("Capabilities", "CoopResume", false);
            return fallback;
        }
    }
}
