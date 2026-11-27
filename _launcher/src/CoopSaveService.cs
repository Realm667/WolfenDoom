using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text.RegularExpressions;

namespace BladeOfAgonyLauncher
{
    [DataContract]
    internal sealed class CoopSaveHeader
    {
        [DataMember(Name = "multiplayer")] public bool Multiplayer { get; set; }
        [DataMember(Name = "numplayers")] public int PlayerCount { get; set; }
        [DataMember(Name = "players")] public CoopSavePlayer[] Players { get; set; }
    }

    [DataContract]
    internal sealed class CoopSavePlayer
    {
        [DataMember(Name = "playername")] public string Name { get; set; }
    }

    internal static class CoopSaveService
    {
        private static readonly FileMemo<CoopSaveHeader> cache = new FileMemo<CoopSaveHeader>(64);
        private static readonly FileMemo<string> folderCache = new FileMemo<string>(8);

        internal static string LoadName(LauncherOptions options)
        {
            return SaveName(FileFingerprint.CachedSha256(options.BaseDirectory, options.MultiplayerSavePath));
        }

        private static string SaveName(string hash)
        {
            // Keep portable paths short; Prepare still verifies the complete SHA-256.
            return "boa-resume-" + hash.Substring(0, 24).ToLowerInvariant() + ".zds";
        }

        internal static string NetworkDirectory(string baseDirectory)
        {
            bool portable = false;
            string ini = Path.Combine(baseDirectory, "uzdoom_portable.ini");
            bool programFiles = new[] { "ProgramFiles", "ProgramFiles(x86)" }.Any(variable => {
                string path = Environment.GetEnvironmentVariable(variable);
                return !string.IsNullOrEmpty(path) && Path.GetFullPath(baseDirectory).StartsWith(path, StringComparison.OrdinalIgnoreCase);
            });
            if (!programFiles && File.Exists(ini)) {
                try { using (File.Open(ini, FileMode.Open, FileAccess.ReadWrite, FileShare.None)) portable = true; }
                catch (IOException) { } catch (UnauthorizedAccessException) { }
            }
            string savedGames = SavegameService.GetSavedGamesDirectory();
            if (!portable && string.IsNullOrWhiteSpace(savedGames))
                throw new IOException("Windows did not provide a Saved Games directory.");
            string root = portable ? Path.Combine(baseDirectory, "Save") : Path.Combine(savedGames, "UZDoom");
            string game = Path.Combine(baseDirectory, "boa.ipk3");
            string folder = folderCache.Get(game, "AutoName", delegate {
                using (ZipArchive zip = ZipFile.OpenRead(game)) {
                    ZipArchiveEntry entry = zip.Entries.FirstOrDefault(e => e.FullName.Equals("iwadinfo.txt", StringComparison.OrdinalIgnoreCase));
                    if (entry == null || entry.Length > 1024 * 1024) throw new InvalidDataException("Missing BoA IWAD save-folder information.");
                    using (StreamReader reader = new StreamReader(entry.Open())) {
                        Match match = Regex.Match(reader.ReadToEnd(), "\\bAutoName\\s*=\\s*\"([A-Za-z0-9_.-]+)\"", RegexOptions.IgnoreCase);
                        if (!match.Success || match.Groups[1].Value == "." || match.Groups[1].Value == "..")
                            throw new InvalidDataException("Invalid BoA IWAD save-folder information.");
                        return match.Groups[1].Value;
                    }
                }
            });
            return Path.Combine(root, "NetGame", folder);
        }

