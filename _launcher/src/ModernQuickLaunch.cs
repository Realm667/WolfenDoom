using System;
using System.Windows;
using System.Windows.Automation;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;

namespace BladeOfAgonyLauncher
{
    internal sealed partial class ModernMainWindow
    {
        private ComboBox campaignDestination;
        private StackPanel chapterFields;
        private FrameworkElement campaignWarning;
        private bool syncingStartMode;

        internal static ProgressBar CreateStartupProgress(ThemePalette colors)
        {
            ProgressBar progress = new ProgressBar {
                IsIndeterminate = true, Height = 4,
                Foreground = colors.Accent, Background = colors.SurfaceAlternative,
                BorderThickness = new Thickness(0),
                VerticalAlignment = VerticalAlignment.Center, Margin = new Thickness(40)
            };
            AutomationProperties.SetAutomationId(progress, "StartupProgress");
            FrameworkElementFactory track = new FrameworkElementFactory(typeof(Border), "PART_Track");
            track.SetValue(Border.BackgroundProperty, new TemplateBindingExtension(Control.BackgroundProperty));
            track.SetValue(UIElement.ClipToBoundsProperty, true);
            FrameworkElementFactory indicator = new FrameworkElementFactory(typeof(Border), "StartupSegment");
            indicator.SetValue(Border.BackgroundProperty, new TemplateBindingExtension(Control.ForegroundProperty));
            indicator.SetValue(FrameworkElement.HorizontalAlignmentProperty, HorizontalAlignment.Left);
            track.AppendChild(indicator);
            progress.Template = new ControlTemplate(typeof(ProgressBar)) { VisualTree = track };
            // Keep motion independent of the native ProgressBar template and enabled state.
            Action animate = delegate {
                if (!progress.IsLoaded || progress.ActualWidth <= 0) return;
                Border fill = progress.Template.FindName("StartupSegment", progress) as Border;
                if (fill == null) return;
                TranslateTransform movement = fill.RenderTransform as TranslateTransform;
                if (movement == null) fill.RenderTransform = movement = new TranslateTransform();
                fill.Width = progress.ActualWidth * 0.25;
                movement.BeginAnimation(TranslateTransform.XProperty,
                    new DoubleAnimation(0, progress.ActualWidth - fill.Width, TimeSpan.FromMilliseconds(900)) {
                        AutoReverse = true, RepeatBehavior = RepeatBehavior.Forever,
                        EasingFunction = new SineEase { EasingMode = EasingMode.EaseInOut }
                    });
            };
            progress.Loaded += delegate { animate(); };
            progress.SizeChanged += delegate { animate(); };
            progress.Unloaded += delegate {
                Border fill = progress.Template.FindName("StartupSegment", progress) as Border;
                TranslateTransform movement = fill == null ? null : fill.RenderTransform as TranslateTransform;
                if (movement != null) movement.BeginAnimation(TranslateTransform.XProperty, null);
            };
            return progress;
        }

