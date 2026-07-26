using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace BladeOfAgonyLauncher
{
    internal sealed class PoCatalog
    {
        private readonly Dictionary<string, string> translations =
            new Dictionary<string, string>(StringComparer.Ordinal);

        internal static PoCatalog Load(string baseDirectory, string languageCode)
        {
            PoCatalog result = new PoCatalog();
            string language = LauncherOptions.NormalizeLanguage(languageCode);
            result.AddBuiltIn(language);
            if (language == "en") {
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

        private void AddBuiltIn(string language)
        {
            if (language == "en") {
                return;
            }

            string[] keys = {
                "Use last settings",
                "Reset to default settings",
                "Very low detail (fastest)",
                "Low detail (faster)",
                "Normal detail",
                "High detail (prettier)",
                "Very high detail (beautiful)",
                "Disable (faster)",
                "Enable (beautiful)",
                "Developer commentary",
                "Detail preset:",
                "Displacement textures:",
                "Game language:",
                "Launch with:",
                "No addon selected.",
                "Scan for addons",
                "Description:",
                "Requirements:",
                "Play",
                "Exit",
                ", and %d more",
                "No addons",
                "by",
                "Multiplayer",
                "Mode:",
                "Single player",
                "Host co-op",
                "Join co-op",
                "Players (including host):",
                "Start map:",
                "Host / IP:",
                "UDP port:",
                "Skill:",
                "Allow cheats",
                "Design:",
                "Dark",
                "Light"
            };

            string data = null;
            switch (language) {
                case "de":
                    data = "Letzte Einstellungen verwenden|Auf Standardeinstellungen zurücksetzen|Sehr niedrige Details (am schnellsten)|Niedrige Details (schneller)|Normale Details|Hohe Details (schöner)|Sehr hohe Details (am schönsten)|Deaktivieren (schneller)|Aktivieren (schöner)|Entwicklerkommentar|Detailstufe:|Displacement-Texturen:|Spielsprache:|Starte mit:|Kein Addon ausgewählt.|Nach Addons scannen|Beschreibung:|Voraussetzungen:|Spielen|Beenden|, und %d weitere|Keine Addons|von|Mehrspieler|Modus:|Einzelspieler|Co-op hosten|Co-op beitreten|Spieler (inklusive Host):|Startkarte:|Host / IP:|UDP-Port:|Schwierigkeit:|Cheats erlauben|Design:|Dunkel|Hell";
                    break;
                case "es":
                    data = "Usar últimos ajustes|Restablecer ajustes predeterminados|Detalle muy bajo (más rápido)|Detalle bajo (rápido)|Detalle normal|Detalle alto (más bonito)|Detalle muy alto (más bonito)|Desactivar (rápido)|Activar (más bonito)|Comentarios del desarrollador|Nivel de detalle:|Texturas de desplazamiento:|Idioma del juego:|Iniciar con:|Ningún addon seleccionado.|Buscar addons|Descripción:|Requisitos:|Jugar|Salir|, y %d más|Sin addons|por|Multijugador|Modo:|Un jugador|Alojar cooperativo|Unirse a cooperativo|Jugadores (incluido anfitrión):|Mapa inicial:|Host / IP:|Puerto UDP:|Dificultad:|Permitir trucos|Diseño:|Oscuro|Claro";
                    break;
                case "ru":
                    data = "Использовать последние настройки|Сбросить настройки|Очень низкая детализация (быстрее всего)|Низкая детализация (быстрее)|Обычная детализация|Высокая детализация (красивее)|Очень высокая детализация|Отключить (быстрее)|Включить (красивее)|Комментарии разработчиков|Детализация:|Текстуры смещения:|Язык игры:|Запустить с:|Дополнение не выбрано.|Найти дополнения|Описание:|Требования:|Играть|Выход| и ещё %d|Без дополнений|от|Сетевая игра|Режим:|Одиночная игра|Создать кооператив|Подключиться к кооперативу|Игроки (включая хоста):|Начальная карта:|Хост / IP:|UDP-порт:|Сложность:|Разрешить читы|Оформление:|Тёмное|Светлое";
                    break;
                case "ptb":
                    data = "Usar últimas configurações|Restaurar configurações padrão|Detalhe muito baixo (mais rápido)|Detalhe baixo (rápido)|Detalhe normal|Detalhe alto (mais bonito)|Detalhe muito alto (mais bonito)|Desativar (rápido)|Ativar (mais bonito)|Comentários dos desenvolvedores|Nível de detalhe:|Texturas de deslocamento:|Idioma do jogo:|Iniciar com:|Nenhum addon selecionado.|Procurar addons|Descrição:|Requisitos:|Jogar|Sair| e mais %d|Sem addons|por|Multijogador|Modo:|Um jogador|Hospedar cooperativo|Entrar no cooperativo|Jogadores (incluindo host):|Mapa inicial:|Host / IP:|Porta UDP:|Dificuldade:|Permitir cheats|Tema:|Escuro|Claro";
                    break;
                case "it":
                    data = "Usa ultime impostazioni|Ripristina impostazioni predefinite|Dettagli molto bassi (più veloce)|Dettagli bassi (veloce)|Dettagli normali|Dettagli alti (più bello)|Dettagli molto alti (più bello)|Disattiva (veloce)|Attiva (più bello)|Commento degli sviluppatori|Livello dettagli:|Texture di spostamento:|Lingua del gioco:|Avvia con:|Nessun addon selezionato.|Cerca addon|Descrizione:|Requisiti:|Gioca|Esci| e altri %d|Nessun addon|di|Multigiocatore|Modalità:|Giocatore singolo|Ospita cooperativa|Partecipa alla cooperativa|Giocatori (host incluso):|Mappa iniziale:|Host / IP:|Porta UDP:|Difficoltà:|Consenti trucchi|Tema:|Scuro|Chiaro";
                    break;
                case "tr":
                    data = "Son ayarları kullan|Varsayılan ayarlara dön|Çok düşük ayrıntı (en hızlı)|Düşük ayrıntı (daha hızlı)|Normal ayrıntı|Yüksek ayrıntı (daha güzel)|Çok yüksek ayrıntı (en güzel)|Devre dışı (daha hızlı)|Etkin (daha güzel)|Geliştirici yorumları|Ayrıntı düzeyi:|Yer değiştirme dokuları:|Oyun dili:|Şununla başlat:|Addon seçilmedi.|Addon tara|Açıklama:|Gereksinimler:|Oyna|Çıkış| ve %d tane daha|Addon yok|yapan|Çok oyunculu|Mod:|Tek oyunculu|Co-op barındır|Co-op'a katıl|Oyuncular (host dahil):|Başlangıç haritası:|Host / IP:|UDP portu:|Zorluk:|Hilelere izin ver|Tema:|Koyu|Açık";
                    break;
                case "fr":
                    data = "Utiliser les derniers réglages|Rétablir les réglages par défaut|Détails très faibles (plus rapide)|Détails faibles (rapide)|Détails normaux|Détails élevés (plus joli)|Détails très élevés (plus joli)|Désactiver (rapide)|Activer (plus joli)|Commentaires des développeurs|Niveau de détail :|Textures de déplacement :|Langue du jeu :|Démarrer avec :|Aucun addon sélectionné.|Rechercher les addons|Description :|Prérequis :|Jouer|Quitter| et %d de plus|Aucun addon|par|Multijoueur|Mode :|Un joueur|Héberger une partie coop|Rejoindre une partie coop|Joueurs (hôte inclus) :|Carte de départ :|Hôte / IP :|Port UDP :|Difficulté :|Autoriser les codes|Thème :|Sombre|Clair";
                    break;
                case "cs":
                    data = "Použít poslední nastavení|Obnovit výchozí nastavení|Velmi nízké detaily (nejrychlejší)|Nízké detaily (rychlejší)|Normální detaily|Vysoké detaily (hezčí)|Velmi vysoké detaily (nejhezčí)|Vypnout (rychlejší)|Zapnout (hezčí)|Komentář vývojářů|Úroveň detailů:|Displacement textury:|Jazyk hry:|Spustit s:|Není vybrán žádný doplněk.|Vyhledat doplňky|Popis:|Požadavky:|Hrát|Ukončit| a další %d|Žádné doplňky|od|Hra více hráčů|Režim:|Jeden hráč|Hostovat kooperaci|Připojit se ke kooperaci|Hráči (včetně hostitele):|Počáteční mapa:|Host / IP:|UDP port:|Obtížnost:|Povolit cheaty|Motiv:|Tmavý|Světlý";
                    break;
                case "pl":
                    data = "Użyj ostatnich ustawień|Przywróć ustawienia domyślne|Bardzo niskie detale (najszybciej)|Niskie detale (szybciej)|Normalne detale|Wysokie detale (ładniej)|Bardzo wysokie detale (najładniej)|Wyłącz (szybciej)|Włącz (ładniej)|Komentarz twórców|Poziom detali:|Tekstury przemieszczeń:|Język gry:|Uruchom z:|Nie wybrano dodatku.|Wyszukaj dodatki|Opis:|Wymagania:|Graj|Wyjdź| i jeszcze %d|Bez dodatków|autor|Gra wieloosobowa|Tryb:|Jeden gracz|Hostuj kooperację|Dołącz do kooperacji|Gracze (łącznie z hostem):|Mapa startowa:|Host / IP:|Port UDP:|Poziom trudności:|Zezwól na kody|Motyw:|Ciemny|Jasny";
                    break;
            }

            if (data == null) {
                return;
            }
            string[] values = data.Split('|');
            for (int index = 0; index < keys.Length && index < values.Length; index++) {
                translations[keys[index]] = values[index];
            }
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
            if (!string.IsNullOrEmpty(id) && !string.IsNullOrEmpty(value)) {
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