        internal static void Prepare(LauncherOptions options)
        {
            Validate(options);
            string directory = NetworkDirectory(options.BaseDirectory);
            Directory.CreateDirectory(directory);
            string expectedHash = FileFingerprint.Sha256(options.MultiplayerSavePath);
            string target = Path.Combine(directory, SaveName(expectedHash));
            if (!File.Exists(target)) {
                string temporary = Path.Combine(directory, ".boa-" + Guid.NewGuid().ToString("N") + ".tmp");
                try {
                    File.Copy(options.MultiplayerSavePath, temporary, false);
                    if (!string.Equals(FileFingerprint.Sha256(temporary), expectedHash, StringComparison.OrdinalIgnoreCase))
                        throw new IOException("The co-op save changed while preparing the launch.");
                    File.Move(temporary, target);
                } finally { if (File.Exists(temporary)) File.Delete(temporary); }
            }
            if (!string.Equals(FileFingerprint.Sha256(target), expectedHash, StringComparison.OrdinalIgnoreCase))
                throw new IOException("A conflicting file exists at the prepared co-op save path.");
            if (!File.Exists(target + ".boa-launcher.ini"))
                File.Copy(options.MultiplayerSavePath + ".boa-launcher.ini", target + ".boa-launcher.ini", false);
        }

        internal static CoopSaveHeader Read(SavegameInfo save)
        {
            return cache.Get(save.Path, save.CurrentMap, delegate {
                using (ZipArchive archive = ZipFile.OpenRead(save.Path)) {
                    ZipArchiveEntry entry = archive.Entries.FirstOrDefault(delegate(ZipArchiveEntry item) {
                        return string.Equals(item.FullName, save.CurrentMap + ".map.json", StringComparison.OrdinalIgnoreCase);
                    });
                    if (entry == null || entry.Length > 128 * 1024 * 1024)
                        throw new InvalidDataException("This save has no supported map snapshot.");
                    using (Stream stream = entry.Open()) {
                        DataContractJsonSerializer serializer = new DataContractJsonSerializer(typeof(CoopSaveHeader),
                            new DataContractJsonSerializerSettings { IgnoreExtensionDataObject = true, MaxItemsInObjectGraph = 2000000 });
                        return (CoopSaveHeader)serializer.ReadObject(stream);
                    }
                }
            });
        }

        internal static bool IsCoop(SavegameInfo save)
        {
            try { CoopSaveHeader header = Read(save); return header.Multiplayer && header.PlayerCount > 1; }
            catch { return false; }
        }

        internal static void Validate(LauncherOptions options)
        {
            SavegameInfo save = SavegameService.Read(options.MultiplayerSavePath);
            if (!string.Equals(Path.GetFileName(save.GameWad), "boa.ipk3", StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("The co-op save does not belong to boa.ipk3.");
            CoopSaveHeader header = Read(save);
            if (!header.Multiplayer || header.PlayerCount < 2 || header.PlayerCount > 4 ||
                    header.Players == null || header.Players.Length != header.PlayerCount)
                throw new InvalidDataException("Select a readable BoA co-op save for 2-4 players.");
            if (options.MultiplayerPlayers != header.PlayerCount)
                throw new InvalidDataException("This save requires " + header.PlayerCount + " players. Keep the original player names to restore the correct characters.");

            // Unbound legacy saves cannot prove the exact game/engine/add-on identity.
            IniFile binding = IniFile.Load(save.Path + ".boa-launcher.ini");
            string engine = FileFingerprint.CachedSha256(options.BaseDirectory, LauncherPaths.EngineExecutable(options.BaseDirectory));
            string game = FileFingerprint.CachedSha256(options.BaseDirectory, Path.Combine(options.BaseDirectory, "boa.ipk3"));
            if (string.IsNullOrEmpty(engine) || string.IsNullOrEmpty(game) ||
                    !string.Equals(engine, binding.Get("Files", "EngineSha256", ""), StringComparison.OrdinalIgnoreCase) ||
                    !string.Equals(game, binding.Get("Files", "MainGameSha256", ""), StringComparison.OrdinalIgnoreCase) ||
                    binding.Get("Addons", "Selection", "missing") != string.Empty)
                throw new InvalidDataException("This co-op save has no matching engine/game binding or was created with add-ons. Use its original installation and include the .boa-launcher.ini companion file.");
            if (!string.IsNullOrEmpty(options.ImportedSaveSha256) && !string.Equals(
                    options.ImportedSaveSha256, FileFingerprint.CachedSha256(options.BaseDirectory, save.Path), StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("The selected co-op save differs from the host's session save.");
        }
    }
}
