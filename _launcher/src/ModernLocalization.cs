using System;
using System.Collections.Generic;

namespace BladeOfAgonyLauncher
{
    internal sealed partial class ModernLocalization
    {
        private readonly Dictionary<string, string> values =
            new Dictionary<string, string>(StringComparer.Ordinal);

        internal static ModernLocalization Load(string language)
        {
            ModernLocalization result = new ModernLocalization();
            string[] keys = {
                "Start", "Add-ons", "Multiplayer", "Diagnostics",
                "Interface language", "Design", "Launch", "Exit",
                "Quick launch", "Start mode", "Main menu", "Start campaign",
                "Chapter", "Mission", "Difficulty", "Graphics",
                "Detail preset", "Displacement textures", "Game language",
                "Developer commentary", "Selected add-ons", "No add-ons",
                "Scan add-ons", "Move up", "Move down", "Description",
                "Requirements", "Compatibility", "Single player", "Host co-op",
                "Join co-op", "Players", "Host or IP", "UDP port",
                "Allow cheats", "Engine", "Main game", "Content source",
                "Ready", "Warning", "Error", "Not found", "Detected",
                "Add-ons are disabled in multiplayer.",
                "Only UZDoom 5.0.3 or newer and boa.ipk3 are checked and launched.",
                "Open game folder", "Copy command", "Command line",
                "Add-on load order", "No compatibility issues detected.",
                "Select an add-on to view its details.",
                "Game files are ready.", "Game files need attention.",
                "selected", "Main menu will be shown", "Direct campaign start",
                "Current settings", "Refresh", "Version", "Status"
            };
            string[][] languages = {
                new[] { "en",
                    "Start|Add-ons|Multiplayer|Diagnostics|Interface language|Design|Play|Exit|Quick Launch|Start mode|Main menu|Start campaign|Chapter|Mission|Difficulty|Graphics|Detail preset|Displacement textures|Game language|Developer commentary|Selected add-ons|No add-ons|Scan add-ons|Move up|Move down|Description|Requirements|Compatibility|Single player|Host co-op|Join co-op|Players|Host or IP|UDP port|Allow cheats|Engine|Main game|Content source|Ready|Warning|Error|Not found|Detected|Add-ons are disabled in multiplayer.|Only UZDoom 5.0.3 or newer and boa.ipk3 are checked and launched.|Open game folder|Copy command|Command line|Add-on load order|No compatibility issues detected.|Select an add-on to view its details.|Game files are ready.|Game files need attention.|selected|Main menu will be shown|Direct campaign start|Current settings|Refresh|Version|Status" },
                new[] { "de",
                    "Start|Add-ons|Mehrspieler|Diagnose|Interfacesprache|Design|Spielen|Beenden|Schnellstart|Startmodus|Hauptmen\u00fc|Kampagne starten|Kapitel|Mission|Schwierigkeit|Grafik|Detailstufe|Displacement-Texturen|Spielsprache|Entwicklerkommentar|Ausgew\u00e4hlte Add-ons|Keine Add-ons|Add-ons scannen|Nach oben|Nach unten|Beschreibung|Voraussetzungen|Kompatibilit\u00e4t|Einzelspieler|Co-op hosten|Co-op beitreten|Spieler|Host oder IP|UDP-Port|Cheats erlauben|Engine|Hauptspiel|Inhaltsquelle|Bereit|Warnung|Fehler|Nicht gefunden|Erkannt|Add-ons sind im Mehrspielermodus deaktiviert.|Es werden nur UZDoom ab Version 5.0.3 und boa.ipk3 gepr\u00fcft und gestartet.|Spielordner \u00f6ffnen|Befehl kopieren|Kommandozeile|Add-on-Ladereihenfolge|Keine Kompatibilit\u00e4tsprobleme erkannt.|W\u00e4hle ein Add-on, um Details anzuzeigen.|Die Spieldateien sind bereit.|Die Spieldateien ben\u00f6tigen Aufmerksamkeit.|ausgew\u00e4hlt|Das Hauptmen\u00fc wird angezeigt|Direkter Kampagnenstart|Aktuelle Einstellungen|Aktualisieren|Version|Status" },
                new[] { "es",
                    "Inicio|Add-ons|Multijugador|Diagn\u00f3stico|Idioma de interfaz|Dise\u00f1o|Jugar|Salir|Inicio r\u00e1pido|Modo de inicio|Men\u00fa principal|Iniciar campa\u00f1a|Cap\u00edtulo|Misi\u00f3n|Dificultad|Gr\u00e1ficos|Nivel de detalle|Texturas de desplazamiento|Idioma del juego|Comentarios del desarrollador|Add-ons seleccionados|Sin add-ons|Buscar add-ons|Subir|Bajar|Descripci\u00f3n|Requisitos|Compatibilidad|Un jugador|Alojar cooperativo|Unirse al cooperativo|Jugadores|Host o IP|Puerto UDP|Permitir trucos|Motor|Juego principal|Fuente de contenido|Listo|Advertencia|Error|No encontrado|Detectado|Los add-ons se desactivan en multijugador.|Solo se comprueban e inician UZDoom 5.0.3 o posterior y boa.ipk3.|Abrir carpeta del juego|Copiar comando|L\u00ednea de comandos|Orden de carga|No se detectaron problemas de compatibilidad.|Selecciona un add-on para ver sus detalles.|Los archivos del juego est\u00e1n listos.|Los archivos del juego requieren atenci\u00f3n.|seleccionados|Se mostrar\u00e1 el men\u00fa principal|Inicio directo de campa\u00f1a|Ajustes actuales|Actualizar|Versi\u00f3n|Estado" },
                new[] { "fr",
                    "D\u00e9marrer|Add-ons|Multijoueur|Diagnostic|Langue de l'interface|Th\u00e8me|Jouer|Quitter|Lancement rapide|Mode de d\u00e9marrage|Menu principal|D\u00e9marrer la campagne|Chapitre|Mission|Difficult\u00e9|Graphismes|Niveau de d\u00e9tail|Textures de d\u00e9placement|Langue du jeu|Commentaires des d\u00e9veloppeurs|Add-ons s\u00e9lectionn\u00e9s|Aucun add-on|Rechercher les add-ons|Monter|Descendre|Description|Pr\u00e9requis|Compatibilit\u00e9|Un joueur|H\u00e9berger la coop|Rejoindre la coop|Joueurs|H\u00f4te ou IP|Port UDP|Autoriser les codes|Moteur|Jeu principal|Source du contenu|Pr\u00eat|Avertissement|Erreur|Introuvable|D\u00e9tect\u00e9|Les add-ons sont d\u00e9sactiv\u00e9s en multijoueur.|Seuls UZDoom 5.0.3 ou ult\u00e9rieur et boa.ipk3 sont v\u00e9rifi\u00e9s et lanc\u00e9s.|Ouvrir le dossier du jeu|Copier la commande|Ligne de commande|Ordre de chargement|Aucun probl\u00e8me de compatibilit\u00e9 d\u00e9tect\u00e9.|S\u00e9lectionnez un add-on pour afficher ses d\u00e9tails.|Les fichiers du jeu sont pr\u00eats.|Les fichiers du jeu n\u00e9cessitent votre attention.|s\u00e9lectionn\u00e9s|Le menu principal sera affich\u00e9|D\u00e9marrage direct de la campagne|Param\u00e8tres actuels|Actualiser|Version|\u00c9tat" },
                new[] { "it",
                    "Avvio|Add-on|Multigiocatore|Diagnostica|Lingua interfaccia|Tema|Gioca|Esci|Avvio rapido|Modalit\u00e0 di avvio|Menu principale|Avvia campagna|Capitolo|Missione|Difficolt\u00e0|Grafica|Livello dettagli|Texture di spostamento|Lingua del gioco|Commenti sviluppatori|Add-on selezionati|Nessun add-on|Cerca add-on|Sposta su|Sposta gi\u00f9|Descrizione|Requisiti|Compatibilit\u00e0|Giocatore singolo|Ospita cooperativa|Partecipa alla cooperativa|Giocatori|Host o IP|Porta UDP|Consenti trucchi|Motore|Gioco principale|Fonte contenuti|Pronto|Avviso|Errore|Non trovato|Rilevato|Gli add-on sono disattivati in multigiocatore.|Vengono controllati e avviati solo UZDoom 5.0.3 o successivo e boa.ipk3.|Apri cartella di gioco|Copia comando|Riga di comando|Ordine di caricamento|Nessun problema di compatibilit\u00e0 rilevato.|Seleziona un add-on per visualizzarne i dettagli.|I file di gioco sono pronti.|I file di gioco richiedono attenzione.|selezionati|Verr\u00e0 mostrato il menu principale|Avvio diretto campagna|Impostazioni correnti|Aggiorna|Versione|Stato" },
                new[] { "ptb",
                    "In\u00edcio|Add-ons|Multijogador|Diagn\u00f3stico|Idioma da interface|Tema|Jogar|Sair|In\u00edcio r\u00e1pido|Modo de in\u00edcio|Menu principal|Iniciar campanha|Cap\u00edtulo|Miss\u00e3o|Dificuldade|Gr\u00e1ficos|N\u00edvel de detalhe|Texturas de deslocamento|Idioma do jogo|Coment\u00e1rios do desenvolvedor|Add-ons selecionados|Sem add-ons|Procurar add-ons|Mover para cima|Mover para baixo|Descri\u00e7\u00e3o|Requisitos|Compatibilidade|Um jogador|Hospedar cooperativo|Entrar no cooperativo|Jogadores|Host ou IP|Porta UDP|Permitir cheats|Motor|Jogo principal|Fonte do conte\u00fado|Pronto|Aviso|Erro|N\u00e3o encontrado|Detectado|Os add-ons s\u00e3o desativados no multijogador.|Apenas UZDoom 5.0.3 ou posterior e boa.ipk3 s\u00e3o verificados e iniciados.|Abrir pasta do jogo|Copiar comando|Linha de comando|Ordem de carregamento|Nenhum problema de compatibilidade detectado.|Selecione um add-on para ver seus detalhes.|Os arquivos do jogo est\u00e3o prontos.|Os arquivos do jogo precisam de aten\u00e7\u00e3o.|selecionados|O menu principal ser\u00e1 exibido|In\u00edcio direto da campanha|Configura\u00e7\u00f5es atuais|Atualizar|Vers\u00e3o|Status" },
                new[] { "tr",
                    "Ba\u015flat|Eklentiler|\u00c7ok oyunculu|Tan\u0131lama|Aray\u00fcz dili|Tema|Oyna|\u00c7\u0131k|H\u0131zl\u0131 ba\u015flat|Ba\u015flatma modu|Ana men\u00fc|Kampanyay\u0131 ba\u015flat|B\u00f6l\u00fcm|G\u00f6rev|Zorluk|Grafik|Ayr\u0131nt\u0131 d\u00fczeyi|Yer de\u011fi\u015ftirme dokular\u0131|Oyun dili|Geli\u015ftirici yorumlar\u0131|Se\u00e7ili eklentiler|Eklenti yok|Eklentileri tara|Yukar\u0131 ta\u015f\u0131|A\u015fa\u011f\u0131 ta\u015f\u0131|A\u00e7\u0131klama|Gereksinimler|Uyumluluk|Tek oyunculu|Co-op bar\u0131nd\u0131r|Co-op'a kat\u0131l|Oyuncular|Sunucu veya IP|UDP portu|Hilelere izin ver|Motor|Ana oyun|\u0130\u00e7erik kayna\u011f\u0131|Haz\u0131r|Uyar\u0131|Hata|Bulunamad\u0131|Alg\u0131land\u0131|\u00c7ok oyunculuda eklentiler devre d\u0131\u015f\u0131d\u0131r.|Yaln\u0131zca UZDoom 5.0.3 veya \u00fczeri ve boa.ipk3 denetlenir ve ba\u015flat\u0131l\u0131r.|Oyun klas\u00f6r\u00fcn\u00fc a\u00e7|Komutu kopyala|Komut sat\u0131r\u0131|Eklenti y\u00fckleme s\u0131ras\u0131|Uyumluluk sorunu alg\u0131lanmad\u0131.|Ayr\u0131nt\u0131lar i\u00e7in bir eklenti se\u00e7in.|Oyun dosyalar\u0131 haz\u0131r.|Oyun dosyalar\u0131yla ilgilenilmesi gerekiyor.|se\u00e7ili|Ana men\u00fc g\u00f6sterilecek|Do\u011frudan kampanya ba\u015flatma|Ge\u00e7erli ayarlar|Yenile|S\u00fcr\u00fcm|Durum" },
                new[] { "cs",
                    "Start|Dopl\u0148ky|Hra pro v\u00edce hr\u00e1\u010d\u016f|Diagnostika|Jazyk rozhran\u00ed|Motiv|Hr\u00e1t|Ukon\u010dit|Rychl\u00e9 spu\u0161t\u011bn\u00ed|Re\u017eim spu\u0161t\u011bn\u00ed|Hlavn\u00ed nab\u00eddka|Spustit kampa\u0148|Kapitola|Mise|Obt\u00ed\u017enost|Grafika|\u00darove\u0148 detail\u016f|Displacement textury|Jazyk hry|Koment\u00e1\u0159 v\u00fdvoj\u00e1\u0159\u016f|Vybran\u00e9 dopl\u0148ky|\u017d\u00e1dn\u00e9 dopl\u0148ky|Vyhledat dopl\u0148ky|Posunout nahoru|Posunout dol\u016f|Popis|Po\u017eadavky|Kompatibilita|Jeden hr\u00e1\u010d|Hostovat kooperaci|P\u0159ipojit se ke kooperaci|Hr\u00e1\u010di|Hostitel nebo IP|UDP port|Povolit cheaty|Engine|Hlavn\u00ed hra|Zdroj obsahu|P\u0159ipraveno|Varov\u00e1n\u00ed|Chyba|Nenalezeno|Zji\u0161t\u011bno|V re\u017eimu pro v\u00edce hr\u00e1\u010d\u016f jsou dopl\u0148ky zak\u00e1z\u00e1ny.|Kontroluj\u00ed a spou\u0161t\u011bj\u00ed se pouze UZDoom 5.0.3 nebo nov\u011bj\u0161\u00ed a boa.ipk3.|Otev\u0159\u00edt slo\u017eku hry|Kop\u00edrovat p\u0159\u00edkaz|P\u0159\u00edkazov\u00fd \u0159\u00e1dek|Po\u0159ad\u00ed na\u010d\u00edt\u00e1n\u00ed|Nebyly zji\u0161t\u011bny probl\u00e9my s kompatibilitou.|Vyberte dopln\u011bk pro zobrazen\u00ed podrobnost\u00ed.|Hern\u00ed soubory jsou p\u0159ipraveny.|Hern\u00ed soubory vy\u017eaduj\u00ed pozornost.|vybr\u00e1no|Zobraz\u00ed se hlavn\u00ed nab\u00eddka|P\u0159\u00edm\u00e9 spu\u0161t\u011bn\u00ed kampan\u011b|Aktu\u00e1ln\u00ed nastaven\u00ed|Aktualizovat|Verze|Stav" },
                new[] { "pl",
                    "Start|Dodatki|Gra wieloosobowa|Diagnostyka|J\u0119zyk interfejsu|Motyw|Graj|Wyjd\u017a|Szybki start|Tryb uruchamiania|Menu g\u0142\u00f3wne|Rozpocznij kampani\u0119|Rozdzia\u0142|Misja|Poziom trudno\u015bci|Grafika|Poziom detali|Tekstury przemieszcze\u0144|J\u0119zyk gry|Komentarz tw\u00f3rc\u00f3w|Wybrane dodatki|Bez dodatk\u00f3w|Skanuj dodatki|Przenie\u015b w g\u00f3r\u0119|Przenie\u015b w d\u00f3\u0142|Opis|Wymagania|Zgodno\u015b\u0107|Jeden gracz|Hostuj kooperacj\u0119|Do\u0142\u0105cz do kooperacji|Gracze|Host lub IP|Port UDP|Zezw\u00f3l na kody|Silnik|G\u0142\u00f3wna gra|\u0179r\u00f3d\u0142o tre\u015bci|Gotowe|Ostrze\u017cenie|B\u0142\u0105d|Nie znaleziono|Wykryto|Dodatki s\u0105 wy\u0142\u0105czone w grze wieloosobowej.|Sprawdzane i uruchamiane s\u0105 tylko UZDoom 5.0.3 lub nowszy i boa.ipk3.|Otw\u00f3rz folder gry|Kopiuj polecenie|Wiersz polece\u0144|Kolejno\u015b\u0107 \u0142adowania|Nie wykryto problem\u00f3w ze zgodno\u015bci\u0105.|Wybierz dodatek, aby zobaczy\u0107 szczeg\u00f3\u0142y.|Pliki gry s\u0105 gotowe.|Pliki gry wymagaj\u0105 uwagi.|wybrano|Zostanie wy\u015bwietlone menu g\u0142\u00f3wne|Bezpo\u015bredni start kampanii|Bie\u017c\u0105ce ustawienia|Od\u015bwie\u017c|Wersja|Stan" },
                new[] { "ru",
                    "\u0417\u0430\u043f\u0443\u0441\u043a|\u0414\u043e\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u044f|\u0421\u0435\u0442\u0435\u0432\u0430\u044f \u0438\u0433\u0440\u0430|\u0414\u0438\u0430\u0433\u043d\u043e\u0441\u0442\u0438\u043a\u0430|\u042f\u0437\u044b\u043a \u0438\u043d\u0442\u0435\u0440\u0444\u0435\u0439\u0441\u0430|\u0422\u0435\u043c\u0430|\u0418\u0433\u0440\u0430\u0442\u044c|\u0412\u044b\u0445\u043e\u0434|\u0411\u044b\u0441\u0442\u0440\u044b\u0439 \u0437\u0430\u043f\u0443\u0441\u043a|\u0420\u0435\u0436\u0438\u043c \u0437\u0430\u043f\u0443\u0441\u043a\u0430|\u0413\u043b\u0430\u0432\u043d\u043e\u0435 \u043c\u0435\u043d\u044e|\u041d\u0430\u0447\u0430\u0442\u044c \u043a\u0430\u043c\u043f\u0430\u043d\u0438\u044e|\u0413\u043b\u0430\u0432\u0430|\u041c\u0438\u0441\u0441\u0438\u044f|\u0421\u043b\u043e\u0436\u043d\u043e\u0441\u0442\u044c|\u0413\u0440\u0430\u0444\u0438\u043a\u0430|\u0423\u0440\u043e\u0432\u0435\u043d\u044c \u0434\u0435\u0442\u0430\u043b\u0435\u0439|\u0422\u0435\u043a\u0441\u0442\u0443\u0440\u044b \u0441\u043c\u0435\u0449\u0435\u043d\u0438\u044f|\u042f\u0437\u044b\u043a \u0438\u0433\u0440\u044b|\u041a\u043e\u043c\u043c\u0435\u043d\u0442\u0430\u0440\u0438\u0438 \u0440\u0430\u0437\u0440\u0430\u0431\u043e\u0442\u0447\u0438\u043a\u043e\u0432|\u0412\u044b\u0431\u0440\u0430\u043d\u043d\u044b\u0435 \u0434\u043e\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u044f|\u0411\u0435\u0437 \u0434\u043e\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u0439|\u0421\u043a\u0430\u043d\u0438\u0440\u043e\u0432\u0430\u0442\u044c|\u0412\u0432\u0435\u0440\u0445|\u0412\u043d\u0438\u0437|\u041e\u043f\u0438\u0441\u0430\u043d\u0438\u0435|\u0422\u0440\u0435\u0431\u043e\u0432\u0430\u043d\u0438\u044f|\u0421\u043e\u0432\u043c\u0435\u0441\u0442\u0438\u043c\u043e\u0441\u0442\u044c|\u041e\u0434\u0438\u043d\u043e\u0447\u043d\u0430\u044f \u0438\u0433\u0440\u0430|\u0421\u043e\u0437\u0434\u0430\u0442\u044c \u043a\u043e\u043e\u043f\u0435\u0440\u0430\u0442\u0438\u0432|\u041f\u043e\u0434\u043a\u043b\u044e\u0447\u0438\u0442\u044c\u0441\u044f|\u0418\u0433\u0440\u043e\u043a\u0438|\u0425\u043e\u0441\u0442 \u0438\u043b\u0438 IP|UDP-\u043f\u043e\u0440\u0442|\u0420\u0430\u0437\u0440\u0435\u0448\u0438\u0442\u044c \u0447\u0438\u0442\u044b|\u0414\u0432\u0438\u0436\u043e\u043a|\u041e\u0441\u043d\u043e\u0432\u043d\u0430\u044f \u0438\u0433\u0440\u0430|\u0418\u0441\u0442\u043e\u0447\u043d\u0438\u043a \u043a\u043e\u043d\u0442\u0435\u043d\u0442\u0430|\u0413\u043e\u0442\u043e\u0432\u043e|\u041f\u0440\u0435\u0434\u0443\u043f\u0440\u0435\u0436\u0434\u0435\u043d\u0438\u0435|\u041e\u0448\u0438\u0431\u043a\u0430|\u041d\u0435 \u043d\u0430\u0439\u0434\u0435\u043d\u043e|\u041e\u0431\u043d\u0430\u0440\u0443\u0436\u0435\u043d\u043e|\u0412 \u0441\u0435\u0442\u0435\u0432\u043e\u0439 \u0438\u0433\u0440\u0435 \u0434\u043e\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u044f \u043e\u0442\u043a\u043b\u044e\u0447\u0435\u043d\u044b.|\u041f\u0440\u043e\u0432\u0435\u0440\u044f\u044e\u0442\u0441\u044f \u0438 \u0437\u0430\u043f\u0443\u0441\u043a\u0430\u044e\u0442\u0441\u044f \u0442\u043e\u043b\u044c\u043a\u043e UZDoom 5.0.3 \u0438\u043b\u0438 \u043d\u043e\u0432\u0435\u0435 \u0438 boa.ipk3.|\u041e\u0442\u043a\u0440\u044b\u0442\u044c \u043f\u0430\u043f\u043a\u0443 \u0438\u0433\u0440\u044b|\u041a\u043e\u043f\u0438\u0440\u043e\u0432\u0430\u0442\u044c \u043a\u043e\u043c\u0430\u043d\u0434\u0443|\u041a\u043e\u043c\u0430\u043d\u0434\u043d\u0430\u044f \u0441\u0442\u0440\u043e\u043a\u0430|\u041f\u043e\u0440\u044f\u0434\u043e\u043a \u0437\u0430\u0433\u0440\u0443\u0437\u043a\u0438|\u041f\u0440\u043e\u0431\u043b\u0435\u043c \u0441 \u0441\u043e\u0432\u043c\u0435\u0441\u0442\u0438\u043c\u043e\u0441\u0442\u044c\u044e \u043d\u0435 \u043e\u0431\u043d\u0430\u0440\u0443\u0436\u0435\u043d\u043e.|\u0412\u044b\u0431\u0435\u0440\u0438\u0442\u0435 \u0434\u043e\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u0435 \u0434\u043b\u044f \u043f\u0440\u043e\u0441\u043c\u043e\u0442\u0440\u0430.|\u0424\u0430\u0439\u043b\u044b \u0438\u0433\u0440\u044b \u0433\u043e\u0442\u043e\u0432\u044b.|\u0424\u0430\u0439\u043b\u044b \u0438\u0433\u0440\u044b \u0442\u0440\u0435\u0431\u0443\u044e\u0442 \u0432\u043d\u0438\u043c\u0430\u043d\u0438\u044f.|\u0432\u044b\u0431\u0440\u0430\u043d\u043e|\u0411\u0443\u0434\u0435\u0442 \u043f\u043e\u043a\u0430\u0437\u0430\u043d\u043e \u0433\u043b\u0430\u0432\u043d\u043e\u0435 \u043c\u0435\u043d\u044e|\u041f\u0440\u044f\u043c\u043e\u0439 \u0437\u0430\u043f\u0443\u0441\u043a \u043a\u0430\u043c\u043f\u0430\u043d\u0438\u0438|\u0422\u0435\u043a\u0443\u0449\u0438\u0435 \u043d\u0430\u0441\u0442\u0440\u043e\u0439\u043a\u0438|\u041e\u0431\u043d\u043e\u0432\u0438\u0442\u044c|\u0412\u0435\u0440\u0441\u0438\u044f|\u0421\u0442\u0430\u0442\u0443\u0441" }
            };

            string normalized = LauncherOptions.NormalizeInterfaceLanguage(language);
            foreach (string[] entry in languages) {
                if (entry[0] != normalized) {
                    continue;
                }
                string[] translated = entry[1].Split('|');
                for (int index = 0; index < keys.Length && index < translated.Length; index++) {
                    result.values[keys[index]] = translated[index];
                }
                ApplyV25Translations(result, normalized);
                ApplyV265Translations(result, normalized);
                ApplyQuickLaunchTranslations(result, normalized);
                ApplyCampaignSelectionTranslations(result, normalized);
                ApplyLaunchActionTranslations(result, normalized);
                ApplyReadinessTranslations(result, normalized);
                result.ApplyReleaseTranslations(normalized);
                result.LoadPresetDescriptions(normalized);
                result.values["CoopMissionStartHint"] = CoopMissionStartHint(normalized);
                string[] debug = MissionDebugLabels(normalized);
                result.values["MissionDebugMode"] = debug[0];
                result.values["MissionDebugWarning"] = debug[1];
                return result;
            }
            return Load("en");
        }

