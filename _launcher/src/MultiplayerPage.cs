using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Threading;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Controls.Primitives;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Media.Imaging;

namespace BladeOfAgonyLauncher
{
    internal sealed partial class ModernMainWindow
    {
        private FrameworkElement BuildMultiplayerPage()
        {
            StackPanel page = CreatePageContent();
            page.Children.Add(CreatePageTitle(
                text.Get("Multiplayer"),
                "Blade of Agony co-op, 2-4 players",
                "HeadingMultiplayer"));
            page.Children.Add(CreateInfoBar(
                text.Get("Add-ons are disabled in multiplayer.") + " " +
                text.Get("Only UZDoom 5.0.3 or newer and boa.ipk3 are checked and launched."),
                palette.Warning));
            page.Children.Add(BuildSessionActions());

            StackPanel modes = new StackPanel {
                Orientation = Orientation.Horizontal,
                Margin = new Thickness(0, 18, 0, 18)
            };
            MultiplayerMode role = options.NetworkMode == MultiplayerMode.SinglePlayer
                ? options.LastMultiplayerRole : options.NetworkMode;
            hostMode = CreateModeRadio(
                text.Get("Host co-op"), role == MultiplayerMode.Host);
            joinMode = CreateModeRadio(
                text.Get("Join co-op"), role == MultiplayerMode.Join);
            AutomationProperties.SetAutomationId(hostMode, "ModeHost");
            AutomationProperties.SetAutomationId(joinMode, "ModeJoin");
            modes.Children.Add(hostMode);
            modes.Children.Add(joinMode);
            page.Children.Add(modes);

            WrapPanel settings = new WrapPanel();
            hostSettings = BuildHostSettings();
            joinSettings = BuildJoinSettings();
            settings.Children.Add(hostSettings);
            settings.Children.Add(joinSettings);
            page.Children.Add(settings);
            page.Children.Add(BuildNetworkOptions());

            FrameworkElement status = BuildMultiplayerStatus();
            page.Children.Add(status);
            multiplayerLaunchButton = CreateCommandButton("\uE768", text.Get("Start Multiplayer Session"), true);
            multiplayerLaunchButton.HorizontalAlignment = HorizontalAlignment.Left;
            multiplayerLaunchButton.MinHeight = 36;
            multiplayerLaunchButton.IsEnabled = options.NetworkMode != MultiplayerMode.SinglePlayer;
            multiplayerLaunchButton.Margin = new Thickness(0, 24, 0, 0);
            AutomationProperties.SetAutomationId(multiplayerLaunchButton, "StartMultiplayerSession");
            multiplayerLaunchButton.Click += delegate {
                if (activePage != "multiplayer" || options.NetworkMode == MultiplayerMode.SinglePlayer) return;
                LaunchGame();
            };
            multiplayerNotice = (Border)CreateInfoBar(string.Empty, palette.Error);
            multiplayerNotice.Visibility = Visibility.Collapsed;
            page.Children.Add(multiplayerNotice);
            page.Children.Add(multiplayerLaunchButton);

            RoutedEventHandler modeChanged = delegate {
                if (building) {
                    return;
                }
                if (hostMode.IsChecked == true) {
                    options.NetworkMode = MultiplayerMode.Host;
                    options.ImportedSessionRules = false;
                    options.ImportedSaveSha256 = null;
                    options.ImportedSessionRequiresPassword = false;
                } else if (joinMode.IsChecked == true) {
                    options.NetworkMode = MultiplayerMode.Join;
                } else return;
                options.LastMultiplayerRole = options.NetworkMode;
                UpdateMultiplayerPanels();
                UpdateNetworkOptionsState();
                UpdateSummary();
            };
            hostMode.Checked += modeChanged;
            joinMode.Checked += modeChanged;
            UpdateMultiplayerPanels();
            return WrapPage(page);
        }

