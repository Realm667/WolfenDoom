using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;

namespace BladeOfAgonyLauncher
{
    internal sealed class NetworkRule
    {
        internal readonly string Key, Label, Description;
        internal readonly int Maximum;
        internal readonly string[] Choices;
        internal NetworkRule(string key, string label, string description, int maximum, params string[] choices)
        { Key = key; Label = label; Description = description; Maximum = maximum; Choices = choices; }

        internal static readonly NetworkRule[] All = {
            new NetworkRule("net_ticbalance", "Balance network timing", "Balances input timing between connected players.", 1, "Off", "On"),
            new NetworkRule("net_extratic", "Redundant movement packets", "Sends backup movement commands to tolerate packet loss; uses more bandwidth.", 1, "Off", "On"),
            new NetworkRule("ticdup", "Movement command interval", "1 sends every movement command. Higher values reduce bandwidth and input precision.", 9),
            new NetworkRule("net_disablepause", "Pause permission", "Settings controllers include the host and players authorized by the host.", 2, "Everyone", "Settings controllers", "Disabled"),
            new NetworkRule("net_limitsaves", "Save permission", "Restricts manual saves to settings controllers. UZDoom disables automatic and quick saves in network games.", 1, "Everyone", "Settings controllers"),
            new NetworkRule("net_limitconversations", "Restrict conversations", "Limits simultaneous engine conversations. Custom BoA ACS briefings use their own logic.", 1, "Off", "On"),
            new NetworkRule("net_repeatableactioncooldown", "Repeated action cooldown", "Limits repeated network actions to reduce accidental duplicate activations.", 1, "Off", "On"),
            new NetworkRule("net_chatslowmode", "Chat interval (seconds)", "Minimum interval between chat messages. Zero disables slow mode.", 300)
        };

        internal static NetworkRule Find(string key)
        { return All.FirstOrDefault(delegate(NetworkRule rule) { return rule.Key == key; }); }
    }

    internal static class MultiplayerSettings
    {
        internal static void ValidatePassword(string password)
        {
            if (string.IsNullOrEmpty(password)) return;
            int bytes;
            try { bytes = new UTF8Encoding(false, true).GetByteCount(password); }
            catch (EncoderFallbackException) { throw new InvalidDataException("The password contains invalid Unicode characters."); }
            if (password.IndexOf('\0') >= 0 || bytes > 255)
                throw new InvalidDataException("The lobby password must contain at most 255 UTF-8 bytes and no null characters. It has not been truncated.");
        }

        internal static void ValidateRules(IDictionary<string, int> rules)
        {
            if (rules == null) throw new InvalidDataException("Network settings are missing.");
            foreach (KeyValuePair<string, int> pair in rules) {
                NetworkRule rule = NetworkRule.Find(pair.Key);
                if (rule == null || pair.Value < (pair.Key == "ticdup" ? 1 : 0) || pair.Value > rule.Maximum)
                    throw new InvalidDataException("Invalid network setting: " + pair.Key);
            }
        }

        internal static void Validate(LauncherOptions options, EngineCapabilitySet capabilities)
        {
            if (options.NetworkMode == MultiplayerMode.SinglePlayer) return;
            ValidatePassword(options.MultiplayerPassword);
            if (!string.IsNullOrEmpty(options.MultiplayerPassword) && !capabilities.Password)
                throw new InvalidDataException("This engine does not support lobby passwords.");
            if (options.ImportedSessionRequiresPassword && string.IsNullOrEmpty(options.MultiplayerPassword))
                throw new InvalidDataException("The imported session requires a password.");
            ValidateRules(options.MultiplayerRules);
            if (options.NetworkMode == MultiplayerMode.Host || options.ImportedSessionRules) {
                foreach (string key in options.MultiplayerRules.Keys)
                    if (!capabilities.NetworkRules.Contains(key))
                        throw new InvalidDataException("The detected engine does not support network setting " + key + ". Reset it to Engine default.");
            }
            if (!string.IsNullOrWhiteSpace(options.MultiplayerSavePath)) {
                if (!capabilities.CoopResume)
                    throw new InvalidDataException("Co-op save restoration requires a verified UZDoom 5 engine.");
                CoopSaveService.Validate(options);
            } else if (!string.IsNullOrEmpty(options.ImportedSaveSha256)) {
                throw new InvalidDataException("Select the local copy of this session's co-op save before joining.");
            }
        }

        internal static void AppendRules(List<string> arguments, LauncherOptions options)
        {
            foreach (NetworkRule rule in NetworkRule.All) {
                int value;
                if (!options.MultiplayerRules.TryGetValue(rule.Key, out value)) continue;
                if (rule.Key == "ticdup") arguments.Add("-dup");
                else { arguments.Add("+set"); arguments.Add(rule.Key); }
                arguments.Add(value.ToString(CultureInfo.InvariantCulture));
            }
        }
    }
}