        private static string[] MissionDebugLabels(string language)
        {
            switch (language) {
                case "de": return new[] { "Debugmodus (Einzelspieler)", "Öffnet den geheimen Raum im HQ-Briefingraum: Dort die Mission wählen, dann Millers Briefing anhören. Direktstarts (auch Keen) überspringen das HQ und können den Kampagnenfortschritt stören." };
                case "es": return new[] { "Modo de depuración (un jugador)", "Abre la sala secreta de la sala de reuniones del cuartel: elige allí la misión y escucha a Miller. El inicio directo (incluido Keen) omite el cuartel y puede romper la campaña." };
                case "fr": return new[] { "Mode de débogage (solo)", "Ouvre la pièce secrète de la salle de briefing du QG : choisissez-y la mission, puis écoutez Miller. Le lancement direct (Keen compris) saute le QG et peut bloquer la campagne." };
                case "it": return new[] { "Modalità debug (giocatore singolo)", "Apre la stanza segreta nella sala briefing del quartier generale: scegli lì la missione, poi ascolta Miller. L’avvio diretto (anche Keen) salta il quartier generale e può bloccare la campagna." };
                case "ptb": return new[] { "Modo de depuração (um jogador)", "Abre a sala secreta na sala de instruções do QG: escolha a missão lá e ouça Miller. O início direto (inclusive Keen) pula o QG e pode prejudicar a campanha." };
                case "ru": return new[] { "Режим отладки (одиночная игра)", "Открывает тайную комнату в зале инструктажа штаба: выберите там миссию и выслушайте Миллера. Прямой запуск (включая Keen) минует штаб и может нарушить ход кампании." };
                case "cs": return new[] { "Ladicí režim (jeden hráč)", "Otevře tajnou místnost v poradně na velitelství: tam vyber misi a pak si poslechni Millera. Přímý start (včetně misí Keen) přeskočí velitelství a může narušit kampaň." };
                case "pl": return new[] { "Tryb debugowania (jeden gracz)", "Otwiera tajny pokój w sali odpraw w sztabie: wybierz tam misję, a potem wysłuchaj odprawy Millera. Bezpośredni start (także misji Keen) omija sztab i może zakłócić kampanię." };
                case "tr": return new[] { "Hata ayıklama modu (tek oyunculu)", "Karargâhtaki brifing salonunun gizli odasını açar: görevi orada seçip Miller’ın brifingini dinle. Doğrudan başlatma (Keen dâhil) karargâhı atlar ve harekâtın ilerleyişini bozabilir." };
                default: return new[] { "Debug mode (single-player)", "Unlocks the secret room in the HQ briefing room: choose a mission there, then hear Miller’s briefing. Direct starts (including Keen) bypass HQ and can break campaign progression." };
            }
        }

