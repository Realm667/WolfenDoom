using System;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Media;

namespace BladeOfAgonyLauncher
{
    internal sealed partial class ModernMainWindow
    {
        private Expander networkExpander;

        private Expander CreateAccordion(string title, UIElement contents, string id)
        {
            TextBlock heading = CreateSectionHeader(title);
            heading.Margin = new Thickness(8, 8, 0, 8);
            Expander result = new Expander {
                Header = heading, Content = contents, IsExpanded = false,
                Foreground = palette.Text, Background = Brushes.Transparent,
                HorizontalContentAlignment = HorizontalAlignment.Stretch,
                Margin = new Thickness(0, 12, 0, 12)
            };
            AutomationProperties.SetAutomationId(result, id);
            AutomationProperties.SetName(result, title);
            return result;
        }

        private FrameworkElement BuildNetworkOptions()
        {
            WrapPanel fields = new WrapPanel();
            foreach (NetworkRule rule in NetworkRule.All) {
                NetworkRule selectedRule = rule;
                if (rule.Choices.Length == 0) {
                    fields.Children.Add(BuildNumericNetworkRule(rule));
                    continue;
                }
                ComboBox choice = CreateComboBox();
                choice.Items.Add(text.Get("Engine default"));
                int minimum = rule.Key == "ticdup" ? 1 : 0;
                for (int value = minimum; value <= rule.Maximum; value++)
                    choice.Items.Add(rule.Choices.Length > 0 ? text.Get(rule.Choices[value]) : value.ToString());
                int configured;
                choice.SelectedIndex = options.MultiplayerRules.TryGetValue(rule.Key, out configured) ? configured - minimum + 1 : 0;
                bool supported = engineCapabilities.NetworkRules.Contains(rule.Key);
                choice.IsEnabled = supported || choice.SelectedIndex > 0;
                choice.ToolTip = rule.Description + (supported ? string.Empty : " Not detected in this engine. Select Engine default to remove an old override.");
                AutomationProperties.SetAutomationId(choice, "NetworkRule_" + rule.Key);
                choice.SelectionChanged += delegate {
                    if (choice.SelectedIndex <= 0) options.MultiplayerRules.Remove(selectedRule.Key);
                    else options.MultiplayerRules[selectedRule.Key] = choice.SelectedIndex - 1 + minimum;
                    UpdateSummary();
                };
                FrameworkElement field = CreateField(text.Get(rule.Label), choice);
                field.Width = 350;
                field.Margin = new Thickness(0, 0, 24, 14);
                fields.Children.Add(field);
            }
            Button reset = CreateCommandButton("\uE777", text.Get("Reset network settings"), false);
            AutomationProperties.SetAutomationId(reset, "ResetNetworkRules");
            reset.Click += delegate { options.MultiplayerRules.Clear(); RefreshPage("multiplayer", BuildMultiplayerPage); };
            StackPanel content = new StackPanel();
            content.Children.Add(fields);
            content.Children.Add(reset);
            networkExpander = CreateAccordion(text.Get("Advanced network settings"), content, "NetworkOptionsAccordion");
            UpdateNetworkOptionsState();
            return networkExpander;
        }

        private FrameworkElement BuildNumericNetworkRule(NetworkRule rule)
        {
            int value;
            bool enabled = options.MultiplayerRules.TryGetValue(rule.Key, out value);
            CheckBox useDefault = CreateCheckBox(text.Get("Engine default"), !enabled);
            TextBox input = CreateTextBox(enabled ? value.ToString() : (rule.Key == "ticdup" ? "1" : "0"));
            input.IsEnabled = enabled && engineCapabilities.NetworkRules.Contains(rule.Key);
            input.ToolTip = rule.Description;
            AutomationProperties.SetAutomationId(input, "NetworkRule_" + rule.Key);
            AutomationProperties.SetAutomationId(useDefault, "NetworkDefault_" + rule.Key);
            Action update = delegate {
                bool defaultValue = useDefault.IsChecked == true;
                input.IsEnabled = !defaultValue && engineCapabilities.NetworkRules.Contains(rule.Key);
                int parsed;
                if (defaultValue) options.MultiplayerRules.Remove(rule.Key);
                else options.MultiplayerRules[rule.Key] = int.TryParse(input.Text, out parsed) ? parsed : -1;
                input.BorderBrush = defaultValue || (int.TryParse(input.Text, out parsed) &&
                    parsed >= (rule.Key == "ticdup" ? 1 : 0) && parsed <= rule.Maximum) ? palette.Border : palette.Error;
            };
            useDefault.IsEnabled = engineCapabilities.NetworkRules.Contains(rule.Key) || enabled;
            useDefault.Checked += delegate { update(); };
            useDefault.Unchecked += delegate { update(); };
            input.TextChanged += delegate { update(); };
            StackPanel field = new StackPanel { Width = 350, Margin = new Thickness(0, 0, 24, 14) };
            field.Children.Add(CreateField(text.Get(rule.Label), input));
            field.Children.Add(useDefault);
            return field;
        }