        private Grid CreateResponsiveColumns(FrameworkElement left, FrameworkElement right, double minimumWidth, Func<bool> rightFirst = null)
        {
            Grid grid = new Grid();
            grid.ColumnDefinitions.Add(new ColumnDefinition());
            grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(24) });
            grid.ColumnDefinitions.Add(new ColumnDefinition());
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            grid.Children.Add(left);
            grid.Children.Add(right);
            double previousFontSize = FontSize;
            bool reversed = false;
            Action arrange = delegate {
                previousFontSize = FontSize;
                bool columns = grid.ActualWidth >= minimumWidth * 2 * Math.Max(1, FontSize / 14) + 24;
                grid.ColumnDefinitions[0].Width = new GridLength(1, GridUnitType.Star);
                grid.ColumnDefinitions[1].Width = new GridLength(columns ? 24 : 0);
                grid.ColumnDefinitions[2].Width = columns ? new GridLength(1, GridUnitType.Star) : new GridLength(0);
                Grid.SetColumn(right, columns ? 2 : 0);
                reversed = rightFirst != null && rightFirst();
                bool swap = !columns && reversed;
                Grid.SetRow(left, swap ? 1 : 0);
                Grid.SetRow(right, columns || swap ? 0 : 1);
                KeyboardNavigation.SetTabIndex(left, swap ? 1 : 0);
                KeyboardNavigation.SetTabIndex(right, swap ? 0 : 1);
                left.Margin = new Thickness(0, swap ? 24 : 0, 0, 0);
                right.Margin = new Thickness(0, columns || swap ? 0 : 24, 0, 0);
            };
            grid.SizeChanged += delegate { arrange(); };
            grid.Loaded += delegate { arrange(); };
            grid.LayoutUpdated += delegate { if (previousFontSize != FontSize || (rightFirst != null && rightFirst() != reversed)) arrange(); };
            return grid;
        }

        private Border CreateCampaignPane(string title, string id, UIElement body, UIElement actions)
        {
            Grid grid = new Grid();
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            grid.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            TextBlock heading = CreateSectionHeader(title);
            heading.FontFamily = unicaOneFont;
            heading.FontSize = 22;
            heading.FontWeight = FontWeights.Normal;
            heading.TextWrapping = TextWrapping.Wrap;
            heading.Margin = new Thickness(0, 0, 0, 12);
            grid.Children.Add(heading);
            Grid.SetRow(body, 1);
            grid.Children.Add(body);
            if (actions != null) {
                Grid.SetRow(actions, 2);
                FrameworkElement element = actions as FrameworkElement;
                if (element != null) element.Margin = new Thickness(0, 16, 0, 0);
                grid.Children.Add(actions);
            }
            Border pane = new Border {
                Background = palette.Surface, BorderBrush = palette.Border,
                BorderThickness = new Thickness(1), CornerRadius = new CornerRadius(6),
                Padding = new Thickness(18), Child = grid
            };
            AutomationProperties.SetAutomationId(pane, id);
            AutomationProperties.SetName(pane, title);
            return pane;
        }

        private void PopulateCampaignMissions(string selectedMap)
        {
            bool previous = syncingStartMode;
            syncingStartMode = true;
            try {
                singleMap.Items.Clear();
                singleMap.Items.Add(text.Get("From the beginning"));
                BoaEpisode episode = (BoaEpisode)singleEpisode.SelectedItem;
                if (episode != null) {
                    foreach (BoaMap map in episode.Maps) {
                        singleMap.Items.Add(map);
                        if (string.Equals(map.Id, selectedMap, StringComparison.OrdinalIgnoreCase)) singleMap.SelectedItem = map;
                    }
                }
                if (singleMap.SelectedItem == null) singleMap.SelectedIndex = 0;
                if (options.DebugKeenMissions && episode != null) {
                    foreach (BoaMap map in contentCatalog.KeenMaps) {
                        if ("SM0" + (singleEpisode.SelectedIndex + 1) != map.Id) continue;
                        singleMap.Items.Add(map);
                        if (map.Id == selectedMap) singleMap.SelectedItem = map;
                    }
                }
            } finally { syncingStartMode = previous; }
        }

        private void UpdateQuickLaunchControls()
        {
            if (syncingStartMode) return;
            syncingStartMode = true;
            try {
                bool single = options.NetworkMode == MultiplayerMode.SinglePlayer;
                bool episode = options.DirectStart || options.NewCampaign;
                if (campaignDestination != null) campaignDestination.SelectedIndex = episode ? 1 : 0;
                if (chapterFields != null) chapterFields.Visibility = episode ? Visibility.Visible : Visibility.Collapsed;
                if (singleEpisode != null) singleEpisode.IsEnabled = single && episode;
                if (singleSkill != null) singleSkill.IsEnabled = single && episode;
                if (singleDeathMode != null) singleDeathMode.IsEnabled = single && episode;
                if (singleMap != null) singleMap.IsEnabled = single && episode;
                if (campaignWarning != null) campaignWarning.Visibility = options.DirectStart ? Visibility.Visible : Visibility.Collapsed;
            } finally { syncingStartMode = false; }
        }

    }
}