        private static string CoopMissionStartHint(string language)
        {
            switch (language) {
                case "de": return "Startet eine neue Koop-Kampagne im Hauptquartier und nehmt dort den Auftrag an. Beim direkten Missionsstart können Briefings, Ausrüstung und Kampagnenfortschritt fehlen.";
                case "es": return "Para iniciar una campaña cooperativa, empezad en el cuartel general y aceptad allí la misión. El inicio directo puede omitir instrucciones, equipo y progreso de campaña.";
                case "fr": return "Pour une nouvelle campagne en coopération, partez du QG et acceptez-y la mission. Un départ direct en mission peut vous priver du briefing, de votre équipement et de la progression de campagne.";
                case "it": return "Per una nuova campagna cooperativa, partite dal quartier generale e accettate la missione. Avviarla direttamente può far saltare briefing, equipaggiamento e progressi della campagna.";
                case "ptb": return "Para começar uma campanha cooperativa, vá ao quartel-general e aceite a missão lá. Iniciar uma missão diretamente pode pular instruções, equipamentos e progresso da campanha.";
                case "ru": return "Начинайте новую совместную кампанию в штабе и получите там задание. При запуске сразу с миссии можно пропустить инструктаж, снаряжение и этапы кампании.";
                case "cs": return "Novou kooperativní kampaň začněte na velitelství a tam přijměte úkol. Přímým spuštěním mise můžete přeskočit instruktáž, výbavu i část postupu kampaní.";
                case "pl": return "Nową kampanię w trybie współpracy rozpocznijcie w kwaterze głównej i tam przyjmijcie zadanie. Bezpośredni start misji może pominąć odprawę, wyposażenie i postępy w kampanii.";
                case "tr": return "Yeni bir eşli harekâta karargâhta başlayın ve görevi orada alın. Doğrudan görevden başlamak brifingi, teçhizatı ve harekâtın bazı aşamalarını atlayabilir.";
                default: return "For a new co-op campaign, start at headquarters and take the mission briefing there. Starting directly in a mission can skip briefings, equipment and campaign progress.";
            }
        }

