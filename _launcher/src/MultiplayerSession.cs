using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Web.Script.Serialization;

namespace BladeOfAgonyLauncher
{
    internal sealed class BoaMultiplayerSession
    {
        public int FormatVersion { get; set; }
        public string Game { get; set; }
        public string EngineVersion { get; set; }
        public string EngineSha256 { get; set; }
        public string MainGameSha256 { get; set; }
        public string Host { get; set; }
        public int Port { get; set; }
        public int Players { get; set; }
        public string Map { get; set; }
        public int Skill { get; set; }
        public bool Cheats { get; set; }
        public bool PasswordRequired { get; set; }
        public string CreatedUtc { get; set; }
        public Dictionary<string, int> NetworkRules { get; set; }
        public string SaveName { get; set; }
        public string SaveSha256 { get; set; }
    }

    internal sealed class SessionValidation
    {
        internal readonly List<string> Errors = new List<string>();
        internal readonly List<string> Warnings = new List<string>();
        internal bool IsCompatible { get { return Errors.Count == 0; } }
    }

    internal static class MultiplayerSessionFile
    {
        internal static BoaMultiplayerSession Create(LauncherOptions options)
        {
            MultiplayerSettings.Validate(options, EngineCapabilities.Detect(options.BaseDirectory));
            return new BoaMultiplayerSession {
                FormatVersion = 2,
                NetworkRules = new Dictionary<string, int>(options.MultiplayerRules),
                SaveName = string.IsNullOrEmpty(options.MultiplayerSavePath) ? null : Path.GetFileName(options.MultiplayerSavePath),
                SaveSha256 = string.IsNullOrEmpty(options.MultiplayerSavePath) ? null : FileFingerprint.CachedSha256(options.BaseDirectory, options.MultiplayerSavePath),
                Game = "Blade of Agony",
                EngineVersion = EngineVersionSupport.ReadProductVersion(options.BaseDirectory),
                EngineSha256 = FileFingerprint.CachedSha256(
                    options.BaseDirectory, LauncherPaths.EngineExecutable(options.BaseDirectory)),
                MainGameSha256 = FileFingerprint.CachedSha256(
                    options.BaseDirectory, Path.Combine(options.BaseDirectory, "boa.ipk3")),
                Host = options.MultiplayerHost == "localhost"
                    ? string.Empty
                    : options.MultiplayerHost,
                Port = Math.Max(1, Math.Min(65535, options.MultiplayerPort)),
                Players = Math.Max(2, Math.Min(4, options.MultiplayerPlayers)),
                Map = LauncherOptions.NormalizeMapName(options.MultiplayerStartMap),
                Skill = Math.Max(1, Math.Min(5, options.MultiplayerSkill)),
                Cheats = options.MultiplayerCheats,
                PasswordRequired = !string.IsNullOrEmpty(options.MultiplayerPassword),
                CreatedUtc = DateTime.UtcNow.ToString("o", System.Globalization.CultureInfo.InvariantCulture)
            };
        }

        internal static void Save(string path, BoaMultiplayerSession session)
        {
            string json = new JavaScriptSerializer().Serialize(session);
            File.WriteAllText(path, PrettyPrint(json), new UTF8Encoding(false));
        }

        internal static BoaMultiplayerSession Load(string path)
        {
            BoaMultiplayerSession result = new JavaScriptSerializer().Deserialize<BoaMultiplayerSession>(
                File.ReadAllText(path, Encoding.UTF8));
            if (result == null || (result.FormatVersion != 1 && result.FormatVersion != 2) ||
                    !string.Equals(result.Game, "Blade of Agony", StringComparison.Ordinal)) {
                throw new InvalidDataException("This is not a supported Blade of Agony session file.");
            }
            if (!LauncherOptions.IsValidMapName(result.Map) ||
                    result.Port < 1 || result.Port > 65535 ||
                    result.Players < 2 || result.Players > 4 ||
                    result.Skill < 1 || result.Skill > 5) {
                throw new InvalidDataException("The session contains invalid launch values.");
            }
            if (result.FormatVersion == 1) {
                result.NetworkRules = new Dictionary<string, int>();
                result.SaveName = result.SaveSha256 = null;
            }
            result.NetworkRules = result.NetworkRules ?? new Dictionary<string, int>();
            MultiplayerSettings.ValidateRules(result.NetworkRules);
            if (!string.IsNullOrEmpty(result.SaveSha256) &&
                    (!System.Text.RegularExpressions.Regex.IsMatch(result.SaveSha256, "\\A[0-9a-fA-F]{64}\\z") ||
                    string.IsNullOrEmpty(result.SaveName) || Path.GetFileName(result.SaveName) != result.SaveName))
                throw new InvalidDataException("Invalid co-op save identity in session file.");
            if (!string.IsNullOrEmpty(result.SaveName) && string.IsNullOrEmpty(result.SaveSha256))
                throw new InvalidDataException("The session save checksum is missing.");
            return result;
        }