        private FrameworkElement BuildHostSettings()
        {
            StackPanel section = CreateSection(text.Get("Host co-op"));
            multiplayerPlayers = CreateComboBox();
            AutomationProperties.SetAutomationId(
                multiplayerPlayers, "MultiplayerPlayers");
            for (int players = 2; players <= 4; players++) {
                multiplayerPlayers.Items.Add(players);
            }
            multiplayerPlayers.SelectedItem = options.MultiplayerPlayers;
            multiplayerPlayers.SelectionChanged += delegate {
                if (multiplayerPlayers.SelectedItem != null) {
                    options.MultiplayerPlayers = (int)multiplayerPlayers.SelectedItem;
                    UpdateSummary();
                }
            };
            section.Children.Add(CreateField(text.Get("Players"), multiplayerPlayers));

            multiplayerEpisode = CreateComboBox();
            AutomationProperties.SetAutomationId(multiplayerEpisode, "MultiplayerChapter");
            foreach (BoaEpisode episode in contentCatalog.Episodes) {
                multiplayerEpisode.Items.Add(episode);
            }
            SelectEpisodeForMap(multiplayerEpisode, options.MultiplayerStartMap);
            section.Children.Add(CreateField(text.Get("Chapter"), multiplayerEpisode));

            multiplayerMap = CreateComboBox();
            AutomationProperties.SetAutomationId(
                multiplayerMap, "MultiplayerMap");
            PopulateMapCombo(
                multiplayerEpisode, multiplayerMap, options.MultiplayerStartMap);
            section.Children.Add(CreateField(text.Get("Mission"), multiplayerMap));
            var missionHint = new TextBlock { Text = text.Get("CoopMissionStartHint"), TextWrapping = TextWrapping.Wrap, Foreground = palette.Warning, Margin = new Thickness(0, 0, 0, 8) };
            AutomationProperties.SetAutomationId(missionHint, "CoopMissionStartHint");
            section.Children.Add(missionHint);

            multiplayerSkill = CreateComboBox();
            PopulateSkillCombo(multiplayerSkill, options.MultiplayerSkill);
            section.Children.Add(CreateField(text.Get("Difficulty"), multiplayerSkill));

            multiplayerPort = CreateTextBox(
                options.MultiplayerPort.ToString(
                    System.Globalization.CultureInfo.InvariantCulture));
            AutomationProperties.SetAutomationId(
                multiplayerPort, "MultiplayerHostPort");
            section.Children.Add(CreateField(text.Get("UDP port"), multiplayerPort));

            multiplayerCheats = CreateCheckBox(
                text.Get("Allow cheats"), options.MultiplayerCheats);
            section.Children.Add(multiplayerCheats);

            multiplayerHostPassword = CreatePasswordBox();
            multiplayerHostPassword.Password = options.MultiplayerPassword ?? string.Empty;
            multiplayerHostPassword.IsEnabled = engineCapabilities.Password;
            multiplayerHostPassword.ToolTip = engineCapabilities.Password
                ? text.Get("The password is passed to UZDoom and is never stored.")
                : text.Get("The detected engine does not support lobby passwords.");
            AutomationProperties.SetAutomationId(
                multiplayerHostPassword, "MultiplayerHostPassword");
            section.Children.Add(CreateField(text.Get("Lobby password"), multiplayerHostPassword));

            multiplayerEpisode.SelectionChanged += delegate {
                PopulateMapCombo(multiplayerEpisode, multiplayerMap, null);
                UpdateMultiplayerValues();
            };
            multiplayerMap.SelectionChanged += delegate { UpdateMultiplayerValues(); };
            multiplayerSkill.SelectionChanged += delegate { UpdateMultiplayerValues(); };
            multiplayerPort.TextChanged += delegate { UpdateMultiplayerValues(); };
            multiplayerCheats.Checked += delegate { UpdateMultiplayerValues(); };
            multiplayerCheats.Unchecked += delegate { UpdateMultiplayerValues(); };
            multiplayerHostPassword.PasswordChanged += delegate {
                options.MultiplayerPassword = multiplayerHostPassword.Password;
                UpdateSummary();
            };
            section.Children.Add(BuildCoopSavePicker(true));
            AddPasswordValidation(section, multiplayerHostPassword);
            return section;
        }