        private void LoadPresetDescriptions(string language)
        {
            string[] descriptions;
            switch (language) {
                case "en": descriptions = new[] { "Keeps your current UZDoom and Blade of Agony graphics settings; no detail profile is loaded.", "Standard appearance: smoke and reflections on, up to 512 particle actors.", "For slower PCs: short vegetation range, no smoke or reflections, up to 32 particle actors.", "Shows vegetation farther away than Very low. Smoke and reflections stay off; up to 64 particle actors.", "Smoke and reflections return. Grass is visible farther away; up to 128 particle actors.", "Long vegetation range, shadows and reflections; up to 512 particle actors.", "Same vegetation range and particle limit as High, with stronger anti-aliasing and longer-lasting debris." }; break;
                case "de": descriptions = new[] { "Behält deine aktuellen Grafikeinstellungen bei. Es wird kein Detailprofil geladen.", "Standarddarstellung: Rauch und Spiegelungen sind an, bis zu 512 Partikelobjekte.", "Für langsamere PCs: kurze Vegetationssichtweite, kein Rauch, keine Spiegelungen, bis zu 32 Partikelobjekte.", "Vegetation ist weiter sichtbar als bei „Sehr niedrig“. Rauch und Spiegelungen bleiben aus, bis zu 64 Partikelobjekte.", "Mit Rauch und Spiegelungen. Gras ist weiter sichtbar, bis zu 128 Partikelobjekte.", "Große Vegetationssichtweite, Schatten und Spiegelungen, bis zu 512 Partikelobjekte.", "Gleiche Vegetationssichtweite und Partikelgrenze wie bei „Hoch“, mit stärkerer Kantenglättung und länger sichtbaren Trümmern." }; break;
                case "es": descriptions = new[] { "Conserva los ajustes gráficos actuales sin cargar un perfil de detalle.", "Aspecto estándar: humo y reflejos activados, hasta 512 objetos de partículas.", "Para equipos modestos: vegetación cercana, sin humo ni reflejos, hasta 32 objetos de partículas.", "La vegetación se ve más lejos que en Muy bajo. Sin humo ni reflejos, hasta 64 objetos de partículas.", "Vuelven el humo y los reflejos. La hierba se ve más lejos, hasta 128 objetos de partículas.", "Vegetación visible a gran distancia, sombras y reflejos, hasta 512 objetos de partículas.", "Misma distancia de vegetación y límite de partículas que en Alto, con más suavizado de bordes y escombros que duran más." }; break;
                case "fr": descriptions = new[] { "Conserve les réglages graphiques actuels sans charger de profil de détail.", "Rendu standard : fumée et reflets activés, jusqu’à 512 objets de particules.", "Pour les PC modestes : végétation proche, ni fumée ni reflets, jusqu’à 32 objets de particules.", "La végétation est visible de plus loin qu’au niveau minimal. Ni fumée ni reflets, jusqu’à 64 objets de particules.", "La fumée et les reflets sont activés. L’herbe est visible de plus loin, jusqu’à 128 objets de particules.", "Végétation visible au loin, ombres et reflets, jusqu’à 512 objets de particules.", "Même portée de végétation et même limite de particules qu’au niveau élevé ; anticrénelage renforcé et débris visibles plus longtemps." }; break;
                case "it": descriptions = new[] { "Mantiene le impostazioni grafiche attuali senza caricare un profilo di dettaglio.", "Aspetto standard: fumo e riflessi attivi, fino a 512 oggetti particellari.", "Per PC meno potenti: vegetazione vicina, niente fumo o riflessi, fino a 32 oggetti particellari.", "La vegetazione è visibile più lontano rispetto al livello minimo. Niente fumo o riflessi, fino a 64 oggetti particellari.", "Tornano fumo e riflessi. L’erba è visibile più lontano, fino a 128 oggetti particellari.", "Vegetazione visibile a lunga distanza, ombre e riflessi, fino a 512 oggetti particellari.", "Stessa distanza per la vegetazione e stesso limite di particelle del livello alto, con bordi più smussati e detriti visibili più a lungo." }; break;
                case "ptb": descriptions = new[] { "Mantém as configurações gráficas atuais sem carregar um perfil de detalhes.", "Visual padrão: fumaça e reflexos ativados, até 512 objetos de partículas.", "Para PCs mais lentos: vegetação próxima, sem fumaça ou reflexos, até 32 objetos de partículas.", "A vegetação aparece mais longe do que no nível mínimo. Sem fumaça ou reflexos, até 64 objetos de partículas.", "A fumaça e os reflexos voltam. A grama aparece mais longe, até 128 objetos de partículas.", "Vegetação visível a longa distância, sombras e reflexos, até 512 objetos de partículas.", "Mesmo alcance da vegetação e limite de partículas do nível alto, com mais suavização de bordas e detritos visíveis por mais tempo." }; break;
                case "tr": descriptions = new[] { "Mevcut grafik ayarları korunur; ayrıntı profili yüklenmez.", "Standart görünüm: duman ve yansımalar açık, en fazla 512 parçacık nesnesi.", "Yavaş bilgisayarlar için: bitkiler yalnızca yakında görünür. Duman ve yansıma yok, en fazla 32 parçacık nesnesi.", "Bitkiler en düşük ayara göre daha uzaktan görünür. Duman ve yansımalar kapalı, en fazla 64 parçacık nesnesi.", "Duman ve yansımalar açık. Çimler daha uzaktan görünür, en fazla 128 parçacık nesnesi.", "Bitkiler uzaktan görünür, gölgeler ve yansımalar açık, en fazla 512 parçacık nesnesi.", "Bitki görüş mesafesi ve parçacık sınırı yüksek ayarla aynı. Kenar yumuşatma daha güçlü, döküntüler daha uzun süre görünür." }; break;
                case "cs": descriptions = new[] { "Zachová současné nastavení grafiky a nenačte žádný profil detailů.", "Standardní vzhled: kouř a odrazy jsou zapnuté, až 512 částicových objektů.", "Pro pomalejší počítače: vegetace jen zblízka, bez kouře a odrazů, až 32 částicových objektů.", "Vegetace je vidět dále než při nejnižším nastavení. Bez kouře a odrazů, až 64 částicových objektů.", "Kouř a odrazy jsou zapnuté. Tráva je vidět dále, až 128 částicových objektů.", "Vegetace je vidět do dálky, stíny a odrazy jsou zapnuté, až 512 částicových objektů.", "Stejný dohled vegetace a limit částic jako u vysokých detailů, výraznější vyhlazování hran a déle viditelné úlomky." }; break;
                case "pl": descriptions = new[] { "Zachowuje obecne ustawienia grafiki bez wczytywania profilu szczegółowości.", "Standardowy wygląd: dym i odbicia włączone, do 512 obiektów cząsteczkowych.", "Dla wolniejszych komputerów: roślinność tylko z bliska, bez dymu i odbić, do 32 obiektów cząsteczkowych.", "Roślinność widać dalej niż przy najniższych detalach. Bez dymu i odbić, do 64 obiektów cząsteczkowych.", "Dym i odbicia są włączone. Trawę widać z większej odległości, do 128 obiektów cząsteczkowych.", "Daleki zasięg roślinności, cienie i odbicia, do 512 obiektów cząsteczkowych.", "Zasięg roślinności i limit cząstek jak przy wysokich detalach, mocniejsze wygładzanie krawędzi i dłużej widoczne odłamki." }; break;
                case "ru": descriptions = new[] { "Сохраняет текущие настройки графики без загрузки профиля детализации.", "Стандартный вид: дым и отражения включены, до 512 объектов частиц.", "Для слабых ПК: растительность видна только вблизи. Без дыма и отражений, до 32 объектов частиц.", "Растительность видна дальше, чем на минимальных настройках. Без дыма и отражений, до 64 объектов частиц.", "Включены дым и отражения. Трава видна дальше, до 128 объектов частиц.", "Большая дальность прорисовки растительности, тени и отражения, до 512 объектов частиц.", "Дальность растительности и лимит частиц как на высоких настройках, но сглаживание сильнее, а обломки видны дольше." }; break;
                default: return;
            }
            for (int i = 0; i < descriptions.Length; i++) values["DetailHelp" + i] = descriptions[i];
        }

