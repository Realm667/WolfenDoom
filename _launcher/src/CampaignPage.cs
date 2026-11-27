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
        private FrameworkElement BuildStartPage()
        {
            StackPanel content = CreatePageContent();
            content.Children.Add(CreateHeading(text.Get("Start"), "HeadingQuickLaunch"));

            if (recoveryStatus != null && recoveryStatus.PreviousRunInterrupted) {
                content.Children.Add(BuildRecoveryPanel());
            }

            continueHost = new ContentControl { Content = BuildContinuePanel(), HorizontalContentAlignment = HorizontalAlignment.Stretch, VerticalContentAlignment = VerticalAlignment.Stretch };
            campaignHost = new ContentControl { Content = BuildCampaignSection(), HorizontalContentAlignment = HorizontalAlignment.Stretch, VerticalContentAlignment = VerticalAlignment.Stretch };
            Grid campaigns = CreateResponsiveColumns(continueHost, campaignHost, 380, delegate { return savegames.Count == 0; });
            campaigns.Margin = new Thickness(0, 8, 0, 28);
            AutomationProperties.SetAutomationId(campaigns, "CampaignColumns");
            content.Children.Add(campaigns);
            graphicsHost = new ContentControl { Content = BuildGraphicsSection(), HorizontalContentAlignment = HorizontalAlignment.Stretch };
            content.Children.Add(graphicsHost);

            ApplySelectedAddonsToOptions();
            readinessBar = (Border)CreateInfoBar(string.Empty, palette.Good);
            AutomationProperties.SetAutomationId(readinessBar, "CampaignReadiness");
            content.Children.Insert(content.Children.IndexOf(campaigns), readinessBar);
            UpdateReadiness();

            return WrapPage(content);
        }

        private FrameworkElement BuildRecoveryPanel()
        {
            Border panel = (Border)CreateInfoBar(
                text.Get("The previous game session did not close cleanly."),
                palette.Warning);
            UIElement message = panel.Child;
            StackPanel content = new StackPanel();
            panel.Child = content;
            content.Children.Add(message);
            CrashDiagnosis diagnosis = CrashLogAnalyzer.AnalyzeLatest(baseDirectory);
            if (diagnosis != null) {
                content.Children.Add(new TextBlock {
                    Text = diagnosis.Category + ": " + diagnosis.Summary + " " +
                        diagnosis.Recommendation,
                    Foreground = palette.Muted,
                    TextWrapping = TextWrapping.Wrap,
                    Margin = new Thickness(0, 8, 0, 0)
                });
            }
            StackPanel actions = new StackPanel {
                Orientation = Orientation.Horizontal,
                Margin = new Thickness(0, 10, 0, 0)
            };
            Button safe = CreateCommandButton(
                "\uE7BA", text.Get("Start in Safe Mode"), false);
            AutomationProperties.SetAutomationId(safe, "SafeModeLaunch");
            safe.Click += delegate {
                LaunchSelectedSave(null, true);
            };
            Button dismiss = CreateCommandButton(
                "\uE711", text.Get("Dismiss"), false);
            dismiss.Margin = new Thickness(8, 0, 0, 0);
            dismiss.Click += delegate {
                LaunchRecovery.Dismiss(baseDirectory);
                recoveryStatus.PreviousRunInterrupted = false;
                BuildShell();
            };
            actions.Children.Add(safe);
            actions.Children.Add(dismiss);
            content.Children.Add(actions);
            return panel;
        }


        private const int RecentSaveLimit = 12;
        private bool showAllSaves;

        private FrameworkElement BuildContinuePanel()
        {
            continueCampaignButton = null;
            StackPanel section = new StackPanel();
            if (savegames.Count == 0) {
                section.Children.Add(new TextBlock { Text = text.Get(loadingSaves ? "Checking campaign saves..." : "No readable campaign save was found."), Foreground = palette.Muted, TextWrapping = TextWrapping.Wrap });
                return CreateCampaignPane(text.Get("Continue Campaign"), "ContinueCampaignSection", section, null);
            }

            if (selectedSave == null || FindSave(selectedSave.Path) == null) {
                selectedSave = latestSave;
            }
            ComboBox savePicker = CreateComboBox();
            if (savegames.Count <= RecentSaveLimit) showAllSaves = false;
            else if (!savegames.Take(RecentSaveLimit).Any(s => string.Equals(s.Path, selectedSave.Path, StringComparison.OrdinalIgnoreCase))) showAllSaves = true;
            foreach (SavegameInfo save in showAllSaves ? savegames.AsEnumerable() : savegames.Take(RecentSaveLimit)) {
                savePicker.Items.Add(save);
                if (string.Equals(save.Path, selectedSave.Path,
                        StringComparison.OrdinalIgnoreCase)) {
                    savePicker.SelectedItem = save;
                }
            }
            if (savePicker.SelectedItem == null) savePicker.SelectedIndex = 0;
            AutomationProperties.SetAutomationId(savePicker, "CampaignSavePicker");
            savePicker.SelectionChanged += delegate {
                if (building || savePicker.SelectedItem == null) return;
                selectedSave = (SavegameInfo)savePicker.SelectedItem;
                RefreshSection(continueHost, BuildContinuePanel);
            };
            FrameworkElement pickerField = CreateField(text.Get("Recent campaign saves"), savePicker);
            pickerField.Margin = new Thickness(0, 0, 0, 8);
            section.Children.Add(pickerField);
            if (savegames.Count > RecentSaveLimit) {
                var toggle = CreateButton(text.Get(showAllSaves ? "Show recent saves" : "Show all saves"), false);
                AutomationProperties.SetAutomationId(toggle, "SaveListScope");
                toggle.HorizontalAlignment = HorizontalAlignment.Left;
                toggle.Margin = new Thickness(0,0,0,8);
                toggle.Click += delegate {
                    showAllSaves = !showAllSaves;
                    if (!showAllSaves && !savegames.Take(RecentSaveLimit).Contains(selectedSave)) selectedSave = savegames[0];
                    RefreshSection(continueHost, BuildContinuePanel);
                };
                section.Children.Add(toggle);
            }
            Image preview = new Image { Stretch = Stretch.UniformToFill };
            Grid viewport = new Grid { ClipToBounds = true, Margin = new Thickness(0, 0, 0, 12), Background = palette.Background, Height = 180 };
            AutomationProperties.SetAutomationId(viewport, "CampaignPreview");
            viewport.SizeChanged += delegate { if (viewport.ActualWidth > 0) viewport.Height = viewport.ActualWidth * 9 / 16; };
            viewport.Children.Add(preview);
            section.Children.Add(viewport);
            StackPanel details = new StackPanel();
            details.Children.Add(new TextBlock {
                Text = selectedSave.DisplayTitle,
                Foreground = palette.Text,
                FontWeight = FontWeights.SemiBold,
                TextWrapping = TextWrapping.Wrap
            });
            details.Children.Add(new TextBlock {
                Text = selectedSave.Kind + "  \u2022  " +
                    selectedSave.CurrentMap + "  \u2022  " +
                    selectedSave.CreationTime.ToString("g"),
                TextWrapping = TextWrapping.Wrap,
                Foreground = palette.Muted,
                Margin = new Thickness(0, 5, 0, 0)
            });
                TextBlock saveWarning = new TextBlock {
                    TextWrapping = TextWrapping.Wrap,
                    Margin = new Thickness(0, 7, 0, 0)
                };
                details.Children.Add(saveWarning);
            section.Children.Add(details);
            Button continueButton = CreateCommandButton(
                "\uE768", text.Get("Continue Campaign"),
                true);
            continueCampaignButton = continueButton;
            continueButton.IsEnabled = false;
            AutomationProperties.SetAutomationId(continueButton, "ContinueCampaign");
            continueButton.Click += delegate {
                LaunchSelectedSave(selectedSave.Path);
            };
            WrapPanel saveActions = new WrapPanel();
            saveActions.Children.Add(continueButton);
            Button backup = CreateIconButton("\uE792", text.Get("Back up save"));
            backup.Margin = new Thickness(8, 0, 0, 0);
            backup.Click += delegate {
                SavegameInfo save = selectedSave;
                string path = null;
                RunWorkAsync(delegate { path = SavegameService.Backup(save, baseDirectory); },
                    delegate { footerStatus.Text = string.Format(text.Get("Save backup created: {0}"), Path.GetFileName(path)); });
            };
            saveActions.Children.Add(backup);
            UpdateSaveCardAsync(selectedSave, continueButton, preview, saveWarning);
            return CreateCampaignPane(text.Get("Continue Campaign"), "ContinueCampaignSection", section, saveActions);
        }

        private async void UpdateSaveCardAsync(SavegameInfo save, Button action, Image preview, TextBlock warning)
        {
            LauncherOptions snapshot = options.Snapshot();
            try {
                SaveCompatibilityResult compatibility = await Task.Run(delegate { return SavegameService.Check(save, snapshot); });
                if (closed || selectedSave != save || continueCampaignButton != action) return;
                action.IsEnabled = compatibility.CanLaunch;
                warning.Text = compatibility.Issues.Count > 0 ? compatibility.Issues[0].Message : string.Empty;
                warning.Visibility = warning.Text.Length == 0 ? Visibility.Collapsed : Visibility.Visible;
                warning.Foreground = compatibility.CanLaunch ? palette.Warning : palette.Error;
            } catch (Exception error) {
                if (!closed && continueCampaignButton == action) {
                    action.IsEnabled = false;
                    warning.Text = error.Message;
                    warning.Foreground = palette.Error;
                }
                return;
            }

            BitmapSource picture = null;
            try {
                picture = await Task.Run(delegate {
                    return imageCache.Get(save.Path, "save-960", delegate {
                        byte[] bytes = save.PreviewPng;
                        if (bytes == null) return null;
                        using (MemoryStream stream = new MemoryStream(bytes)) return LoadBitmap(stream, 960);
                    });
                });
            } catch (Exception ex) {
                System.Diagnostics.Trace.TraceWarning("Save preview unavailable: " + ex.Message);
            }
            if (closed || selectedSave != save || continueCampaignButton != action) return;
            preview.Source = picture;
            ((FrameworkElement)preview.Parent).Visibility = picture == null ? Visibility.Collapsed : Visibility.Visible;
        }

        private FrameworkElement BuildCampaignSection()
        {
            StackPanel section = new StackPanel();
            campaignDestination = CreateComboBox();
            AutomationProperties.SetAutomationId(campaignDestination, "CampaignDestination");
            campaignDestination.Items.Add(text.Get("Main menu"));
            campaignDestination.Items.Add(text.Get("Chapter"));
            campaignDestination.SelectedIndex = options.NewCampaign || options.DirectStart ? 1 : 0;
            section.Children.Add(CreateField(text.Get("Start mode"), campaignDestination));
            chapterFields = new StackPanel();
            section.Children.Add(chapterFields);
            singleEpisode = CreateComboBox();
            AutomationProperties.SetAutomationId(singleEpisode, "SingleEpisode");
            foreach (BoaEpisode episode in contentCatalog.Episodes) {
                singleEpisode.Items.Add(episode);
            }
            SelectEpisodeForMap(singleEpisode, options.SinglePlayerStartMap);
            if (options.DebugKeenMissions && BoaContentCatalog.IsKeenMap(options.SinglePlayerStartMap)) {
                int chapter = options.SinglePlayerStartMap[3] - '1';
                if (chapter < singleEpisode.Items.Count) singleEpisode.SelectedIndex = chapter;
            }
            chapterFields.Children.Add(CreateField(text.Get("Chapter"), singleEpisode));

            singleMap = CreateComboBox();
            AutomationProperties.SetAutomationId(singleMap, "SingleMission");
            PopulateCampaignMissions(options.DirectStart ? options.SinglePlayerStartMap : null);
            singleSkill = CreateComboBox();
            AutomationProperties.SetAutomationId(singleSkill, "SingleDifficulty");
            PopulateSkillCombo(singleSkill, options.SinglePlayerSkill);
            chapterFields.Children.Add(CreateField(text.Get("Difficulty"), singleSkill));
            singleDeathMode = null;
            if (contentCatalog.HasCheckpointMode) {
                singleDeathMode = CreateComboBox();
                AutomationProperties.SetAutomationId(singleDeathMode, "SingleDeathMode");
                singleDeathMode.Items.Add(contentCatalog.ClassicLabel);
                singleDeathMode.Items.Add(contentCatalog.CheckpointLabel);
                if (contentCatalog.HasLevelRestart) singleDeathMode.Items.Add(contentCatalog.RestartLabel);
                singleDeathMode.SelectedIndex = options.RestartLevelOnDeath && contentCatalog.HasLevelRestart ? 2 : options.SinglePlayerCheckpoints ? 1 : 0;
                singleDeathMode.SelectionChanged += delegate { if (!building && !syncingStartMode) UpdateSinglePlayerSelection(); };
                chapterFields.Children.Add(CreateField(contentCatalog.DeathModeTitle, singleDeathMode));
            }
            var advanced = new StackPanel();
            var expander = new Expander { Header = text.Get("Advanced launch options"), Foreground = palette.Text, Content = advanced, IsExpanded = options.DirectStart || options.DebugKeenMissions };
            AutomationProperties.SetAutomationId(expander, "AdvancedLaunchOptions");
            chapterFields.Children.Add(expander);
            advanced.Children.Add(CreateField(text.Get("Mission select (optional)"), singleMap));
            var debug = CreateCheckBox(text.Get("MissionDebugMode"), options.DebugKeenMissions);
            AutomationProperties.SetAutomationId(debug, "MissionDebugMode");
            advanced.Children.Add(debug);
            var debugWarning = new TextBlock { Text = text.Get("MissionDebugWarning"), Foreground = palette.Warning, TextWrapping = TextWrapping.Wrap };
            debugWarning.Visibility = debug.IsChecked == true ? Visibility.Visible : Visibility.Collapsed;
            advanced.Children.Add(debugWarning);
            Action toggleDebug = delegate {
                options.DebugKeenMissions = debug.IsChecked == true;
                debugWarning.Visibility = options.DebugKeenMissions ? Visibility.Visible : Visibility.Collapsed;
                var previous = singleMap.SelectedItem as BoaMap;
                PopulateCampaignMissions(previous == null ? null : previous.Id);
                if (!building && !syncingStartMode && !options.ContinueCampaign && previous != null && BoaContentCatalog.IsKeenMap(previous.Id)) UpdateSinglePlayerSelection();
            };
            debug.Checked += delegate { toggleDebug(); };
            debug.Unchecked += delegate { toggleDebug(); };
            campaignWarning = new TextBlock { Text = text.Get("Direct mission starts can bypass campaign state, inventory, and briefings."), Foreground = palette.Warning, TextWrapping = TextWrapping.Wrap, Margin = new Thickness(0, 4, 0, 8) };
            advanced.Children.Add(campaignWarning);
            singleEpisode.SelectionChanged += delegate {
                if (building || syncingStartMode) {
                    return;
                }
                PopulateCampaignMissions(null);
                UpdateSinglePlayerSelection();
            };
            singleMap.SelectionChanged += delegate { if (!building && !syncingStartMode) UpdateSinglePlayerSelection(); };
            singleSkill.SelectionChanged += delegate { if (!building && !syncingStartMode) UpdateSinglePlayerSelection(); };
            campaignDestination.SelectionChanged += delegate {
                if (syncingStartMode || building) return;
                PopulateCampaignMissions(null);
                UpdateSinglePlayerSelection();
            };
            UpdateSinglePlayerSelection();
            campaignLaunchButton = CreateCommandButton("\uE768", text.Get(campaignDestination.SelectedIndex == 1 ? "Start New Campaign" : "Open Main Menu"), true);
            campaignLaunchButton.HorizontalAlignment = HorizontalAlignment.Left;
            campaignLaunchButton.MinHeight = 36;
            AutomationProperties.SetAutomationId(campaignLaunchButton, "StartNewCampaign");
            campaignLaunchButton.Click += delegate {
                if (activePage != "start" || options.NetworkMode != MultiplayerMode.SinglePlayer) return;
                LaunchGame();
            };
            return CreateCampaignPane(text.Get("New Campaign"), "NewCampaignSection", section, campaignLaunchButton);
        }

        private FrameworkElement BuildGraphicsSection()
        {
            StackPanel section = new StackPanel();
            section.Children.Add(CreateSectionHeader(text.Get("Graphics")));
            StackPanel graphics = section;
            ComboBox goal = CreateComboBox();
            AutomationProperties.SetAutomationId(goal, "PerformanceGoal");
            goal.Items.Add(new ComboBoxItem { Content = text.Get("Custom"), IsEnabled = false });
            foreach (string key in new[] { "Performance", "Balanced", "Quality" }) goal.Items.Add(text.Get(key));
            bool derivingGoal = false;
            Action deriveGoal = delegate {
                derivingGoal = true;
                goal.SelectedIndex = options.DetailPreset == 2 && !options.DisplacementTextures ? 1
                    : options.DetailPreset == 4 && options.DisplacementTextures ? 2
                    : options.DetailPreset == 6 && options.DisplacementTextures ? 3 : 0;
                derivingGoal = false;
            };
            deriveGoal();
            goal.SelectionChanged += delegate {
                if (building || derivingGoal || goal.SelectedIndex <= 0) return;
                performanceUndoDetail = options.DetailPreset;
                performanceUndoDisplacement = options.DisplacementTextures;
                if (goal.SelectedIndex == 1) {
                    options.DetailPreset = 2;
                    options.DisplacementTextures = false;
                } else if (goal.SelectedIndex == 2) {
                    options.DetailPreset = 4;
                    options.DisplacementTextures = true;
                } else {
                    options.DetailPreset = 6;
                    options.DisplacementTextures = true;
                }
                RefreshSection(graphicsHost, BuildGraphicsSection);
            };
            section.Children.Add(CreateField(text.Get("Performance goal"), goal));
            if (performanceUndoDetail >= 0) {
                Button undo = CreateCommandButton(
                    "\uE7A7", text.Get("Undo performance changes"), false);
                undo.Margin = new Thickness(0, 0, 0, 13);
                undo.Click += delegate {
                    options.DetailPreset = performanceUndoDetail;
                    options.DisplacementTextures = performanceUndoDisplacement;
                    performanceUndoDetail = -1;
                    RefreshSection(graphicsHost, BuildGraphicsSection);
                };
                section.Children.Add(undo);
            }
            ComboBox detail = CreateComboBox();
            string[] detailNames = {
                "Use last settings", "Default", "Very low", "Low",
                "Normal", "High", "Very high"
            };
            foreach (string name in detailNames) {
                detail.Items.Add(text.Get(name));
            }
            detail.SelectedIndex = Math.Max(
                0, Math.Min(detail.Items.Count - 1, options.DetailPreset));
            AutomationProperties.SetAutomationId(detail, "DetailPreset");
            detail.ToolTip = BuildDetailPresetToolTip(
                detail.SelectedIndex, text.Get(detailNames[detail.SelectedIndex]));
            AutomationProperties.SetHelpText(
                detail, GetDetailPresetDescription(detail.SelectedIndex));
            ToolTipService.SetInitialShowDelay(detail, 350);
            ToolTipService.SetShowDuration(detail, 60000);
            TextBlock detailHelp = new TextBlock { Text = GetDetailPresetDescription(detail.SelectedIndex),
                Foreground = palette.Muted, TextWrapping = TextWrapping.Wrap,
                Margin = new Thickness(0, 2, 0, 8), MaxWidth = 430, HorizontalAlignment = HorizontalAlignment.Left };
            AutomationProperties.SetAutomationId(detailHelp, "DetailPresetDescription");
            detail.SelectionChanged += delegate {
                if (detail.SelectedIndex >= 0) {
                    options.DetailPreset = detail.SelectedIndex;
                    detailHelp.Text = GetDetailPresetDescription(detail.SelectedIndex);
                    deriveGoal();
                    detail.ToolTip = BuildDetailPresetToolTip(
                        detail.SelectedIndex, text.Get(detailNames[detail.SelectedIndex]));
                    AutomationProperties.SetHelpText(
                        detail, GetDetailPresetDescription(detail.SelectedIndex));
                    UpdateSummary();
                }
            };
            section.Children.Add(CreateField(text.Get("Detail preset"), detail));
            section.Children.Add(detailHelp);

            CheckBox displacement = CreateCheckBox(
                text.Get("Displacement textures"), options.DisplacementTextures);
            displacement.ToolTip =
                "Loads boa_dt.pk3 in single-player. Disabled automatically in multiplayer.";
            displacement.Checked += delegate {
                options.DisplacementTextures = true;
                deriveGoal();
                UpdateSummary();
            };
            displacement.Unchecked += delegate {
                options.DisplacementTextures = false;
                deriveGoal();
                UpdateSummary();
            };
            AutomationProperties.SetAutomationId(displacement, "DisplacementTextures");
            // Keep this switch beside the preset that can change its value.
            graphics.Children.Insert(graphics.Children.IndexOf(detailHelp), displacement);
            section = new StackPanel();
            section.Children.Add(CreateSectionHeader(text.Get("Game settings")));
            ComboBox gameLanguage = CreateComboBox();
            AutomationProperties.SetAutomationId(
                gameLanguage, "GameLanguage");
            foreach (LanguageChoice language in GetLanguages()) {
                gameLanguage.Items.Add(language);
                if (language.Code == options.Language) {
                    gameLanguage.SelectedItem = language;
                }
            }
            gameLanguage.SelectionChanged += delegate {
                if (building || gameLanguage.SelectedItem == null) {
                    return;
                }
                options.Language = ((LanguageChoice)gameLanguage.SelectedItem).Code;
                RefreshDataAsync(DataScope.Content, false);
            };
            section.Children.Add(CreateField(text.Get("Game language"), gameLanguage));

            CheckBox commentary = CreateCheckBox(
                text.Get("Developer commentary"), options.DeveloperCommentary);
            AutomationProperties.SetAutomationId(commentary, "DeveloperCommentary");
            commentary.Checked += delegate {
                options.DeveloperCommentary = true;
                UpdateSummary();
            };
            commentary.Unchecked += delegate {
                options.DeveloperCommentary = false;
                UpdateSummary();
            };
            section.Children.Add(commentary);

            StackPanel shared = new StackPanel();
            shared.Children.Add(CreateSectionHeader(text.Get("Shared settings")));
            shared.Children.Add(CreateResponsiveColumns(graphics, section, 320));
            Border band = new Border { BorderBrush = palette.Border, BorderThickness = new Thickness(0, 1, 0, 0), Padding = new Thickness(0, 24, 0, 0), Child = shared };
            AutomationProperties.SetAutomationId(band, "SharedSettings");
            return band;
        }

        private ToolTip BuildDetailPresetToolTip(int preset, string displayName)
        {
            ToolTip toolTip = new ToolTip {
                Background = palette.SurfaceAlternative,
                BorderBrush = palette.Border,
                BorderThickness = new Thickness(1),
                Padding = new Thickness(12),
                Placement = PlacementMode.Right,
                MaxWidth = 430
            };
            StackPanel panel = new StackPanel();
            panel.Children.Add(new TextBlock {
                Text = displayName,
                Foreground = palette.Text,
                FontSize = 14,
                FontWeight = FontWeights.SemiBold,
                Margin = new Thickness(0, 0, 0, 7)
            });

            panel.Children.Add(new TextBlock {
                Text = GetDetailPresetDescription(preset),
                Foreground = palette.Muted,
                TextWrapping = TextWrapping.Wrap,
                LineHeight = 19,
                MaxWidth = 390
            });
            toolTip.Content = panel;
            return toolTip;
        }

        private string GetDetailPresetDescription(int preset)
        {
            return text.Get("DetailHelp" + (preset >= 0 && preset < 7 ? preset : 0));
        }
    }
}