        private FrameworkElement BuildJoinSettings()
        {
            StackPanel section = CreateSection(text.Get("Join co-op"));
            multiplayerHost = CreateTextBox(options.MultiplayerHost);
            AutomationProperties.SetAutomationId(
                multiplayerHost, "MultiplayerHost");
            section.Children.Add(CreateField(text.Get("Host or IP"), multiplayerHost));
            TextBox joinPort = CreateTextBox(
                options.MultiplayerPort.ToString(
                    System.Globalization.CultureInfo.InvariantCulture));
            AutomationProperties.SetAutomationId(
                joinPort, "MultiplayerJoinPort");
            section.Children.Add(CreateField(text.Get("UDP port"), joinPort));
            multiplayerJoinPassword = CreatePasswordBox();
            multiplayerJoinPassword.Password = options.MultiplayerPassword ?? string.Empty;
            multiplayerJoinPassword.IsEnabled = engineCapabilities.Password;
            multiplayerJoinPassword.ToolTip = engineCapabilities.Password
                ? text.Get("The password is passed to UZDoom and is never stored.")
                : text.Get("The detected engine does not support lobby passwords.");
            AutomationProperties.SetAutomationId(
                multiplayerJoinPassword, "MultiplayerJoinPassword");
            section.Children.Add(CreateField(text.Get("Lobby password"), multiplayerJoinPassword));
            multiplayerHost.TextChanged += delegate {
                if (LauncherOptions.IsValidHost(multiplayerHost.Text)) {
                    options.MultiplayerHost = multiplayerHost.Text.Trim();
                    UpdateSummary();
                }
            };
            joinPort.TextChanged += delegate {
                int port;
                if (int.TryParse(joinPort.Text, out port) &&
                        port >= 1 && port <= 65535) {
                    options.MultiplayerPort = port;
                    if (multiplayerPort != null) {
                        multiplayerPort.Text = joinPort.Text;
                    }
                    UpdateSummary();
                }
            };
            multiplayerJoinPassword.PasswordChanged += delegate {
                options.MultiplayerPassword = multiplayerJoinPassword.Password;
                UpdateSummary();
            };
            section.Children.Add(BuildCoopSavePicker(false));
            AddPasswordValidation(section, multiplayerJoinPassword);
            return section;
        }

        private FrameworkElement BuildSessionActions()
        {
            WrapPanel panel = new WrapPanel { Margin = new Thickness(0, 14, 0, 0) };
            Button export = CreateCommandButton(
                "\uE898", text.Get("Export session"), false);
            AutomationProperties.SetAutomationId(export, "ExportSession");
            export.Click += delegate { ExportSession(); };
            Button import = CreateCommandButton(
                "\uE896", text.Get("Import session"), false);
            import.Margin = new Thickness(8, 0, 0, 0);
            AutomationProperties.SetAutomationId(import, "ImportSession");
            AutomationProperties.SetItemStatus(import, "Down");
            import.Click += delegate { ImportSession(); };
            panel.Children.Add(export);
            panel.Children.Add(import);
            if (options.ImportedSessionRequiresPassword &&
                    string.IsNullOrEmpty(options.MultiplayerPassword)) {
                TextBlock warning = new TextBlock {
                    Text = text.Get("The imported session requires a password."),
                    Foreground = palette.Warning,
                    VerticalAlignment = VerticalAlignment.Center,
                    Margin = new Thickness(12, 0, 0, 0)
                };
                panel.Children.Add(warning);
            }
            return panel;
        }

        private FrameworkElement BuildMultiplayerStatus()
        {
            MultiplayerCompatibilityStatus status =
                MultiplayerCompatibilityStatus.Inspect(baseDirectory);
            StackPanel panel = new StackPanel { Margin = new Thickness(0, 20, 0, 0) };
            panel.Children.Add(CreateSectionHeader(text.Get("Compatibility")));
            panel.Children.Add(CreateStatusRow(
                text.Get("Engine"),
                status.EnginePresent
                    ? "UZDoom " + status.EngineVersion
                    : text.Get("Not found"),
                status.EnginePresent && status.CorrectEngineVersion));
            panel.Children.Add(CreateStatusRow(
                text.Get("Main game"),
                status.MainGamePresent
                    ? "boa.ipk3, " + status.MainGameDescription
                    : text.Get("Not found"),
                status.MainGamePresent));
            panel.Children.Add(CreateStatusRow(
                text.Get("Engine capabilities"),
                engineCapabilities.Describe(text),
                engineCapabilities.LoadGame));
            return panel;
        }
    }
}