        private static void ApplyV25Translations(
            ModernLocalization result, string language)
        {
            string[][] english = {
                new[] { "Continue Campaign", "Continue Campaign" },
                new[] { "New Campaign", "New Campaign" },
                new[] { "Save as", "Save as" },
                new[] { "Mission Select (Advanced)", "Mission Select (Advanced)" },
                new[] { "Direct mission starts can bypass campaign state, inventory, and briefings.", "Direct mission starts can bypass campaign state, inventory, and briefings." },
                new[] { "No readable campaign save was found.", "No readable campaign save was found." },
                new[] { "The previous game session did not close cleanly.", "The previous game session did not close cleanly." },
                new[] { "Start in Safe Mode", "Start in Safe Mode" },
                new[] { "Dismiss", "Dismiss" },
                new[] { "Lobby password", "Lobby password" },
                new[] { "The password is passed to UZDoom and is never stored.", "The password is passed to UZDoom and is never stored." },
                new[] { "The detected engine does not support lobby passwords.", "The detected engine does not support lobby passwords." },
                new[] { "Export session", "Export session" },
                new[] { "Import session", "Import session" },
                new[] { "The imported session requires a password.", "The imported session requires a password." },
                new[] { "Engine capabilities", "Engine capabilities" },
                new[] { "Savegames", "Savegames" },
                new[] { "Save locations", "Save locations" },
                new[] { "Create support package", "Create support package" },
                new[] { "Support package created.", "Support package created." },
                new[] { "The selected savegame is no longer available.", "The selected savegame is no longer available." },
                new[] { "Savegame compatibility", "Savegame compatibility" },
                new[] { "Continue anyway?", "Continue anyway?" },
                new[] { "One or more selected add-ons require a new campaign. Do not load an existing save with this selection.", "One or more selected add-ons require a new campaign. Do not load an existing save with this selection." },
                new[] { "The selected add-ons cannot be loaded together.", "The selected add-ons cannot be loaded together." },
                new[] { "Start a new campaign now?", "Start a new campaign now?" },
                new[] { "New campaign required", "New campaign required" },
                new[] { "Select Host co-op before exporting a session.", "Select Host co-op before exporting a session." },
                new[] { "Session exported without the password.", "Session exported without the password." },
                new[] { "Session compatibility", "Session compatibility" },
                new[] { "Cancel", "Cancel" },
                new[] { "Save", "Save" }
            };
            foreach (string[] entry in english) result.values[entry[0]] = entry[1];

            Dictionary<string, string[]> labels = new Dictionary<string, string[]> {
                { "Continue Campaign", new[] { "Kampagne fortsetzen", "Continuar campaña", "Continuer la campagne", "Continua campagna", "Continuar campanha", "Kampanyaya devam et", "Pokračovat v kampani", "Kontynuuj kampanię", "Продолжить кампанию" } },
                { "New Campaign", new[] { "Neue Kampagne", "Nueva campaña", "Nouvelle campagne", "Nuova campagna", "Nova campanha", "Yeni kampanya", "Nová kampaň", "Nowa kampania", "Новая кампания" } },
                { "Save as", new[] { "Speichern unter", "Guardar como", "Enregistrer sous", "Salva con nome", "Guardar como", "Farklı kaydet", "Uložit jako", "Zapisz jako", "Сохранить как" } },
                { "Mission Select (Advanced)", new[] { "Missionsauswahl (Erweitert)", "Selección de misión (avanzado)", "Sélection de mission (avancé)", "Selezione missione (avanzata)", "Seleção de missão (avançado)", "Görev seçimi (gelişmiş)", "Výběr mise (pokročilé)", "Wybór misji (zaawansowane)", "Выбор миссии (дополнительно)" } },
                { "Start in Safe Mode", new[] { "Im abgesicherten Modus starten", "Iniciar en modo seguro", "Démarrer en mode sécurisé", "Avvia in modalità sicura", "Iniciar em modo de segurança", "Güvenli modda başlat", "Spustit v nouzovém režimu", "Uruchom w trybie awaryjnym", "Запустить в безопасном режиме" } },
                { "Lobby password", new[] { "Lobby-Passwort", "Contraseña de sala", "Mot de passe du salon", "Password lobby", "Palavra-passe da sala", "Lobi parolası", "Heslo lobby", "Hasło lobby", "Пароль лобби" } },
                { "Export session", new[] { "Sitzung exportieren", "Exportar sesión", "Exporter la session", "Esporta sessione", "Exportar sessão", "Oturumu dışa aktar", "Exportovat relaci", "Eksportuj sesję", "Экспорт сессии" } },
                { "Import session", new[] { "Sitzung importieren", "Importar sesión", "Importer la session", "Importa sessione", "Importar sessão", "Oturumu içe aktar", "Importovat relaci", "Importuj sesję", "Импорт сессии" } },
                { "Engine capabilities", new[] { "Engine-Fähigkeiten", "Funciones del motor", "Fonctions du moteur", "Funzioni del motore", "Capacidades do motor", "Motor yetenekleri", "Funkce enginu", "Możliwości silnika", "Возможности движка" } },
                { "Savegames", new[] { "Spielstände", "Partidas guardadas", "Sauvegardes", "Salvataggi", "Jogos guardados", "Kayıtlı oyunlar", "Uložené hry", "Zapisy gry", "Сохранения" } },
                { "Create support package", new[] { "Supportpaket erstellen", "Crear paquete de soporte", "Créer un paquet d'assistance", "Crea pacchetto di supporto", "Criar pacote de suporte", "Destek paketi oluştur", "Vytvořit balíček podpory", "Utwórz pakiet pomocy", "Создать пакет диагностики" } }
            };
            string[] codes = { "de", "es", "fr", "it", "ptb", "tr", "cs", "pl", "ru" };
            int languageIndex = Array.IndexOf(codes, language);
            if (languageIndex >= 0) {
                foreach (KeyValuePair<string, string[]> entry in labels) {
                    result.values[entry.Key] = entry.Value[languageIndex];
                }
            }

            if (language == "de") {
                Dictionary<string, string> german = new Dictionary<string, string> {
                    { "Save locations", "Speicherorte" },
                    { "No readable campaign save was found.", "Kein lesbarer Kampagnen-Spielstand wurde gefunden." },
                    { "The previous game session did not close cleanly.", "Die vorherige Spielsitzung wurde nicht sauber beendet." },
                    { "Dismiss", "Ausblenden" },
                    { "The password is passed to UZDoom and is never stored.", "Das Passwort wird an UZDoom übergeben und niemals gespeichert." },
                    { "The detected engine does not support lobby passwords.", "Die erkannte Engine unterstützt keine Lobby-Passwörter." },
                    { "The imported session requires a password.", "Die importierte Sitzung benötigt ein Passwort." },
                    { "The selected savegame is no longer available.", "Der ausgewählte Spielstand ist nicht mehr verfügbar." },
                    { "Savegame compatibility", "Spielstand-Kompatibilität" },
                    { "Continue anyway?", "Trotzdem fortfahren?" },
                    { "New campaign required", "Neue Kampagne erforderlich" },
                    { "The selected add-ons cannot be loaded together.", "Die ausgew\u00e4hlten Add-ons k\u00f6nnen nicht gemeinsam geladen werden." },
                    { "Start a new campaign now?", "Jetzt eine neue Kampagne starten?" },
                    { "Session compatibility", "Sitzungskompatibilität" },
                    { "Support package created.", "Supportpaket erstellt." },
                    { "Cancel", "Abbrechen" },
                    { "Save", "Speichern" }
                };
                foreach (KeyValuePair<string, string> entry in german) {
                    result.values[entry.Key] = entry.Value;
                }
            }
        }