        private void UpdateNetworkOptionsState()
        {
            if (networkExpander != null)
                networkExpander.Visibility = options.NetworkMode == MultiplayerMode.Host ? Visibility.Visible : Visibility.Collapsed;
        }

        private void AddPasswordValidation(Panel section, PasswordBox password)
        {
            TextBlock error = new TextBlock { Foreground = palette.Error, TextWrapping = TextWrapping.Wrap, Margin = new Thickness(0, 0, 0, 12) };
            Action validate = delegate {
                try { MultiplayerSettings.ValidatePassword(password.Password); error.Text = string.Empty; }
                catch (Exception exception) { error.Text = exception.Message; }
                error.Visibility = error.Text.Length == 0 ? Visibility.Collapsed : Visibility.Visible;
                AutomationProperties.SetHelpText(password, error.Text.Length == 0 ? "Maximum 255 UTF-8 bytes. Password is never stored." : error.Text);
            };
            password.PasswordChanged += delegate { validate(); };
            validate();
            section.Children.Add(error);
        }

        private FrameworkElement BuildCoopSavePicker(bool host)
        {
            StackPanel panel = new StackPanel { Margin = new Thickness(0, 16, 0, 0) };
            panel.Children.Add(CreateSectionHeader(text.Get(host ? "Resume co-op campaign" : "Session save")));
            TextBlock selected = new TextBlock {
                Foreground = palette.Muted, TextWrapping = TextWrapping.Wrap,
                Text = string.IsNullOrEmpty(options.MultiplayerSavePath)
                    ? text.Get(string.IsNullOrEmpty(options.ImportedSaveSha256) ? "No co-op save selected" : "This session requires a local co-op save")
                    : Path.GetFileName(options.MultiplayerSavePath), Margin = new Thickness(0, 0, 0, 8)
            };
            AutomationProperties.SetAutomationId(selected, host ? "HostSaveSelection" : "JoinSaveSelection");
            panel.Children.Add(selected);
            WrapPanel actions = new WrapPanel();
            Button browse = CreateCommandButton("\uE8E5", text.Get("Select co-op save"), false);
            browse.IsEnabled = engineCapabilities.CoopResume;
            AutomationProperties.SetAutomationId(browse, host ? "HostSelectSave" : "JoinSelectSave");
            browse.Click += delegate {
                Microsoft.Win32.OpenFileDialog dialog = new Microsoft.Win32.OpenFileDialog {
                    Title = text.Get("Select co-op save"), Filter = "UZDoom save (*.zds)|*.zds", CheckFileExists = true
                };
                if (dialog.ShowDialog(this) != true) return;
                LauncherOptions candidate = options.Snapshot();
                candidate.NetworkMode = host ? MultiplayerMode.Host : MultiplayerMode.Join;
                candidate.MultiplayerSavePath = dialog.FileName;
                CoopSaveHeader header = null;
                RunWorkAsync(delegate {
                    header = CoopSaveService.Read(SavegameService.Read(candidate.MultiplayerSavePath));
                    if (host || string.IsNullOrEmpty(candidate.ImportedSaveSha256)) candidate.MultiplayerPlayers = header.PlayerCount;
                    CoopSaveService.Validate(candidate);
                }, delegate {
                    options.MultiplayerSavePath = candidate.MultiplayerSavePath;
                    options.MultiplayerPlayers = candidate.MultiplayerPlayers;
                    RefreshPage("multiplayer", BuildMultiplayerPage);
                    footerStatus.Text = text.Get("Saved players") + ": " + string.Join(", ", header.Players.Select(p => p.Name));
                });
            };
            Button clear = CreateIconButton("\uE711", text.Get("Clear co-op save"));
            clear.Margin = new Thickness(8, 0, 0, 0);
            clear.Click += delegate { options.MultiplayerSavePath = null; RefreshPage("multiplayer", BuildMultiplayerPage); };
            actions.Children.Add(browse);
            actions.Children.Add(clear);
            panel.Children.Add(actions);
            panel.Children.Add(new TextBlock {
                Text = text.Get("All players need the identical save and its companion .boa-launcher.ini file. Keep the original player names."),
                Foreground = palette.Muted, TextWrapping = TextWrapping.Wrap, Margin = new Thickness(0, 8, 0, 8)
            });
            if (host && !string.IsNullOrEmpty(options.MultiplayerSavePath)) {
                multiplayerPlayers.IsEnabled = false;
                multiplayerEpisode.IsEnabled = false;
                multiplayerMap.IsEnabled = false;
                multiplayerSkill.IsEnabled = false;
            }
            return panel;
        }
    }
}