        internal static SessionValidation Validate(
            string baseDirectory, BoaMultiplayerSession session)
        {
            SessionValidation result = new SessionValidation();
            string engine = FileFingerprint.CachedSha256(
                baseDirectory, LauncherPaths.EngineExecutable(baseDirectory));
            string game = FileFingerprint.CachedSha256(
                baseDirectory, Path.Combine(baseDirectory, "boa.ipk3"));
            if (string.IsNullOrEmpty(engine) ||
                    !string.Equals(engine, session.EngineSha256, StringComparison.OrdinalIgnoreCase)) {
                result.Errors.Add("UZDoom executable mismatch.");
            }
            if (string.IsNullOrEmpty(game) ||
                    !string.Equals(game, session.MainGameSha256, StringComparison.OrdinalIgnoreCase)) {
                result.Errors.Add("boa.ipk3 mismatch.");
            }
            if (session.PasswordRequired && !EngineCapabilities.Detect(baseDirectory).Password) {
                result.Errors.Add("This session requires engine password support.");
            }
            EngineCapabilitySet capabilities = EngineCapabilities.Detect(baseDirectory);
            foreach (string key in (session.NetworkRules ?? new Dictionary<string, int>()).Keys)
                if (!capabilities.NetworkRules.Contains(key)) result.Errors.Add("Unsupported session network setting: " + key);
            if (!string.IsNullOrEmpty(session.SaveSha256)) {
                if (!capabilities.CoopResume) result.Errors.Add("This engine does not support the co-op save workflow.");
                result.Warnings.Add("Each player needs the identical co-op save and its .boa-launcher.ini companion file. Select the local copy before joining and keep the original player names.");
            }
            if (string.IsNullOrEmpty(session.Host)) {
                result.Warnings.Add("Enter the host name or IP address after importing.");
            }
            return result;
        }

        internal static void Apply(LauncherOptions options, BoaMultiplayerSession session)
        {
            options.NetworkMode = MultiplayerMode.Join;
            options.MultiplayerHost = LauncherOptions.IsValidHost(session.Host)
                ? session.Host
                : "localhost";
            options.MultiplayerPort = session.Port;
            options.MultiplayerPlayers = session.Players;
            options.MultiplayerStartMap = session.Map;
            options.MultiplayerSkill = session.Skill;
            options.MultiplayerCheats = session.Cheats;
            options.MultiplayerPassword = string.Empty;
            options.ImportedSessionRequiresPassword = session.PasswordRequired;
            options.MultiplayerRules = new Dictionary<string, int>(session.NetworkRules ?? new Dictionary<string, int>());
            options.ImportedSessionRules = true;
            options.MultiplayerSavePath = null;
            options.ImportedSaveSha256 = session.SaveSha256;
        }

        private static string PrettyPrint(string json)
        {
            StringBuilder result = new StringBuilder();
            bool quoted = false;
            bool escaped = false;
            int depth = 0;
            foreach (char current in json) {
                if (quoted) {
                    result.Append(current);
                    if (escaped) escaped = false;
                    else if (current == '\\') escaped = true;
                    else if (current == '"') quoted = false;
                    continue;
                }
                if (current == '"') {
                    quoted = true;
                    result.Append(current);
                } else if (current == '{' || current == '[') {
                    result.Append(current).AppendLine();
                    depth++;
                    result.Append(' ', depth * 2);
                } else if (current == '}' || current == ']') {
                    result.AppendLine();
                    depth--;
                    result.Append(' ', depth * 2).Append(current);
                } else if (current == ',') {
                    result.Append(current).AppendLine().Append(' ', depth * 2);
                } else if (current == ':') {
                    result.Append(": ");
                } else if (!char.IsWhiteSpace(current)) {
                    result.Append(current);
                }
            }
            return result.ToString();
        }
    }
}