        private static void ApplyV265Translations(ModernLocalization result, string language)
        {
            if (language != "de") return;
            string[] keys = { "Engine default", "Advanced network settings", "Reset network settings",
                "Balance network timing", "Redundant movement packets", "Movement command interval",
                "Pause permission", "Save permission", "Restrict conversations", "Repeated action cooldown",
                "Chat interval (seconds)", "Everyone", "Settings controllers", "Disabled", "Off", "On",
                "Resume co-op campaign", "Session save", "No co-op save selected", "This session requires a local co-op save",
                "Select co-op save", "Clear co-op save",
                "All players need the identical save and its companion .boa-launcher.ini file. Keep the original player names." };
            string[] values = { "Engine-Standard", "Erweiterte Netzwerkeinstellungen", "Netzwerkeinstellungen zur\u00fccksetzen",
                "Netzwerk-Timing ausgleichen", "Redundante Bewegungspakete", "Intervall der Bewegungsbefehle",
                "Pausenberechtigung", "Speicherberechtigung", "Dialoge begrenzen", "Wartezeit f\u00fcr wiederholte Aktionen",
                "Chat-Intervall (Sekunden)", "Alle", "Einstellungsberechtigte", "Deaktiviert", "Aus", "An",
                "Koop-Kampagne fortsetzen", "Sitzungsspielstand", "Kein Koop-Spielstand ausgew\u00e4hlt", "Diese Sitzung ben\u00f6tigt einen lokalen Koop-Spielstand",
                "Koop-Spielstand ausw\u00e4hlen", "Koop-Spielstand abw\u00e4hlen",
                "Alle Spieler ben\u00f6tigen denselben Spielstand samt .boa-launcher.ini-Begleitdatei. Die urspr\u00fcnglichen Spielernamen beibehalten." };
            for (int i = 0; i < keys.Length; i++) result.values[keys[i]] = values[i];
        }

        private static void ApplyQuickLaunchTranslations(ModernLocalization result, string language)
        {
            string[] keys = { "Shared settings", "Game settings", "Select for Play", "Recent compatible save", "Back up save" };
            string[][] rows = {
                new[] { "en", "Shared settings", "Game settings", "Select for Play", "Recent compatible save", "Back up save" },
                new[] { "de", "Gemeinsame Einstellungen", "Spieleinstellungen", "F\u00fcr den Spielstart ausw\u00e4hlen", "Letzter kompatibler Spielstand", "Spielstand sichern" },
                new[] { "fr", "Param\u00e8tres communs", "Param\u00e8tres du jeu", "S\u00e9lectionner pour Jouer", "Sauvegarde compatible r\u00e9cente", "Copier la sauvegarde" },
                new[] { "es", "Ajustes comunes", "Ajustes del juego", "Seleccionar para Jugar", "Partida compatible reciente", "Respaldar partida" },
                new[] { "it", "Impostazioni comuni", "Impostazioni di gioco", "Seleziona per l'avvio", "Salvataggio compatibile recente", "Copia salvataggio" },
                new[] { "ptb", "Defini\u00e7\u00f5es comuns", "Defini\u00e7\u00f5es do jogo", "Selecionar para Jogar", "Grava\u00e7\u00e3o compat\u00edvel recente", "Copiar grava\u00e7\u00e3o" },
                new[] { "tr", "Ortak ayarlar", "Oyun ayarlar\u0131", "Oyna i\u00e7in se\u00e7", "Son uyumlu kay\u0131t", "Kayd\u0131 yedekle" },
                new[] { "cs", "Spole\u010dn\u00e1 nastaven\u00ed", "Nastaven\u00ed hry", "Vybrat pro Hr\u00e1t", "Posledn\u00ed kompatibiln\u00ed pozice", "Z\u00e1lohovat pozici" },
                new[] { "pl", "Wsp\u00f3lne ustawienia", "Ustawienia gry", "Wybierz do gry", "Ostatni zgodny zapis", "Utw\u00f3rz kopi\u0119 zapisu" },
                new[] { "ru", "\u041e\u0431\u0449\u0438\u0435 \u043d\u0430\u0441\u0442\u0440\u043e\u0439\u043a\u0438", "\u041d\u0430\u0441\u0442\u0440\u043e\u0439\u043a\u0438 \u0438\u0433\u0440\u044b", "\u0412\u044b\u0431\u0440\u0430\u0442\u044c \u0434\u043b\u044f \u0437\u0430\u043f\u0443\u0441\u043a\u0430", "\u041f\u043e\u0441\u043b\u0435\u0434\u043d\u0435\u0435 \u0441\u043e\u0432\u043c\u0435\u0441\u0442\u0438\u043c\u043e\u0435 \u0441\u043e\u0445\u0440\u0430\u043d\u0435\u043d\u0438\u0435", "\u0421\u043e\u0437\u0434\u0430\u0442\u044c \u043a\u043e\u043f\u0438\u044e \u0441\u043e\u0445\u0440\u0430\u043d\u0435\u043d\u0438\u044f" }
            };
            foreach (string[] row in rows) {
                if (row[0] != language) continue;
                for (int i = 0; i < keys.Length; i++) result.values[keys[i]] = row[i + 1];
            }
        }

        private static void ApplyCampaignSelectionTranslations(ModernLocalization result, string language)
        {
            string[][] rows = {
                new[] { "en", "Mission select (optional)", "From the beginning" },
                new[] { "de", "Missionsauswahl (optional)", "Von Anfang an" },
                new[] { "es", "Selecci\u00f3n de misi\u00f3n (opcional)", "Desde el principio" },
                new[] { "fr", "Choix de mission (facultatif)", "Depuis le d\u00e9but" },
                new[] { "it", "Selezione missione (opzionale)", "Dall'inizio" },
                new[] { "ptb", "Sele\u00e7\u00e3o de miss\u00e3o (opcional)", "Desde o in\u00edcio" },
                new[] { "tr", "G\u00f6rev se\u00e7imi (iste\u011fe ba\u011fl\u0131)", "Ba\u015ftan" },
                new[] { "cs", "V\u00fdb\u011br mise (voliteln\u00fd)", "Od za\u010d\u00e1tku" },
                new[] { "pl", "Wyb\u00f3r misji (opcjonalny)", "Od pocz\u0105tku" },
                new[] { "ru", "\u0412\u044b\u0431\u043e\u0440 \u043c\u0438\u0441\u0441\u0438\u0438 (\u043d\u0435\u043e\u0431\u044f\u0437\u0430\u0442\u0435\u043b\u044c\u043d\u043e)", "\u0421 \u0441\u0430\u043c\u043e\u0433\u043e \u043d\u0430\u0447\u0430\u043b\u0430" }
            };
            foreach (string[] row in rows) {
                if (row[0] != language) continue;
                result.values["Mission select (optional)"] = row[1];
                result.values["From the beginning"] = row[2];
            }
        }

        private static void ApplyLaunchActionTranslations(ModernLocalization result, string language)
        {
            string[][] rows = {
                new[] { "en", "Start New Campaign", "Start Multiplayer Session" },
                new[] { "de", "Neue Kampagne starten", "Mehrspielersitzung starten" },
                new[] { "es", "Iniciar nueva campa\u00f1a", "Iniciar sesi\u00f3n multijugador" },
                new[] { "fr", "D\u00e9marrer une nouvelle campagne", "D\u00e9marrer une session multijoueur" },
                new[] { "it", "Avvia nuova campagna", "Avvia sessione multigiocatore" },
                new[] { "ptb", "Iniciar nova campanha", "Iniciar sess\u00e3o multijogador" },
                new[] { "tr", "Yeni kampanya ba\u015flat", "\u00c7ok oyunculu oturum ba\u015flat" },
                new[] { "cs", "Spustit novou kampa\u0148", "Spustit hru v\u00edce hr\u00e1\u010d\u016f" },
                new[] { "pl", "Rozpocznij now\u0105 kampani\u0119", "Rozpocznij sesj\u0119 wieloosobow\u0105" },
                new[] { "ru", "\u041d\u0430\u0447\u0430\u0442\u044c \u043d\u043e\u0432\u0443\u044e \u043a\u0430\u043c\u043f\u0430\u043d\u0438\u044e", "\u041d\u0430\u0447\u0430\u0442\u044c \u0441\u0435\u0442\u0435\u0432\u0443\u044e \u0438\u0433\u0440\u0443" }
            };
            foreach (string[] row in rows) {
                if (row[0] != language) continue;
                result.values["Start New Campaign"] = row[1];
                result.values["Start Multiplayer Session"] = row[2];
            }
        }

        private static void ApplyReadinessTranslations(ModernLocalization result, string language)
        {
            string keys = "Use last settings|Open Main Menu|Recent campaign saves|Checking campaign saves...|Custom|Performance|Balanced|Quality|Performance goal|Undo performance changes|Default|Very low|Low|Normal|High|Very high|Review add-ons|Open diagnostics|Missing file: {0}|Empty file: {0}|Cannot read: {0}|Cannot write: {0}|Requires UZDoom {0}+|{0}: missing {1}|{0}: requires {1}|{0} conflicts with {1}.|{0}: unknown version of {1}";
            string translations;
            switch (language) {
                case "de": translations = "Letzte Einstellungen verwenden|Hauptmen\u00fc \u00f6ffnen|Letzte Kampagnenspielst\u00e4nde|Spielst\u00e4nde werden gepr\u00fcft \u2026|Benutzerdefiniert|Leistung|Ausgewogen|Qualit\u00e4t|Grafikziel|Grafik\u00e4nderungen r\u00fcckg\u00e4ngig machen|Standard|Sehr niedrig|Niedrig|Normal|Hoch|Sehr hoch|Add-ons pr\u00fcfen|Diagnose \u00f6ffnen|Datei fehlt: {0}|Datei ist leer: {0}|Nicht lesbar: {0}|Kein Schreibzugriff: {0}|UZDoom ab {0} erforderlich|{0}: {1} fehlt|{0}: ben\u00f6tigt {1}|{0} und {1} sind inkompatibel.|{0}: Version von {1} unbekannt"; break;
                case "es": translations = "Usar los \u00faltimos ajustes|Abrir men\u00fa principal|Partidas recientes|Comprobando partidas\u2026|Personalizado|Rendimiento|Equilibrado|Calidad|Objetivo gr\u00e1fico|Deshacer cambios gr\u00e1ficos|Predeterminado|Muy bajo|Bajo|Normal|Alto|Muy alto|Revisar add-ons|Abrir diagn\u00f3stico|Falta el archivo: {0}|Archivo vac\u00edo: {0}|No se puede leer: {0}|No se puede escribir: {0}|Requiere UZDoom {0} o posterior|{0}: falta {1}|{0}: requiere {1}|{0} es incompatible con {1}.|{0}: versi\u00f3n desconocida de {1}"; break;
                case "fr": translations = "Conserver les derniers r\u00e9glages|Ouvrir le menu principal|Sauvegardes r\u00e9centes|V\u00e9rification des sauvegardes\u2026|Personnalis\u00e9|Performances|\u00c9quilibr\u00e9|Qualit\u00e9|Objectif graphique|Annuler les r\u00e9glages graphiques|Par d\u00e9faut|Tr\u00e8s faible|Faible|Normal|\u00c9lev\u00e9|Tr\u00e8s \u00e9lev\u00e9|V\u00e9rifier les add-ons|Ouvrir le diagnostic|Fichier manquant : {0}|Fichier vide : {0}|Lecture impossible : {0}|\u00c9criture impossible : {0}|N\u00e9cessite UZDoom {0} ou ult\u00e9rieur|{0} : {1} manquant|{0} : n\u00e9cessite {1}|{0} est incompatible avec {1}.|{0} : version inconnue de {1}"; break;
                case "it": translations = "Usa le ultime impostazioni|Apri menu principale|Salvataggi recenti|Verifica dei salvataggi\u2026|Personalizzato|Prestazioni|Bilanciato|Qualit\u00e0|Obiettivo grafico|Annulla modifiche grafiche|Predefinito|Molto basso|Basso|Normale|Alto|Molto alto|Verifica add-on|Apri diagnostica|File mancante: {0}|File vuoto: {0}|Impossibile leggere: {0}|Impossibile scrivere: {0}|Richiede UZDoom {0} o successivo|{0}: manca {1}|{0}: richiede {1}|{0} \u00e8 incompatibile con {1}.|{0}: versione di {1} sconosciuta"; break;
                case "ptb": translations = "Usar as \u00faltimas defini\u00e7\u00f5es|Abrir menu principal|Jogos guardados recentes|A verificar jogos guardados\u2026|Personalizado|Desempenho|Equilibrado|Qualidade|Objetivo gr\u00e1fico|Anular altera\u00e7\u00f5es gr\u00e1ficas|Predefinido|Muito baixo|Baixo|Normal|Alto|Muito alto|Verificar add-ons|Abrir diagn\u00f3stico|Ficheiro em falta: {0}|Ficheiro vazio: {0}|N\u00e3o \u00e9 poss\u00edvel ler: {0}|N\u00e3o \u00e9 poss\u00edvel escrever: {0}|Requer UZDoom {0} ou posterior|{0}: falta {1}|{0}: requer {1}|{0} \u00e9 incompat\u00edvel com {1}.|{0}: vers\u00e3o de {1} desconhecida"; break;
                case "tr": translations = "Son ayarlar\u0131 kullan|Ana men\u00fcy\u00fc a\u00e7|Son kampanya kay\u0131tlar\u0131|Kay\u0131tlar denetleniyor\u2026|\u00d6zel|Performans|Dengeli|Kalite|Grafik hedefi|Grafik de\u011fi\u015fikliklerini geri al|Varsay\u0131lan|\u00c7ok d\u00fc\u015f\u00fck|D\u00fc\u015f\u00fck|Normal|Y\u00fcksek|\u00c7ok y\u00fcksek|Eklentileri denetle|Tan\u0131lamay\u0131 a\u00e7|Dosya eksik: {0}|Bo\u015f dosya: {0}|Okunam\u0131yor: {0}|Yaz\u0131lam\u0131yor: {0}|UZDoom {0} veya \u00fczeri gerekir|{0}: {1} eksik|{0}: {1} gerekir|{0} ile {1} uyumsuz.|{0}: {1} s\u00fcr\u00fcm\u00fc bilinmiyor"; break;
                case "cs": translations = "Pou\u017e\u00edt posledn\u00ed nastaven\u00ed|Otev\u0159\u00edt hlavn\u00ed nab\u00eddku|Ned\u00e1vno ulo\u017een\u00e9 hry|Kontrola ulo\u017een\u00fdch her\u2026|Vlastn\u00ed|V\u00fdkon|Vyv\u00e1\u017een\u00e9|Kvalita|C\u00edl grafiky|Vr\u00e1tit zm\u011bny grafiky|V\u00fdchoz\u00ed|Velmi n\u00edzk\u00e9|N\u00edzk\u00e9|Norm\u00e1ln\u00ed|Vysok\u00e9|Velmi vysok\u00e9|Zkontrolovat dopl\u0148ky|Otev\u0159\u00edt diagnostiku|Chyb\u011bj\u00edc\u00ed soubor: {0}|Pr\u00e1zdn\u00fd soubor: {0}|Nelze \u010d\u00edst: {0}|Nelze zapisovat: {0}|Vy\u017eaduje UZDoom {0} nebo nov\u011bj\u0161\u00ed|{0}: chyb\u00ed {1}|{0}: vy\u017eaduje {1}|{0} a {1} nejsou kompatibiln\u00ed.|{0}: nezn\u00e1m\u00e1 verze {1}"; break;
                case "pl": translations = "U\u017cyj ostatnich ustawie\u0144|Otw\u00f3rz menu g\u0142\u00f3wne|Ostatnie zapisy kampanii|Sprawdzanie zapis\u00f3w\u2026|W\u0142asne|Wydajno\u015b\u0107|Zr\u00f3wnowa\u017cone|Jako\u015b\u0107|Cel ustawie\u0144 grafiki|Cofnij zmiany grafiki|Domy\u015blne|Bardzo niskie|Niskie|Normalne|Wysokie|Bardzo wysokie|Sprawd\u017a dodatki|Otw\u00f3rz diagnostyk\u0119|Brak pliku: {0}|Pusty plik: {0}|Nie mo\u017cna odczyta\u0107: {0}|Nie mo\u017cna zapisa\u0107: {0}|Wymaga UZDoom {0} lub nowszego|{0}: brak {1}|{0}: wymaga {1}|{0} i {1} s\u0105 niezgodne.|{0}: nieznana wersja {1}"; break;
                case "ru": translations = "\u0418\u0441\u043f\u043e\u043b\u044c\u0437\u043e\u0432\u0430\u0442\u044c \u043f\u043e\u0441\u043b\u0435\u0434\u043d\u0438\u0435 \u043d\u0430\u0441\u0442\u0440\u043e\u0439\u043a\u0438|\u041e\u0442\u043a\u0440\u044b\u0442\u044c \u0433\u043b\u0430\u0432\u043d\u043e\u0435 \u043c\u0435\u043d\u044e|\u041d\u0435\u0434\u0430\u0432\u043d\u0438\u0435 \u0441\u043e\u0445\u0440\u0430\u043d\u0435\u043d\u0438\u044f \u043a\u0430\u043c\u043f\u0430\u043d\u0438\u0438|\u041f\u0440\u043e\u0432\u0435\u0440\u043a\u0430 \u0441\u043e\u0445\u0440\u0430\u043d\u0435\u043d\u0438\u0439\u2026|\u0421\u0432\u043e\u0438 \u043d\u0430\u0441\u0442\u0440\u043e\u0439\u043a\u0438|\u041f\u0440\u043e\u0438\u0437\u0432\u043e\u0434\u0438\u0442\u0435\u043b\u044c\u043d\u043e\u0441\u0442\u044c|\u0411\u0430\u043b\u0430\u043d\u0441|\u041a\u0430\u0447\u0435\u0441\u0442\u0432\u043e|\u041f\u0440\u0438\u043e\u0440\u0438\u0442\u0435\u0442 \u0433\u0440\u0430\u0444\u0438\u043a\u0438|\u041e\u0442\u043c\u0435\u043d\u0438\u0442\u044c \u0438\u0437\u043c\u0435\u043d\u0435\u043d\u0438\u044f \u0433\u0440\u0430\u0444\u0438\u043a\u0438|\u041f\u043e \u0443\u043c\u043e\u043b\u0447\u0430\u043d\u0438\u044e|\u041e\u0447\u0435\u043d\u044c \u043d\u0438\u0437\u043a\u0438\u0439|\u041d\u0438\u0437\u043a\u0438\u0439|\u041e\u0431\u044b\u0447\u043d\u044b\u0439|\u0412\u044b\u0441\u043e\u043a\u0438\u0439|\u041e\u0447\u0435\u043d\u044c \u0432\u044b\u0441\u043e\u043a\u0438\u0439|\u041f\u0440\u043e\u0432\u0435\u0440\u0438\u0442\u044c \u0434\u043e\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u044f|\u041e\u0442\u043a\u0440\u044b\u0442\u044c \u0434\u0438\u0430\u0433\u043d\u043e\u0441\u0442\u0438\u043a\u0443|\u041d\u0435\u0442 \u0444\u0430\u0439\u043b\u0430: {0}|\u041f\u0443\u0441\u0442\u043e\u0439 \u0444\u0430\u0439\u043b: {0}|\u041d\u0435 \u0443\u0434\u0430\u0451\u0442\u0441\u044f \u043f\u0440\u043e\u0447\u0438\u0442\u0430\u0442\u044c: {0}|\u041d\u0435 \u0443\u0434\u0430\u0451\u0442\u0441\u044f \u0437\u0430\u043f\u0438\u0441\u0430\u0442\u044c: {0}|\u0422\u0440\u0435\u0431\u0443\u0435\u0442\u0441\u044f UZDoom {0} \u0438\u043b\u0438 \u043d\u043e\u0432\u0435\u0435|{0}: \u043e\u0442\u0441\u0443\u0442\u0441\u0442\u0432\u0443\u0435\u0442 {1}|{0}: \u0442\u0440\u0435\u0431\u0443\u0435\u0442\u0441\u044f {1}|{0} \u0438 {1} \u043d\u0435\u0441\u043e\u0432\u043c\u0435\u0441\u0442\u0438\u043c\u044b.|{0}: \u043d\u0435\u0438\u0437\u0432\u0435\u0441\u0442\u043d\u0430\u044f \u0432\u0435\u0440\u0441\u0438\u044f {1}"; break;
                default: translations = keys; break;
            }
            string[] names = keys.Split('|'), values = translations.Split('|');
            for (int i = 0; i < names.Length; ++i) result.values[names[i]] = values[i];
        }

        internal string Get(string key)
        {
            string value;
            return values.TryGetValue(key, out value) ? value : key;
        }
    }
}
