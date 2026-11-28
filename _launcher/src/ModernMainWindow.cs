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
    internal sealed class LanguageChoice
    {
        internal string Code;
        internal string Name;

        public override string ToString()
        {
            return Name;
        }
    }

    internal sealed class ThemeChoice
    {
        internal LauncherTheme Theme;
        internal string Name;

        public override string ToString()
        {
            return Name;
        }
    }

    internal sealed class AddonListEntry
    {
        internal AddonDescriptor Addon;
        internal string Label;
        internal CheckBox CheckBox;
        internal ListBoxItem Item;

        public override string ToString()
        {
            return Label;
        }
    }

    internal sealed class ThemePalette
    {
        internal Brush Background;
        internal Brush Navigation;
        internal Brush Surface;
        internal Brush SurfaceAlternative;
        internal Brush Border;
        internal Brush Text;
        internal Brush Muted;
        internal Brush Accent;
        internal Brush AccentHover;
        internal Brush AccentText, ButtonFill, GoodFill, ErrorFill;
        internal Brush Good;
        internal Brush Warning;
        internal Brush Error;

        internal static ThemePalette Create(LauncherTheme theme)
        {
            if (SystemParameters.HighContrast) {
                ThemePalette highContrast = new ThemePalette();
                highContrast.Background = SystemColors.WindowBrush;
                highContrast.Navigation = SystemColors.ControlBrush;
                highContrast.Surface = SystemColors.WindowBrush;
                highContrast.SurfaceAlternative = SystemColors.ControlBrush;
                highContrast.Border = SystemColors.WindowTextBrush;
                highContrast.Text = SystemColors.WindowTextBrush;
                highContrast.Muted = SystemColors.GrayTextBrush;
                highContrast.Accent = SystemColors.HighlightBrush;
                highContrast.AccentHover = SystemColors.HotTrackBrush;
                highContrast.ButtonFill = highContrast.GoodFill = highContrast.ErrorFill = SystemColors.HighlightBrush;
                highContrast.AccentText = SystemColors.HighlightTextBrush;
                highContrast.Good = SystemColors.HighlightBrush;
                highContrast.Warning = SystemColors.HighlightBrush;
                highContrast.Error = SystemColors.HighlightBrush;
                return highContrast;
            }

            ThemePalette result = new ThemePalette();
            if (theme == LauncherTheme.Light) {
                result.Background = Brush("#F3F4F5");
                result.Navigation = Brush("#E7EAEC");
                result.Surface = Brush("#FFFFFF");
                result.SurfaceAlternative = Brush("#ECEFF1");
                result.Border = Brush("#CDD2D6");
                result.Text = Brush("#1E2327");
                result.Muted = Brush("#5E6870");
                result.Accent = Brush("#668197");
                result.AccentHover = Brush("#557286");
            } else if (theme == LauncherTheme.Wolfenstein3D) {
                result.Background = Brush("#303234");
                result.Navigation = Brush("#860000");
                result.Surface = Brush("#3B3D3F");
                result.SurfaceAlternative = Brush("#45484A");
                result.Border = Brush("#5A5D60");
                result.Text = Brush("#F5F5F5");
                result.Muted = Brush("#C4C7C9");
                result.Accent = Brush("#857E7E");
                result.AccentHover = Brush("#9A9292");
            } else if (theme == LauncherTheme.Dark) {
                result.Background = Brush("#3B3B3B");
                result.Navigation = Brush("#2F3031");
                result.Surface = Brush("#454647");
                result.SurfaceAlternative = Brush("#505254");
                result.Border = Brush("#636669");
                result.Text = Brush("#F2F3F4");
                result.Muted = Brush("#C1C5C8");
                result.Accent = Brush("#5E839E");
                result.AccentHover = Brush("#7398B2");
            } else {
                result.Background = Brush("#30363A");
                result.Navigation = Brush("#11273A");
                result.Surface = Brush("#3B4145");
                result.SurfaceAlternative = Brush("#454C51");
                result.Border = Brush("#596168");
                result.Text = Brush("#F3F6F8");
                result.Muted = Brush("#C2CBD1");
                result.Accent = Brush("#668197");
                result.AccentHover = Brush("#7895AC");
            }
            result.ButtonFill = Brush(theme == LauncherTheme.Wolfenstein3D ? "#70696A" : "#557286");
            result.GoodFill = Brush("#366846");
            result.ErrorFill = Brush("#984242");
            result.AccentText = Brushes.White;
            result.Good = Brush(theme == LauncherTheme.Light ? "#326842" : "#8ACB9E");
            result.Warning = Brush(theme == LauncherTheme.Light ? "#805900" : "#EDBD68");
            result.Error = Brush(theme == LauncherTheme.Light ? "#9C3838" : "#FFAAAA");
            return result;
        }

        private static Brush Brush(string value)
        {
            SolidColorBrush brush = new SolidColorBrush(
                (Color)ColorConverter.ConvertFromString(value));
            brush.Freeze();
            return brush;
        }
    }

    internal sealed partial class ModernMainWindow : Window
    {
        private readonly string baseDirectory;
        private LauncherOptions options;
        private ModernLocalization text;
        private ThemePalette palette;
        private FontFamily unicaOneFont;
        private BoaContentCatalog contentCatalog;
        private BoaLauncherManifest launcherManifest;
        private List<AddonDescriptor> availableAddons;
        private List<AddonDescriptor> selectedAddons;
        private List<SavegameInfo> savegames = new List<SavegameInfo>();
        private SavegameInfo latestSave;
        private SavegameInfo selectedSave;
        private EngineCapabilitySet engineCapabilities;
        private RecoveryStatus recoveryStatus;
        private GamepadNavigation gamepadNavigation;
        private readonly Dictionary<string, FrameworkElement> pages =
            new Dictionary<string, FrameworkElement>(StringComparer.Ordinal);
        private readonly Dictionary<string, Button> navigationButtons =
            new Dictionary<string, Button>(StringComparer.Ordinal);
        private readonly List<TextBlock> navigationLabels = new List<TextBlock>();
        private string activePage = "start";
        private bool building;
        private bool addonSelectionSync;
        private int performanceUndoDetail = -1;
        private bool performanceUndoDisplacement;

        private Grid root;
        private ColumnDefinition navigationColumn;
        private TextBlock navigationVersion;
        private Grid pageHost;
        private TextBlock summaryText;
        private TextBlock footerStatus;
        private Button campaignLaunchButton;
        private Button multiplayerLaunchButton;
        private Button continueCampaignButton;

        private ComboBox singleEpisode;
        private ComboBox singleMap;
        private ComboBox singleSkill;
        private ComboBox singleDeathMode;
        private ComboBox multiplayerEpisode;
        private ComboBox multiplayerMap;
        private ComboBox multiplayerSkill;
        private ComboBox multiplayerPlayers;
        private TextBox multiplayerHost;
        private TextBox multiplayerPort;
        private PasswordBox multiplayerHostPassword;
        private PasswordBox multiplayerJoinPassword;
        private CheckBox multiplayerCheats;
        private RadioButton hostMode;
        private RadioButton joinMode;
        private FrameworkElement hostSettings;
        private FrameworkElement joinSettings;

        private ListBox addonList;
        private TextBlock addonSelectionCount;
        private TextBlock addonTitle;
        private TextBlock addonCredits;
        private TextBlock addonDescription;
        private TextBlock addonRequirements;
        private TextBlock addonCompatibility;
        private Image addonPreview;
        private Border addonPreviewViewport;
        private TextBlock addonPreviewCounter;
        private Button addonPreviewPrevious;
        private Button addonPreviewNext;
        private AddonDescriptor previewAddon;
        private int addonPreviewIndex = 1;
        private readonly List<AddonListEntry> addonEntries =
            new List<AddonListEntry>();
        private AddonDescriptor activeAddon;
        private Button addonMoveUp;
        private Button addonMoveDown;
        private Button addonResolveOrder;
        private ContentControl continueHost;
        private ContentControl campaignHost;
        private ContentControl graphicsHost;
        private bool busy;
        private bool closed;
        private PreflightResult displayPreflight = new PreflightResult();
        private Border readinessBar;
        private Border multiplayerNotice;
        private bool loadingSaves;
        private int saveScanGeneration;
        private int validationGeneration;
        private int previewGeneration;
        private readonly FileMemo<BitmapSource> imageCache = new FileMemo<BitmapSource>(12);

        [Flags]
        private enum DataScope { Content = 1, Addons = 2, Saves = 4, Engine = 8, All = 15 }

        internal ModernMainWindow(string directory)
        {
            baseDirectory = directory;
            options = LauncherOptions.Load(directory);
            selectedAddons = ReadPersistedSelection(options);
            options.NetworkMode = MultiplayerMode.SinglePlayer;
            options.ContinueCampaign = false;
            options.ContinueSavePath = null;

            Title = "Blade of Agony";
            MinWidth = 760;
            MinHeight = 600;
            Width = Math.Min(
                options.WindowWidth,
                Math.Max(MinWidth, SystemParameters.WorkArea.Width));
            Height = Math.Min(
                options.WindowHeight,
                Math.Max(MinHeight, SystemParameters.WorkArea.Height));
            WindowStartupLocation = WindowStartupLocation.CenterScreen;
            UseLayoutRounding = true;
            SnapsToDevicePixels = true;
            FontFamily = new FontFamily("Segoe UI Variable Text, Segoe UI");
            FontSize = 14;
            unicaOneFont = LoadEmbeddedFontFamily(
                "BladeLauncher.UnicaOne-Regular.ttf",
                "UnicaOne-Regular.ttf",
                "Unica One");
            KeyboardNavigation.SetTabNavigation(this, KeyboardNavigationMode.Cycle);
            AutomationProperties.SetName(this, "Blade of Agony Launcher");
            SetWindowIcon();

            SizeChanged += delegate { UpdateResponsiveLayout(); };
            Closing += delegate {
                closed = true;
                Rect bounds = WindowState == WindowState.Normal
                    ? new Rect(Left, Top, ActualWidth, ActualHeight)
                    : RestoreBounds;
                if (!bounds.IsEmpty) {
                    options.WindowWidth = Math.Max(MinWidth, bounds.Width);
                    options.WindowHeight = Math.Max(MinHeight, bounds.Height);
                }
                options.Save();
                if (gamepadNavigation != null) {
                    gamepadNavigation.Dispose();
                }
            };
            palette = ThemePalette.Create(options.Theme);
            Background = palette.Background;
            Content = CreateStartupProgress(palette);
            Loaded += delegate { loadingSaves = true; RefreshDataAsync(DataScope.Content | DataScope.Addons, true); };
            gamepadNavigation = new GamepadNavigation(HandleGamepadAction);
            gamepadNavigation.Enabled = true;
        }

        private void BuildShell()
        {
            string focusedId = FocusedControlId();
            Dictionary<string, double> offsets = new Dictionary<string, double>();
            foreach (KeyValuePair<string, FrameworkElement> pair in pages) {
                ScrollViewer scroll = pair.Value as ScrollViewer;
                if (scroll != null) offsets[pair.Key] = scroll.VerticalOffset;
            }
            building = true;
            palette = ThemePalette.Create(options.Theme);
            text = ModernLocalization.Load(options.InterfaceLanguage);
            pages.Clear();
            navigationButtons.Clear();
            navigationLabels.Clear();
            continueCampaignButton = null;
            campaignDestination = null;
            campaignLaunchButton = null;
            multiplayerLaunchButton = null;

            root = new Grid();
            root.Background = palette.Background;
            root.RowDefinitions.Add(new RowDefinition { Height = new GridLength(76) });
            root.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });
            root.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            Content = root;

            FrameworkElement header = BuildHeader();
            Grid.SetRow(header, 0);
            root.Children.Add(header);

            Grid body = new Grid();
            navigationColumn = new ColumnDefinition { Width = new GridLength(216) };
            body.ColumnDefinitions.Add(navigationColumn);
            body.ColumnDefinitions.Add(new ColumnDefinition {
                Width = new GridLength(1, GridUnitType.Star)
            });
            Grid.SetRow(body, 1);
            root.Children.Add(body);

            FrameworkElement navigation = BuildNavigation();
            Grid.SetColumn(navigation, 0);
            body.Children.Add(navigation);

            pageHost = new Grid {
                Background = palette.Background,
                Margin = new Thickness(0)
            };
            Grid.SetColumn(pageHost, 1);
            body.Children.Add(pageHost);

            AddPage("start", BuildStartPage());
            AddPage("addons", BuildAddonsPage());
            hostMode = joinMode = null;
            multiplayerMap = multiplayerSkill = null;
            multiplayerPort = null;
            multiplayerCheats = null;

            FrameworkElement footer = BuildFooter();
            Grid.SetRow(footer, 2);
            root.Children.Add(footer);

            building = false;
            ShowPage(activePage, false);
            UpdateResponsiveLayout();
            UpdateSummary();
            foreach (KeyValuePair<string, double> pair in offsets) {
                FrameworkElement page;
                if (pages.TryGetValue(pair.Key, out page)) {
                    ScrollViewer scroll = page as ScrollViewer;
                    if (scroll != null) scroll.ScrollToVerticalOffset(pair.Value);
                }
            }
            RestoreFocus(focusedId);
        }

        private FrameworkElement BuildHeader()
        {
            Border header = new Border {
                Background = palette.Navigation,
                BorderBrush = palette.Border,
                BorderThickness = new Thickness(0, 0, 0, 1),
                Padding = new Thickness(22, 10, 22, 10)
            };
            Grid grid = new Grid();
            grid.ColumnDefinitions.Add(new ColumnDefinition {
                Width = new GridLength(1, GridUnitType.Star)
            });
            grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
            header.Child = grid;

            StackPanel brand = new StackPanel {
                Orientation = Orientation.Horizontal,
                VerticalAlignment = VerticalAlignment.Center
            };
            Image logo = new Image {
                Width = 54,
                Height = 54,
                Stretch = Stretch.Uniform,
                Margin = new Thickness(0, 0, 14, 0)
            };
            logo.Source = LoadEmbeddedImage("BladeLauncher.boa-logo.png");
            logo.SnapsToDevicePixels = false;
            logo.UseLayoutRounding = false;
            RenderOptions.SetBitmapScalingMode(
                logo, BitmapScalingMode.HighQuality);
            RenderOptions.SetEdgeMode(logo, EdgeMode.Unspecified);
            AutomationProperties.SetName(logo, "Blade of Agony logo");
            AutomationProperties.SetAutomationId(logo, "BladeOfAgonyLogo");
            brand.Children.Add(logo);
            StackPanel titles = new StackPanel {
                VerticalAlignment = VerticalAlignment.Center
            };
            TextBlock brandTitle = new TextBlock {
                Text = "Blade of Agony",
                Foreground = palette.Text,
                FontFamily = unicaOneFont,
                FontSize = 24,
                FontWeight = FontWeights.Normal
            };
            AutomationProperties.SetAutomationId(brandTitle, "BrandTitle");
            AutomationProperties.SetItemStatus(
                brandTitle, brandTitle.FontFamily.Source);
            titles.Children.Add(brandTitle);
            TextBlock engineVersion = new TextBlock {
                Text = GetEngineVersionLabel(),
                Foreground = palette.Muted,
                FontSize = 12,
                Margin = new Thickness(0, 2, 0, 0)
            };
            AutomationProperties.SetName(engineVersion, engineVersion.Text);
            AutomationProperties.SetAutomationId(engineVersion, "EngineVersion");
            titles.Children.Add(engineVersion);
            brand.Children.Add(titles);
            grid.Children.Add(brand);

            StackPanel controls = new StackPanel {
                Orientation = Orientation.Horizontal,
                VerticalAlignment = VerticalAlignment.Center
            };
            controls.Children.Add(CreateHeaderField(
                text.Get("Interface language"), BuildInterfaceLanguageCombo()));
            controls.Children.Add(CreateHeaderField(
                text.Get("Design"), BuildThemeCombo()));
            Grid.SetColumn(controls, 1);
            grid.Children.Add(controls);
            return header;
        }

        private FrameworkElement CreateHeaderField(string label, Control control)
        {
            StackPanel panel = new StackPanel {
                Margin = new Thickness(18, 0, 0, 0),
                Width = 168
            };
            panel.Children.Add(new TextBlock {
                Text = label,
                Foreground = palette.Muted,
                FontSize = 11,
                Margin = new Thickness(2, 0, 0, 4)
            });
            control.Height = 32;
            panel.Children.Add(control);
            return panel;
        }

        private ComboBox BuildInterfaceLanguageCombo()
        {
            ComboBox combo = CreateComboBox();
            LanguageChoice[] languages = {
                new LanguageChoice { Code = "en", Name = "English" },
                new LanguageChoice { Code = "de", Name = "Deutsch" },
                new LanguageChoice { Code = "es", Name = "Espa\u00f1ol" },
                new LanguageChoice { Code = "ru", Name = "\u0420\u0443\u0441\u0441\u043a\u0438\u0439" },
                new LanguageChoice { Code = "ptb", Name = "Portugu\u00eas (European)" },
                new LanguageChoice { Code = "it", Name = "Italiano" },
                new LanguageChoice { Code = "tr", Name = "T\u00fcrk\u00e7e" },
                new LanguageChoice { Code = "fr", Name = "Fran\u00e7ais" },
                new LanguageChoice { Code = "cs", Name = "\u010ce\u0161tina" },
                new LanguageChoice { Code = "pl", Name = "Polski" }
            };
            foreach (LanguageChoice language in languages) {
                combo.Items.Add(language);
                if (language.Code == options.InterfaceLanguage) {
                    combo.SelectedItem = language;
                }
            }
            combo.SelectionChanged += delegate {
                if (building || combo.SelectedItem == null) {
                    return;
                }
                options.InterfaceLanguage =
                    ((LanguageChoice)combo.SelectedItem).Code;
                RefreshDataAsync(DataScope.Addons, true);
            };
            AutomationProperties.SetName(combo, text.Get("Interface language"));
            AutomationProperties.SetAutomationId(combo, "InterfaceLanguage");
            return combo;
        }

        private ComboBox BuildThemeCombo()
        {
            ComboBox combo = CreateComboBox();
            ThemeChoice[] themes = {
                new ThemeChoice { Theme = LauncherTheme.BladeOfAgony, Name = "Blade of Agony" },
                new ThemeChoice { Theme = LauncherTheme.Dark, Name = "Dark" },
                new ThemeChoice { Theme = LauncherTheme.Light, Name = "Light" },
                new ThemeChoice { Theme = LauncherTheme.Wolfenstein3D, Name = "Wolfenstein 3D" }
            };
            foreach (ThemeChoice theme in themes) {
                combo.Items.Add(theme);
                if (theme.Theme == options.Theme) {
                    combo.SelectedItem = theme;
                }
            }
            combo.SelectionChanged += delegate {
                if (building || combo.SelectedItem == null) {
                    return;
                }
                options.Theme = ((ThemeChoice)combo.SelectedItem).Theme;
                BuildShell();
            };
            AutomationProperties.SetName(combo, text.Get("Design"));
            AutomationProperties.SetAutomationId(combo, "Theme");
            return combo;
        }

        private FrameworkElement BuildNavigation()
        {
            Border navigation = new Border {
                Background = palette.Navigation,
                BorderBrush = palette.Border,
                BorderThickness = new Thickness(0, 0, 1, 0),
                Padding = new Thickness(10, 14, 10, 14)
            };
            Grid grid = new Grid();
            grid.RowDefinitions.Add(new RowDefinition {
                Height = new GridLength(1, GridUnitType.Star)
            });
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            navigation.Child = grid;

            StackPanel buttons = new StackPanel();
            buttons.Children.Add(CreateNavigationButton(
                "start", "\uE74A", text.Get("Start")));
            buttons.Children.Add(CreateNavigationButton(
                "addons", "\uE74C", text.Get("Add-ons")));
            buttons.Children.Add(CreateNavigationButton(
                "multiplayer", "\uE716", text.Get("Multiplayer")));
            buttons.Children.Add(CreateNavigationButton(
                "diagnostics", "\uE9D9", text.Get("Diagnostics")));
            grid.Children.Add(buttons);

            navigationVersion = new TextBlock {
                Text = "Launcher " + LauncherVersion.Number,
                Foreground = palette.Muted,
                FontSize = 11,
                Margin = new Thickness(12, 8, 0, 2)
            };
            Grid.SetRow(navigationVersion, 1);
            grid.Children.Add(navigationVersion);
            return navigation;
        }

        private Button CreateNavigationButton(string page, string glyph, string label)
        {
            Button button = CreateButton(string.Empty, false);
            button.Height = 46;
            button.Margin = new Thickness(0, 0, 0, 5);
            button.HorizontalContentAlignment = HorizontalAlignment.Left;
            button.Padding = new Thickness(13, 0, 10, 0);
            button.Background = Brushes.Transparent;
            button.BorderThickness = new Thickness(0);
            DockPanel content = new DockPanel();
            content.HorizontalAlignment = HorizontalAlignment.Left;
            TextBlock icon = new TextBlock {
                Text = glyph,
                FontFamily = new FontFamily("Segoe Fluent Icons, Segoe MDL2 Assets"),
                FontSize = 17,
                Width = 30,
                VerticalAlignment = VerticalAlignment.Center
            };
            icon.SetBinding(
                TextBlock.ForegroundProperty,
                new System.Windows.Data.Binding("Foreground") {
                    Source = button
                });
            TextBlock textLabel = new TextBlock {
                Text = label,
                FontFamily = unicaOneFont,
                FontSize = 16,
                FontWeight = FontWeights.Normal,
                VerticalAlignment = VerticalAlignment.Center,
                TextAlignment = TextAlignment.Left
            };
            textLabel.SetBinding(
                TextBlock.ForegroundProperty,
                new System.Windows.Data.Binding("Foreground") {
                    Source = button
                });
            navigationLabels.Add(textLabel);
            content.Children.Add(icon);
            content.Children.Add(textLabel);
            button.Content = content;
            button.ToolTip = label;
            AutomationProperties.SetName(button, label);
            AutomationProperties.SetAutomationId(button, "Nav_" + page);
            if (page == "start") {
                AutomationProperties.SetItemStatus(button, "Up");
            }
            button.Click += delegate { ShowPage(page, true); };
            navigationButtons[page] = button;
            return button;
        }

        private FrameworkElement BuildFooter()
        {
            Border footer = new Border {
                Background = palette.Surface,
                BorderBrush = palette.Border,
                BorderThickness = new Thickness(0, 1, 0, 0),
                Padding = new Thickness(20, 12, 20, 12)
            };
            AutomationProperties.SetAutomationId(footer, "LaunchFooter");
            StackPanel status = new StackPanel();
            summaryText = new TextBlock {
                Foreground = palette.Text,
                FontWeight = FontWeights.SemiBold,
                TextTrimming = TextTrimming.CharacterEllipsis
            };
            footerStatus = new TextBlock {
                Foreground = palette.Muted,
                FontSize = 12,
                Margin = new Thickness(0, 4, 0, 0),
                TextTrimming = TextTrimming.CharacterEllipsis
            };
            AutomationProperties.SetAutomationId(summaryText, "LaunchSummary");
            AutomationProperties.SetAutomationId(footerStatus, "LaunchStatus");
            status.Children.Add(summaryText);
            status.Children.Add(footerStatus);
            footer.Child = status;
            return footer;
        }

        private void AddPage(string key, FrameworkElement page)
        {
            page.Visibility = Visibility.Collapsed;
            pages[key] = page;
            pageHost.Children.Add(page);
        }

        private void ShowPage(string key, bool animate)
        {
            if (key == "multiplayer" || key == "diagnostics") {
                if (engineCapabilities == null) {
                    RunWorkAsync(delegate { engineCapabilities = EngineCapabilities.Detect(baseDirectory); },
                        delegate { ShowPage(key, animate); });
                    return;
                }
                if (key == "diagnostics") RefreshPage(key, BuildDiagnosticsPage);
                else if (!pages.ContainsKey(key)) RefreshPage(key, BuildMultiplayerPage);
            }
            FrameworkElement page;
            if (!pages.TryGetValue(key, out page)) {
                key = "start";
                page = pages[key];
            }
            bool leavingNetwork = options.NetworkMode != MultiplayerMode.SinglePlayer;
            activePage = key;
            if (options.NetworkMode != MultiplayerMode.SinglePlayer)
                options.LastMultiplayerRole = options.NetworkMode;
            if (key == "start" || key == "addons") {
                options.NetworkMode = MultiplayerMode.SinglePlayer;
                if (leavingNetwork) QueueValidationAsync();
            } else if (key == "multiplayer") {
                options.NetworkMode = options.LastMultiplayerRole;
                bool wasBuilding = building;
                building = true;
                try {
                    hostMode.IsChecked = options.NetworkMode == MultiplayerMode.Host;
                    joinMode.IsChecked = options.NetworkMode == MultiplayerMode.Join;
                } finally { building = wasBuilding; }
            }
            UpdateMultiplayerPanels();
            UpdateNetworkOptionsState();
            foreach (KeyValuePair<string, FrameworkElement> item in pages) {
                item.Value.Visibility = item.Key == key
                    ? Visibility.Visible
                    : Visibility.Collapsed;
            }
            foreach (KeyValuePair<string, Button> item in navigationButtons) {
                bool selected = item.Key == key;
                item.Value.Background = selected
                    ? palette.ButtonFill
                    : Brushes.Transparent;
                item.Value.Foreground = selected
                    ? palette.AccentText
                    : palette.Text;
            }
            if (animate) {
                page.BeginAnimation(
                    OpacityProperty,
                    new DoubleAnimation(0.25, 1.0, TimeSpan.FromMilliseconds(150)) {
                        EasingFunction = new QuadraticEase()
                    });
            }
            UpdateSummary();
        }

        private void PopulateAddonList()
        {
            addonList.SelectionChanged -= AddonSelectionChanged;
            addonSelectionSync = true;
            addonEntries.Clear();
            addonList.Items.Clear();

            AddonListEntry none = CreateAddonEntry(null, text.Get("No add-ons"));
            addonEntries.Add(none);
            addonList.Items.Add(none.Item);

            List<AddonDescriptor> ordered = new List<AddonDescriptor>();
            foreach (AddonDescriptor selected in selectedAddons) {
                if (FindAddon(availableAddons, selected.RelativePath) != null) {
                    ordered.Add(FindAddon(availableAddons, selected.RelativePath));
                }
            }
            foreach (AddonDescriptor addon in availableAddons) {
                if (FindAddon(ordered, addon.RelativePath) == null) {
                    ordered.Add(addon);
                }
            }

            foreach (AddonDescriptor addon in ordered) {
                AddonListEntry entry = CreateAddonEntry(addon, addon.Title);
                addonEntries.Add(entry);
                addonList.Items.Add(entry.Item);
                if (FindAddon(selectedAddons, addon.RelativePath) != null) {
                    addonList.SelectedItems.Add(entry.Item);
                }
            }
            if (selectedAddons.Count == 0) {
                none.Item.IsSelected = true;
            }
            addonSelectionSync = false;
            SyncAddonEntries();
            addonList.SelectionChanged += AddonSelectionChanged;
        }

        private AddonListEntry CreateAddonEntry(AddonDescriptor addon, string label)
        {
            AddonListEntry entry = new AddonListEntry();
            entry.Addon = addon;
            entry.Label = label;
            entry.CheckBox = CreateCheckBox(label, false);
            entry.CheckBox.Margin = new Thickness(0);
            entry.CheckBox.MinHeight = 24;
            entry.CheckBox.Tag = entry;
            entry.CheckBox.Checked += AddonCheckChanged;
            entry.CheckBox.Unchecked += AddonCheckChanged;
            entry.Item = new ListBoxItem {
                Content = entry.CheckBox,
                Tag = entry,
                Padding = new Thickness(8, 5, 8, 5),
                Background = Brushes.Transparent,
                BorderBrush = Brushes.Transparent,
                BorderThickness = new Thickness(1),
                Foreground = palette.Text,
                HorizontalContentAlignment = HorizontalAlignment.Stretch
            };
            entry.Item.Template = CreateAddonListItemTemplate();
            AutomationProperties.SetName(entry.Item, label);
            return entry;
        }

        private ControlTemplate CreateAddonListItemTemplate()
        {
            FrameworkElementFactory border =
                new FrameworkElementFactory(typeof(Border), "AddonItemBorder");
            border.SetBinding(
                Border.BackgroundProperty,
                new System.Windows.Data.Binding("Background") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            border.SetBinding(
                Border.BorderBrushProperty,
                new System.Windows.Data.Binding("BorderBrush") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            border.SetBinding(
                Border.BorderThicknessProperty,
                new System.Windows.Data.Binding("BorderThickness") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            border.SetBinding(
                Border.PaddingProperty,
                new System.Windows.Data.Binding("Padding") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });

            FrameworkElementFactory presenter =
                new FrameworkElementFactory(typeof(ContentPresenter));
            presenter.SetBinding(
                ContentPresenter.ContentProperty,
                new System.Windows.Data.Binding("Content") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            presenter.SetBinding(
                ContentPresenter.ContentTemplateProperty,
                new System.Windows.Data.Binding("ContentTemplate") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            presenter.SetValue(FrameworkElement.HorizontalAlignmentProperty,
                HorizontalAlignment.Stretch);
            presenter.SetValue(FrameworkElement.VerticalAlignmentProperty,
                VerticalAlignment.Center);
            border.AppendChild(presenter);

            ControlTemplate template = new ControlTemplate(typeof(ListBoxItem));
            template.VisualTree = border;
            Trigger hover = new Trigger {
                Property = ListBoxItem.IsMouseOverProperty,
                Value = true
            };
            hover.Setters.Add(new Setter(
                Border.BorderBrushProperty, palette.Accent, "AddonItemBorder"));
            template.Triggers.Add(hover);
            Trigger focus = new Trigger {
                Property = ListBoxItem.IsKeyboardFocusWithinProperty,
                Value = true
            };
            focus.Setters.Add(new Setter(
                Border.BorderBrushProperty, palette.Text, "AddonItemBorder"));
            focus.Setters.Add(new Setter(
                Border.BorderThicknessProperty, new Thickness(2), "AddonItemBorder"));
            template.Triggers.Add(focus);
            Trigger disabled = new Trigger {
                Property = ListBoxItem.IsEnabledProperty,
                Value = false
            };
            disabled.Setters.Add(new Setter(ListBoxItem.OpacityProperty, 0.45));
            template.Triggers.Add(disabled);
            return template;
        }

        private void AddonCheckChanged(object sender, RoutedEventArgs eventArgs)
        {
            if (addonSelectionSync) {
                return;
            }
            CheckBox checkBox = (CheckBox)sender;
            AddonListEntry entry = (AddonListEntry)checkBox.Tag;
            addonSelectionSync = true;
            if (checkBox.IsChecked == true) {
                if (entry.Addon == null) {
                    activeAddon = null;
                    addonList.UnselectAll();
                    entry.Item.IsSelected = true;
                } else {
                    activeAddon = entry.Addon;
                    AddonListEntry none = addonEntries[0];
                    none.Item.IsSelected = false;
                    if (!addonList.SelectedItems.Contains(entry.Item)) {
                        addonList.SelectedItems.Add(entry.Item);
                    }
                }
            } else {
                entry.Item.IsSelected = false;
                if (SameAddon(activeAddon, entry.Addon)) {
                    activeAddon = null;
                }
            }
            addonSelectionSync = false;
            SyncAddonEntries();
            ShowAddonDetails(
                checkBox.IsChecked == true ? entry.Addon : null);
        }

        private void AddonSelectionChanged(
            object sender, SelectionChangedEventArgs eventArgs)
        {
            if (addonSelectionSync) {
                return;
            }
            addonSelectionSync = true;
            AddonListEntry none = addonEntries[0];
            if (none.Item.IsSelected && eventArgs.AddedItems.Contains(none.Item)) {
                addonList.UnselectAll();
                none.Item.IsSelected = true;
            } else if (addonList.SelectedItems.Count > 1 && none.Item.IsSelected) {
                none.Item.IsSelected = false;
            }
            if (addonList.SelectedItems.Count == 0) {
                none.Item.IsSelected = true;
            }
            addonSelectionSync = false;
            SyncAddonEntries();

            if (eventArgs.AddedItems.Count > 0) {
                ListBoxItem item = eventArgs.AddedItems[
                    eventArgs.AddedItems.Count - 1] as ListBoxItem;
                if (item != null) {
                    AddonListEntry entry = item.Tag as AddonListEntry;
                    activeAddon = entry == null ? null : entry.Addon;
                    ShowAddonDetails(entry == null ? null : entry.Addon);
                }
            }
        }

        private void SyncAddonEntries()
        {
            if (addonEntries.Count == 0) {
                return;
            }
            addonSelectionSync = true;
            bool noneSelected = addonEntries[0].Item.IsSelected;
            selectedAddons.Clear();
            foreach (AddonListEntry entry in addonEntries) {
                bool selected = entry.Item.IsSelected;
                entry.CheckBox.IsChecked = selected;
                if (entry.Addon != null) {
                    entry.Item.IsEnabled = !noneSelected;
                    if (selected && !noneSelected) {
                        selectedAddons.Add(entry.Addon);
                    }
                }
            }
            activeAddon = activeAddon == null
                ? null
                : FindAddon(selectedAddons, activeAddon.RelativePath);
            if (activeAddon == null && selectedAddons.Count > 0) {
                activeAddon = selectedAddons[selectedAddons.Count - 1];
            }
            addonSelectionSync = false;
            ApplySelectedAddonsToOptions();
            UpdateAddonMoveButtons();
            if (addonSelectionCount != null) {
                addonSelectionCount.Text =
                    selectedAddons.Count.ToString(
                        System.Globalization.CultureInfo.InvariantCulture) +
                    " " + text.Get("selected");
            }
            QueueValidationAsync();
            UpdateSummary();
        }

        private async void QueueValidationAsync()
        {
            int generation = ++validationGeneration;
            LauncherOptions snapshot = options.Snapshot();
            List<AddonDescriptor> selection = new List<AddonDescriptor>(selectedAddons);
            await Task.Delay(80);
            if (closed || generation != validationGeneration) return;
            try {
                List<CompatibilityIssue> issues = null;
                PreflightResult preflight = null;
                await Task.Run(delegate {
                    issues = AddonCompatibility.Analyze(baseDirectory, selection);
                    preflight = LauncherPreflight.Inspect(snapshot, selection, issues);
                });
                if (closed || generation != validationGeneration) return;
                displayPreflight = preflight;
                UpdateAddonEntryStates(issues);
                UpdateAddonCompatibility(issues);
                UpdateReadiness();
                if (activePage == "diagnostics") RefreshPage("diagnostics", BuildDiagnosticsPage);
                if (selectedSave != null && continueCampaignButton != null)
                    RefreshSection(continueHost, BuildContinuePanel);
            } catch (Exception error) {
                if (!closed && generation == validationGeneration && addonCompatibility != null)
                    addonCompatibility.Text = error.Message;
            }
        }

        private void UpdateReadiness()
        {
            if (readinessBar == null) return;
            SetReadiness(readinessBar, displayPreflight);
        }

        private string FindingText(PreflightFinding finding)
        {
            if (finding.Severity == PreflightSeverity.Information && finding.Area == "Ready") return text.Get("Game files are ready.");
            string summary = text.Get(finding.SummaryKey ?? finding.Message);
            if (finding.SummaryArguments != null && finding.SummaryArguments.Length > 0) summary = string.Format(summary, finding.SummaryArguments);
            return text.Get(finding.Area) + ": " + summary;
        }

        private void SetReadiness(Border bar, PreflightResult result)
        {
            PreflightFinding finding = result.Findings.FirstOrDefault(f => f.Severity == PreflightSeverity.Blocking)
                ?? result.Findings.FirstOrDefault(f => f.Severity == PreflightSeverity.Warning);
            StackPanel content = new StackPanel();
            TextBlock message = new TextBlock { Foreground = palette.Text, TextWrapping = TextWrapping.Wrap };
            content.Children.Add(message);
            bar.Child = content;
            if (finding == null) {
                message.Text = text.Get("Game files are ready.");
                bar.BorderBrush = palette.Good;
                return;
            }
            string summary = text.Get(finding.SummaryKey ?? finding.Message);
            if (finding.SummaryArguments != null && finding.SummaryArguments.Length != 0)
                summary = string.Format(summary, finding.SummaryArguments);
            message.Text = text.Get(result.CanLaunch ? "Warning" : "Error") + ": " + summary;
            bar.BorderBrush = result.CanLaunch ? palette.Warning : palette.Error;
            bool addon = finding.Area == "Add-ons";
            Button review = CreateCommandButton("\uE76C", text.Get(addon ? "Review add-ons" : "Open diagnostics"), false);
            AutomationProperties.SetAutomationId(review, addon ? "ReviewAddonFinding" : "ReviewDiagnosticFinding");
            review.HorizontalAlignment = HorizontalAlignment.Left;
            review.Margin = new Thickness(0, 6, 0, 0);
            review.Click += delegate { ShowPage(addon ? "addons" : "diagnostics", true); };
            content.Children.Add(review);
        }

        private void UpdateAddonEntryStates(
            IList<CompatibilityIssue> compatibilityIssues)
        {
            HashSet<string> conflictingIds = new HashSet<string>(
                StringComparer.OrdinalIgnoreCase);
            foreach (CompatibilityIssue issue in compatibilityIssues) {
                if (issue.Severity != CompatibilitySeverity.Error) {
                    continue;
                }
                foreach (string id in issue.AffectedAddonIds) {
                    conflictingIds.Add(id);
                }
            }

            foreach (AddonListEntry entry in addonEntries) {
                bool selected = entry.Item.IsSelected;
                bool conflict = selected && entry.Addon != null &&
                    conflictingIds.Contains(entry.Addon.Id);
                Brush marker = conflict ? palette.ErrorFill : palette.GoodFill;
                var issues = conflict ? compatibilityIssues.Where(i => i.Severity == CompatibilitySeverity.Error && i.AffectedAddonIds.Contains(entry.Addon.Id)) : Enumerable.Empty<CompatibilityIssue>();
                string details = string.Join("\n", issues.Select(i => i.SummaryKey == null ? i.Message : string.Format(text.Get(i.SummaryKey), i.SummaryArguments)).Distinct());
                string line = entry.Label + (conflict ? "\n" + details : "");
                entry.CheckBox.Content = new TextBlock { Text = line, TextWrapping = TextWrapping.Wrap };
                AutomationProperties.SetName(entry.Item, line);
                AutomationProperties.SetName(entry.CheckBox, line);
                if (selected && entry.Addon != null) {
                    entry.Item.Background = marker;
                    entry.Item.Foreground = palette.AccentText;
                    entry.CheckBox.Foreground = palette.AccentText;
                    entry.CheckBox.Template = CreateCheckBoxTemplate(marker);
                    AutomationProperties.SetItemStatus(
                        entry.Item, conflict ? "Conflict" : "Compatible");
                    AutomationProperties.SetItemStatus(
                        entry.CheckBox, conflict ? "Conflict" : "Compatible");
                } else {
                    entry.Item.Background = selected
                        ? palette.ButtonFill
                        : Brushes.Transparent;
                    entry.Item.Foreground = selected
                        ? palette.AccentText
                        : palette.Text;
                    entry.CheckBox.Foreground = selected
                        ? palette.AccentText
                        : palette.Text;
                    entry.CheckBox.Template = CreateCheckBoxTemplate(palette.Accent);
                    AutomationProperties.SetItemStatus(
                        entry.Item, entry.Addon == null && selected
                            ? "NoAddons"
                            : string.Empty);
                    AutomationProperties.SetItemStatus(
                        entry.CheckBox, entry.Addon == null && selected
                            ? "NoAddons"
                            : string.Empty);
                }
            }
        }

        private void ShowAddonDetails(AddonDescriptor addon)
        {
            if (addon == null) {
                addonTitle.Text = text.Get("Select an add-on to view its details.");
                addonCredits.Text = string.Empty;
                addonDescription.Text = string.Empty;
                addonRequirements.Text = string.Empty;
                addonCompatibility.Text = string.Empty;
                previewAddon = null;
                addonPreviewIndex = 1;
                UpdateAddonPreview();
                return;
            }
            if (!SameAddon(previewAddon, addon)) {
                addonPreviewIndex = 1;
            }
            previewAddon = addon;
            addonTitle.Text = addon.Title;
            addonCredits.Text = addon.CreditsFull.Length > 0
                ? addon.CreditsFull
                : addon.Credits;
            addonCredits.ToolTip = addonCredits.Text;
            addonDescription.Text = addon.Description;
            addonRequirements.Text = addon.Requirements.Length > 0
                ? addon.Requirements
                : "-";
            QueueValidationAsync();
            UpdateAddonPreview();
        }

        private void ChangeAddonPreview(int direction)
        {
            if (previewAddon == null || previewAddon.PreviewImageCount < 2) {
                return;
            }
            addonPreviewIndex += direction;
            if (addonPreviewIndex < 1) {
                addonPreviewIndex = previewAddon.PreviewImageCount;
            } else if (addonPreviewIndex > previewAddon.PreviewImageCount) {
                addonPreviewIndex = 1;
            }
            UpdateAddonPreview();
        }

        private async void UpdateAddonPreview()
        {
            int generation = ++previewGeneration;
            int count = previewAddon == null
                ? 0
                : previewAddon.PreviewImageCount;
            bool multiple = count > 1;
            if (addonPreviewPrevious != null) {
                addonPreviewPrevious.Visibility =
                    multiple ? Visibility.Visible : Visibility.Collapsed;
            }
            if (addonPreviewNext != null) {
                addonPreviewNext.Visibility =
                    multiple ? Visibility.Visible : Visibility.Collapsed;
            }
            if (addonPreviewCounter != null) {
                addonPreviewCounter.Visibility =
                    multiple ? Visibility.Visible : Visibility.Collapsed;
                addonPreviewCounter.Text = multiple
                    ? addonPreviewIndex.ToString(
                        System.Globalization.CultureInfo.InvariantCulture) +
                        " / " + count.ToString(
                            System.Globalization.CultureInfo.InvariantCulture)
                    : string.Empty;
                AutomationProperties.SetName(
                    addonPreviewCounter, addonPreviewCounter.Text);
                AutomationProperties.SetItemStatus(
                    addonPreviewCounter, addonPreviewCounter.Text);
            }
            AddonDescriptor addon = previewAddon;
            int index = addonPreviewIndex;
            Image target = addonPreview;
            target.Source = null;
            if (addon == null) return;
            BitmapSource picture = await Task.Run(delegate { return LoadAddonImage(addon, index); });
            if (!closed && generation == previewGeneration && target == addonPreview)
                target.Source = picture;
        }

        private void UpdateAddonCompatibility(
            IList<CompatibilityIssue> issues)
        {
            if (addonCompatibility == null) {
                return;
            }
            addonCompatibility.Text = issues.Count == 0
                ? text.Get("No compatibility issues detected.")
                : JoinIssues(new List<CompatibilityIssue>(issues));
        }

        private static string JoinIssues(List<CompatibilityIssue> issues)
        {
            List<string> lines = new List<string>();
            foreach (CompatibilityIssue issue in issues) {
                string prefix = issue.Severity == CompatibilitySeverity.Error
                    ? "[ERROR] "
                    : issue.Severity == CompatibilitySeverity.Warning
                        ? "[WARNING] "
                        : "[INFO] ";
                lines.Add(prefix + issue.Message);
            }
            return string.Join(Environment.NewLine, lines.ToArray());
        }

        private void MoveSelectedAddon(int direction)
        {
            if (selectedAddons.Count < 2 || activeAddon == null) {
                return;
            }
            AddonDescriptor focused = FindAddon(
                selectedAddons, activeAddon.RelativePath);
            if (focused == null) {
                return;
            }
            int index = selectedAddons.IndexOf(focused);
            int target = index + direction;
            if (index < 0 || target < 0 || target >= selectedAddons.Count) {
                return;
            }
            selectedAddons.RemoveAt(index);
            selectedAddons.Insert(target, focused);
            ApplySelectedAddonsToOptions();
            PopulateAddonList();
            ShowAddonDetails(focused);
        }

        private void UpdateAddonMoveButtons()
        {
            int index = -1;
            if (activeAddon != null) {
                AddonDescriptor current = FindAddon(
                    selectedAddons, activeAddon.RelativePath);
                if (current != null) {
                    index = selectedAddons.IndexOf(current);
                }
            }
            if (addonMoveUp != null) {
                addonMoveUp.IsEnabled = index > 0;
            }
            if (addonMoveDown != null) {
                addonMoveDown.IsEnabled =
                    index >= 0 && index < selectedAddons.Count - 1;
            }
            if (addonResolveOrder != null) {
                addonResolveOrder.IsEnabled = selectedAddons.Count > 1;
            }
        }

        private static bool SameAddon(
            AddonDescriptor left, AddonDescriptor right)
        {
            return left != null && right != null &&
                string.Equals(
                    left.RelativePath, right.RelativePath,
                    StringComparison.OrdinalIgnoreCase);
        }

        private void ApplySelectedAddonsToOptions()
        {
            options.UseAddon = selectedAddons.Count > 0;
            options.SingleAddon = selectedAddons.Count == 1
                ? selectedAddons[0]
                : null;
            options.MultiAddons.Clear();
            if (selectedAddons.Count > 1) {
                options.MultiAddons.AddRange(selectedAddons);
            }
        }

        private void UpdateSinglePlayerSelection()
        {
            if (syncingStartMode || campaignDestination == null || singleMap == null) return;
            bool episodeSelected = campaignDestination.SelectedIndex == 1;
            BoaMap mission = singleMap.SelectedItem as BoaMap;
            if (singleDeathMode != null && singleDeathMode.SelectedValue is LauncherOptions.DeathAction)
                options.OnDeath = (LauncherOptions.DeathAction)singleDeathMode.SelectedValue;
            options.ContinueCampaign = false;
            options.ContinueSavePath = null;
            options.NewCampaign = episodeSelected && mission == null;
            options.DirectStart = episodeSelected && mission != null;
            BoaEpisode episode = singleEpisode.SelectedItem as BoaEpisode;
            if (mission != null) options.SinglePlayerStartMap = mission.Id;
            else if (episode != null && episode.Maps.Count > 0) options.SinglePlayerStartMap = episode.Maps[0].Id;
            if (singleSkill != null && singleSkill.SelectedItem is BoaSkill) {
                options.SinglePlayerSkill =
                    ((BoaSkill)singleSkill.SelectedItem).Number;
            }
            UpdateSummary();
        }

        private void UpdateMultiplayerValues()
        {
            if (multiplayerMap != null &&
                    multiplayerMap.SelectedItem is BoaMap) {
                options.MultiplayerStartMap =
                    ((BoaMap)multiplayerMap.SelectedItem).Id;
            }
            if (multiplayerSkill != null &&
                    multiplayerSkill.SelectedItem is BoaSkill) {
                options.MultiplayerSkill =
                    ((BoaSkill)multiplayerSkill.SelectedItem).Number;
            }
            int port;
            if (multiplayerPort != null &&
                    int.TryParse(multiplayerPort.Text, out port) &&
                    port >= 1 && port <= 65535) {
                options.MultiplayerPort = port;
            }
            if (multiplayerCheats != null) {
                options.MultiplayerCheats =
                    multiplayerCheats.IsChecked == true;
            }
            UpdateSummary();
        }

        private void UpdateMultiplayerPanels()
        {
            if (hostSettings == null || joinSettings == null) {
                return;
            }
            hostSettings.Visibility = options.NetworkMode == MultiplayerMode.Host
                ? Visibility.Visible
                : Visibility.Collapsed;
            joinSettings.Visibility = options.NetworkMode == MultiplayerMode.Join
                ? Visibility.Visible
                : Visibility.Collapsed;
        }

        private void UpdateSummary()
        {
            UpdateQuickLaunchControls();
            if (summaryText == null || footerStatus == null) {
                return;
            }
            string mode;
            if (options.NetworkMode == MultiplayerMode.Host) {
                mode = text.Get("Host co-op");
            } else if (options.NetworkMode == MultiplayerMode.Join) {
                mode = text.Get("Join co-op");
            } else {
                mode = text.Get("Single player");
            }
            string addons = options.NetworkMode == MultiplayerMode.SinglePlayer
                ? selectedAddons.Count.ToString(
                    System.Globalization.CultureInfo.InvariantCulture) +
                    " " + text.Get("Add-ons")
                : text.Get("No add-ons");
            summaryText.Text = mode + "  \u2022  " +
                options.Language.ToUpperInvariant() + "  \u2022  " +
                addons;
            footerStatus.Text = options.NetworkMode == MultiplayerMode.SinglePlayer
                ? options.ContinueCampaign && selectedSave != null
                    ? text.Get("Continue Campaign") + ": " +
                        selectedSave.DisplayTitle
                    : options.DirectStart || options.NewCampaign
                    ? (options.NewCampaign
                            ? text.Get("New Campaign")
                            : text.Get("Direct campaign start")) + ": " +
                        options.SinglePlayerStartMap + "  \u2022  " +
                        text.Get("Difficulty") + ": " +
                        GetSkillDisplayName(options.SinglePlayerSkill) +
                        "  \u2022  " + text.Get("Game language") + ": " +
                        GetLanguageDisplayName(options.Language)
                    : text.Get("Main menu will be shown")
                : text.Get("Add-ons are disabled in multiplayer.");
            UpdateCampaignActionSelection();
            if (campaignLaunchButton != null) {
                string label = text.Get(campaignDestination.SelectedIndex == 1 ? "Start New Campaign" : "Open Main Menu");
                ((TextBlock)((StackPanel)campaignLaunchButton.Content).Children[1]).Text = label;
                AutomationProperties.SetName(campaignLaunchButton, label);
                campaignLaunchButton.IsEnabled = options.NetworkMode == MultiplayerMode.SinglePlayer;
                AutomationProperties.SetItemStatus(campaignLaunchButton, CurrentLaunchTarget());
            }
            if (multiplayerLaunchButton != null) {
                multiplayerLaunchButton.IsEnabled = options.NetworkMode != MultiplayerMode.SinglePlayer;
                AutomationProperties.SetItemStatus(multiplayerLaunchButton, CurrentLaunchTarget());
            }
        }

        private void UpdateCampaignActionSelection()
        {
            bool singlePlayer = options.NetworkMode == MultiplayerMode.SinglePlayer;
            ApplyCommandButtonSelection(continueCampaignButton, singlePlayer);
        }

        private void ApplyCommandButtonSelection(Button button, bool selected)
        {
            if (button == null) return;
            button.Foreground = selected ? palette.AccentText : palette.Text;
            button.Background = selected
                ? palette.ButtonFill
                : palette.SurfaceAlternative;
            button.BorderBrush = selected ? palette.Accent : palette.Border;
            AutomationProperties.SetItemStatus(
                button, selected ? "Selected" : "NotSelected");
        }

        private string CurrentLaunchTarget()
        {
            if (options.NetworkMode == MultiplayerMode.Host) return "Host";
            if (options.NetworkMode == MultiplayerMode.Join) return "Join";
            if (options.ContinueCampaign) return "ContinueCampaign";
            if (options.DirectStart) return "MissionSelect";
            if (options.NewCampaign) return "NewCampaign";
            return "MainMenu";
        }

        private string GetSkillDisplayName(int number)
        {
            foreach (BoaSkill skill in contentCatalog.Skills) {
                if (skill.Number == number) {
                    return skill.DisplayName;
                }
            }
            return number.ToString(
                System.Globalization.CultureInfo.InvariantCulture);
        }

        private string GetLanguageDisplayName(string code)
        {
            string normalized = LauncherOptions.NormalizeGameLanguage(code);
            foreach (LanguageChoice language in GetLanguages()) {
                if (language.Code == normalized) {
                    return language.Name;
                }
            }
            return normalized.ToUpperInvariant();
        }

        private void LaunchGame() { LaunchSelectedSave(null); }

        private async void LaunchSelectedSave(string continuePath, bool recovery = false)
        {
            if (busy || closed) return;
            busy = true;
            root.IsEnabled = false;
            Cursor = Cursors.Wait;
            try {
                UpdateSinglePlayerSelection();
                UpdateMultiplayerValues();
                ApplySelectedAddonsToOptions();
                if (!recovery && options.NetworkMode == MultiplayerMode.SinglePlayer &&
                        options.UseAddon && selectedAddons.Count > 1) {
                    AddonLoadOrderResult order =
                        AddonLoadOrderResolver.Resolve(selectedAddons);
                    if (order.CanResolve && order.Changed) {
                        selectedAddons.Clear();
                        selectedAddons.AddRange(order.Ordered);
                        ApplySelectedAddonsToOptions();
                    }
                }
                LauncherOptions snapshot = options.Snapshot();
                LauncherOptions settingsSnapshot = options.Snapshot();
                if (recovery) {
                    snapshot.NetworkMode = MultiplayerMode.SinglePlayer;
                    snapshot.SafeMode = true;
                    snapshot.UseAddon = snapshot.ContinueCampaign = snapshot.DirectStart = snapshot.NewCampaign = false;
                    snapshot.SingleAddon = null;
                    snapshot.MultiAddons.Clear();
                    snapshot.ContinueSavePath = null;
                } else if (continuePath != null) {
                    snapshot.NetworkMode = MultiplayerMode.SinglePlayer;
                    snapshot.SafeMode = false;
                    snapshot.ContinueCampaign = true;
                    snapshot.ContinueSavePath = continuePath;
                }
                List<AddonDescriptor> selection = new List<AddonDescriptor>(selectedAddons);
                PreflightResult preflight = await Task.Run(delegate {
                    return LauncherPreflight.Inspect(snapshot, selection);
                });
                if (closed) return;
                ++validationGeneration;
                displayPreflight = preflight;
                if (snapshot.NetworkMode == MultiplayerMode.SinglePlayer) UpdateReadiness();
                if (!preflight.CanLaunch) {
                    Border notice = snapshot.NetworkMode == MultiplayerMode.SinglePlayer ? readinessBar : multiplayerNotice;
                    if (notice != null) {
                        if (notice != readinessBar) SetReadiness(notice, preflight);
                        notice.Visibility = Visibility.Visible;
                        notice.BringIntoView();
                    }
                    return;
                }
                if (snapshot.NetworkMode != MultiplayerMode.SinglePlayer && multiplayerNotice != null)
                    multiplayerNotice.Visibility = Visibility.Collapsed;
                if (snapshot.NetworkMode == MultiplayerMode.SinglePlayer && snapshot.ContinueCampaign) {
                    SavegameInfo selectedSave = FindSave(snapshot.ContinueSavePath);
                    if (selectedSave == null) {
                        MessageBox.Show(
                            text.Get("The selected savegame is no longer available."),
                            "Blade of Agony", MessageBoxButton.OK, MessageBoxImage.Warning);
                        return;
                    }
                    SaveCompatibilityResult saveStatus = await Task.Run(delegate {
                        return SavegameService.Check(SavegameService.Read(selectedSave.Path), snapshot);
                    });
                    if (closed) return;
                    if (!saveStatus.CanLaunch) {
                        MessageBox.Show(
                            JoinSaveIssues(saveStatus),
                            text.Get("Savegame compatibility"),
                            MessageBoxButton.OK,
                            MessageBoxImage.Error);
                        return;
                    }
                    if (saveStatus.Issues.Count > 0 && MessageBox.Show(
                            JoinSaveIssues(saveStatus) + "\n\n" + text.Get("Continue anyway?"),
                            text.Get("Savegame compatibility"),
                            MessageBoxButton.YesNo,
                            MessageBoxImage.Warning) != MessageBoxResult.Yes) {
                        return;
                    }
                } else if (ShouldWarnNewCampaignAddon(snapshot) &&
                        MessageBox.Show(
                            text.Get("One or more selected add-ons require a new campaign. Do not load an existing save with this selection.") +
                                "\n\n" + text.Get("Start a new campaign now?"),
                            text.Get("New campaign required"),
                            MessageBoxButton.YesNo,
                            MessageBoxImage.Warning) != MessageBoxResult.Yes) {
                    return;
                }
                if (snapshot.NetworkMode != MultiplayerMode.SinglePlayer) {
                    MultiplayerCompatibilityStatus status =
                        MultiplayerCompatibilityStatus.Inspect(baseDirectory);
                    if (!status.IsReady) {
                        ShowPage("diagnostics", true);
                        MessageBox.Show(
                            text.Get("Game files need attention."),
                            "Blade of Agony",
                            MessageBoxButton.OK,
                            MessageBoxImage.Warning);
                        return;
                    }
                    if (options.ImportedSessionRequiresPassword &&
                            string.IsNullOrEmpty(options.MultiplayerPassword)) {
                        MessageBox.Show(
                            text.Get("The imported session requires a password."),
                            "Blade of Agony",
                            MessageBoxButton.OK,
                            MessageBoxImage.Warning);
                        return;
                    }
                }
                await Task.Run(delegate {
                    settingsSnapshot.Save();
                    LauncherCommand.Start(snapshot);
                });
                if (closed) return;
                if (recovery) QueueValidationAsync();
                if (recoveryStatus != null && recoveryStatus.PreviousRunInterrupted) {
                    // Track has replaced the interrupted marker with the running process.
                    recoveryStatus.PreviousRunInterrupted = false;
                    RefreshPage("start", BuildStartPage);
                }
                footerStatus.Text = text.Get("Launch") + ": " + text.Get("Ready");
            } catch (Exception exception) {
                if (closed) return;
                MessageBox.Show(
                    exception.Message,
                    "Blade of Agony",
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
            } finally {
                FileFingerprint.Flush();
                busy = false;
                if (!closed) { root.IsEnabled = true; Cursor = null; }
            }
        }

        private async void RunWorkAsync(Action work, Action complete)
        {
            if (busy || closed) return;
            busy = true;
            UIElement surface = Content as UIElement;
            if (surface != null) surface.IsEnabled = false;
            Cursor = Cursors.Wait;
            try {
                await Task.Run(work);
                if (!closed) complete();
            } catch (Exception error) {
                if (!closed) MessageBox.Show(this, error.Message, "Blade of Agony",
                    MessageBoxButton.OK, MessageBoxImage.Error);
            } finally {
                FileFingerprint.Flush();
                busy = false;
                if (!closed) {
                    UIElement current = Content as UIElement;
                    if (current != null) current.IsEnabled = true;
                    Cursor = null;
                }
            }
        }

        private void RefreshDataAsync(DataScope scope, bool rebuildShell)
        {
            ++validationGeneration;
            if ((scope & DataScope.Saves) != 0) ++saveScanGeneration;
            LauncherOptions snapshot = options.Snapshot();
            string selectedSavePath = selectedSave == null
                ? string.Empty
                : selectedSave.Path;
            List<string> selectedPaths = selectedAddons.Select(
                delegate(AddonDescriptor addon) { return addon.RelativePath; }).ToList();
            BoaContentCatalog catalog = contentCatalog;
            BoaLauncherManifest manifest = launcherManifest;
            List<AddonDescriptor> addons = availableAddons;
            List<SavegameInfo> saves = savegames;
            EngineCapabilitySet capabilities = engineCapabilities;
            PreflightResult preflight = null;
            RunWorkAsync(delegate {
                if ((scope & DataScope.Content) != 0) {
                    catalog = BoaContentCatalog.Load(baseDirectory, snapshot.Language);
                    manifest = BoaLauncherManifest.Load(baseDirectory, catalog);
                }
                if ((scope & DataScope.Addons) != 0)
                    addons = AddonDescriptor.Scan(baseDirectory, snapshot.InterfaceLanguage);
                if ((scope & DataScope.Saves) != 0)
                    saves = SavegameService.Scan(baseDirectory);
                if ((scope & DataScope.Engine) != 0)
                    capabilities = EngineCapabilities.Detect(baseDirectory);
                preflight = LauncherPreflight.Inspect(snapshot, selectedPaths.Select(
                    delegate(string path) { return FindAddon(addons, path); }).Where(
                    delegate(AddonDescriptor addon) { return addon != null; }).ToList());
            }, delegate {
                bool initial = root == null;
                if ((scope & DataScope.Saves) != 0) loadingSaves = false;
                contentCatalog = catalog;
                launcherManifest = manifest;
                availableAddons = addons;
                if ((scope & DataScope.Saves) != 0) savegames = saves.Where(save => !save.IsMultiplayer).ToList();
                engineCapabilities = capabilities;
                displayPreflight = preflight;
                selectedAddons = selectedPaths.Select(delegate(string path) {
                    return FindAddon(availableAddons, path);
                }).Where(delegate(AddonDescriptor addon) { return addon != null; }).ToList();
                ApplySelectedAddonsToOptions();
                latestSave = savegames.Count > 0 ? savegames[0] : null;
                if ((scope & DataScope.Saves) != 0) selectedSave = FindSave(selectedSavePath) ?? latestSave;
                if (options.ContinueCampaign && FindSave(options.ContinueSavePath) == null)
                    options.ContinueCampaign = false;
                recoveryStatus = LaunchRecovery.Inspect(baseDirectory);
                if (rebuildShell || root == null) BuildShell();
                else {
                    if ((scope & DataScope.Content) != 0) RefreshSection(campaignHost, BuildCampaignSection);
                    if ((scope & DataScope.Saves) != 0) RefreshSection(continueHost, BuildContinuePanel);
                    if ((scope & DataScope.Addons) != 0) PopulateAddonList();
                    if (activePage == "diagnostics") RefreshPage("diagnostics", BuildDiagnosticsPage);
                    if (pages.ContainsKey("multiplayer") && (scope & DataScope.Engine) != 0) RefreshPage("multiplayer", BuildMultiplayerPage);
                    UpdateReadiness();
                    UpdateSummary();
                }
                if (initial && loadingSaves) LoadStartupSavesAsync();
            });
        }

        private async void LoadStartupSavesAsync()
        {
            int generation = ++saveScanGeneration;
            try {
                List<SavegameInfo> found = await Task.Run(delegate { return SavegameService.Scan(baseDirectory); });
                if (closed || generation != saveScanGeneration) return;
                savegames = found.Where(save => !save.IsMultiplayer).ToList();
                latestSave = savegames.FirstOrDefault();
                selectedSave = latestSave;
            } catch (Exception error) {
                if (!closed && generation == saveScanGeneration) footerStatus.Text = error.Message;
            } finally {
                if (!closed && generation == saveScanGeneration) {
                    loadingSaves = false;
                    RefreshSection(continueHost, BuildContinuePanel);
                    if (activePage == "diagnostics") RefreshPage("diagnostics", BuildDiagnosticsPage);
                }
            }
        }

        private void RefreshSection(ContentControl host, Func<FrameworkElement> build)
        {
            if (host == null) return;
            string focusedId = FocusedControlId();
            bool wasBuilding = building;
            building = true;
            try { host.Content = build(); }
            finally { building = wasBuilding; }
            UpdateSummary();
            RestoreFocus(focusedId);
        }

        private static string FocusedControlId()
        {
            DependencyObject focused = Keyboard.FocusedElement as DependencyObject;
            return focused == null ? string.Empty : AutomationProperties.GetAutomationId(focused);
        }

        private void RestoreFocus(string id)
        {
            if (string.IsNullOrEmpty(id)) return;
            Dispatcher.BeginInvoke(DispatcherPriority.Loaded, new Action(delegate {
                if (closed) return;
                FrameworkElement control = FindControl(this, id);
                if (control != null && control.IsVisible && control.IsEnabled) control.Focus();
            }));
        }

        private static FrameworkElement FindControl(DependencyObject parent, string id)
        {
            FrameworkElement control = parent as FrameworkElement;
            if (control != null && AutomationProperties.GetAutomationId(control) == id) return control;
            for (int index = 0; index < VisualTreeHelper.GetChildrenCount(parent); index++) {
                FrameworkElement found = FindControl(VisualTreeHelper.GetChild(parent, index), id);
                if (found != null) return found;
            }
            return null;
        }

        private void RefreshPage(string key, Func<FrameworkElement> build)
        {
            if (pageHost == null) return;
            FrameworkElement old;
            double offset = 0;
            if (pages.TryGetValue(key, out old)) {
                ScrollViewer scroll = old as ScrollViewer;
                if (scroll != null) offset = scroll.VerticalOffset;
                pageHost.Children.Remove(old);
            }
            bool wasBuilding = building;
            building = true;
            try {
                FrameworkElement page = build();
                AddPage(key, page);
                page.Visibility = key == activePage ? Visibility.Visible : Visibility.Collapsed;
                ScrollViewer scroll = page as ScrollViewer;
                if (scroll != null) scroll.ScrollToVerticalOffset(offset);
            } finally { building = wasBuilding; }
        }

        private static List<AddonDescriptor> ReadPersistedSelection(
            LauncherOptions launcherOptions)
        {
            List<AddonDescriptor> result = new List<AddonDescriptor>();
            if (!launcherOptions.UseAddon) {
                return result;
            }
            if (launcherOptions.MultiAddons.Count > 0) {
                result.AddRange(launcherOptions.MultiAddons);
            } else if (launcherOptions.SingleAddon != null) {
                result.Add(launcherOptions.SingleAddon);
            }
            return result;
        }

        private static AddonDescriptor FindAddon(
            IList<AddonDescriptor> addons, string relativePath)
        {
            foreach (AddonDescriptor addon in addons) {
                if (string.Equals(
                        addon.RelativePath, relativePath,
                        StringComparison.OrdinalIgnoreCase)) {
                    return addon;
                }
            }
            return null;
        }

        private void SelectEpisodeForMap(ComboBox combo, string map)
        {
            BoaEpisode selected = null;
            foreach (BoaEpisode episode in contentCatalog.Episodes) {
                foreach (BoaMap candidate in episode.Maps) {
                    if (candidate.Id == map) {
                        selected = episode;
                    }
                }
            }
            combo.SelectedItem = selected ??
                (combo.Items.Count > 0 ? combo.Items[0] : null);
        }

        private void PopulateMapCombo(
            ComboBox episodeCombo, ComboBox mapCombo, string selectedMap)
        {
            mapCombo.Items.Clear();
            BoaEpisode episode = episodeCombo.SelectedItem as BoaEpisode;
            if (episode == null) {
                return;
            }
            foreach (BoaMap map in episode.Maps) {
                mapCombo.Items.Add(map);
                if (map.Id == selectedMap) {
                    mapCombo.SelectedItem = map;
                }
            }
            if (mapCombo.SelectedItem == null && mapCombo.Items.Count > 0) {
                mapCombo.SelectedIndex = 0;
            }
        }

        private void PopulateSkillCombo(ComboBox combo, int selected)
        {
            foreach (BoaSkill skill in contentCatalog.Skills) {
                combo.Items.Add(skill);
                if (skill.Number == selected) {
                    combo.SelectedItem = skill;
                }
            }
            if (combo.SelectedItem == null && combo.Items.Count > 0) {
                combo.SelectedIndex = Math.Min(2, combo.Items.Count - 1);
            }
        }

        private StackPanel CreatePageContent()
        {
            return new StackPanel {
                Margin = new Thickness(28, 24, 28, 28),
                MaxWidth = 1120,
                HorizontalAlignment = HorizontalAlignment.Stretch
            };
        }

        private FrameworkElement WrapPage(FrameworkElement content)
        {
            return new ScrollViewer {
                Content = content,
                VerticalScrollBarVisibility = ScrollBarVisibility.Auto,
                HorizontalScrollBarVisibility = ScrollBarVisibility.Disabled,
                PanningMode = PanningMode.VerticalOnly
            };
        }

        private FrameworkElement CreatePageTitle(
            string title, string subtitle, string headingAutomationId)
        {
            StackPanel panel = new StackPanel();
            panel.Children.Add(CreateHeading(title, headingAutomationId));
            panel.Children.Add(new TextBlock {
                Text = subtitle,
                Foreground = palette.Muted,
                Margin = new Thickness(0, 5, 0, 0)
            });
            return panel;
        }

        private SavegameInfo FindSave(string path)
        {
            foreach (SavegameInfo save in savegames) {
                if (string.Equals(save.Path, path, StringComparison.OrdinalIgnoreCase)) {
                    return save;
                }
            }
            return null;
        }

        private static string JoinSaveIssues(SaveCompatibilityResult status)
        {
            List<string> messages = new List<string>();
            foreach (SaveCompatibilityIssue issue in status.Issues) {
                messages.Add(issue.Message);
            }
            return string.Join(Environment.NewLine, messages.ToArray());
        }

        internal static bool ShouldWarnNewCampaignAddon(LauncherOptions options)
        {
            if (options.NetworkMode != MultiplayerMode.SinglePlayer || options.SafeMode || options.ContinueCampaign ||
                    options.NewCampaign || options.DirectStart || !options.UseAddon) return false;
            if (options.MultiAddons.Count > 0) {
                foreach (AddonDescriptor addon in options.MultiAddons) {
                    if (addon.NewCampaignRequired) return true;
                }
                return false;
            }
            return options.SingleAddon != null && options.SingleAddon.NewCampaignRequired;
        }


        private void ExportSession()
        {
            UpdateMultiplayerValues();
            if (options.NetworkMode != MultiplayerMode.Host) {
                MessageBox.Show(
                    text.Get("Select Host co-op before exporting a session."),
                    "Blade of Agony", MessageBoxButton.OK, MessageBoxImage.Information);
                return;
            }
            Microsoft.Win32.SaveFileDialog dialog = new Microsoft.Win32.SaveFileDialog {
                Title = text.Get("Export session"),
                Filter = "Blade of Agony session (*.boa-session)|*.boa-session",
                FileName = "Blade-of-Agony-session.boa-session",
                AddExtension = true,
                DefaultExt = ".boa-session"
            };
            if (dialog.ShowDialog(this) == true) {
                string path = dialog.FileName;
                LauncherOptions snapshot = options.Snapshot();
                RunWorkAsync(delegate {
                    MultiplayerSessionFile.Save(path, MultiplayerSessionFile.Create(snapshot));
                }, delegate { footerStatus.Text = text.Get("Session exported without the password."); });
            }
        }

        private void ImportSession()
        {
            Microsoft.Win32.OpenFileDialog dialog = new Microsoft.Win32.OpenFileDialog {
                Title = text.Get("Import session"),
                Filter = "Blade of Agony session (*.boa-session)|*.boa-session"
            };
            if (dialog.ShowDialog(this) != true) return;
            string path = dialog.FileName;
            BoaMultiplayerSession session = null;
            SessionValidation validation = null;
            RunWorkAsync(delegate {
                session = MultiplayerSessionFile.Load(path);
                validation = MultiplayerSessionFile.Validate(baseDirectory, session);
            }, delegate {
            if (!validation.IsCompatible) {
                MessageBox.Show(
                    string.Join(Environment.NewLine, validation.Errors.ToArray()),
                    text.Get("Session compatibility"),
                    MessageBoxButton.OK,
                    MessageBoxImage.Error);
                return;
            }
            MultiplayerSessionFile.Apply(options, session);
            activePage = "multiplayer";
            RefreshPage("multiplayer", BuildMultiplayerPage);
            ShowPage("multiplayer", false);
            if (validation.Warnings.Count > 0) {
                MessageBox.Show(
                    string.Join(Environment.NewLine, validation.Warnings.ToArray()),
                    text.Get("Session compatibility"),
                    MessageBoxButton.OK,
                    MessageBoxImage.Information);
            }
            });
        }

        private void CreateSupportPackage()
        {
            Microsoft.Win32.SaveFileDialog dialog = new Microsoft.Win32.SaveFileDialog {
                Title = text.Get("Create support package"),
                Filter = "ZIP archive (*.zip)|*.zip",
                FileName = "Blade-of-Agony-support.zip",
                AddExtension = true,
                DefaultExt = ".zip"
            };
            if (dialog.ShowDialog(this) == true) {
                string path = dialog.FileName;
                LauncherOptions snapshot = options.Snapshot();
                RunWorkAsync(delegate { DiagnosticsPackage.Create(path, snapshot); },
                    delegate { footerStatus.Text = text.Get("Support package created."); });
            }
        }


        private void HandleGamepadAction(GamepadAction action)
        {
            if (busy || closed || root == null || !IsActive) return;
            IInputElement focused = Keyboard.FocusedElement;
            ComboBox combo = focused as ComboBox;
            if (action == GamepadAction.Back) {
                if (combo != null && combo.IsDropDownOpen) combo.IsDropDownOpen = false;
                else ShowPage("start", true);
                return;
            }
            if (action == GamepadAction.PreviousPage || action == GamepadAction.NextPage) {
                string[] order = { "start", "addons", "multiplayer", "diagnostics" };
                int index = Array.IndexOf(order, activePage);
                index = (index + (action == GamepadAction.NextPage ? 1 : order.Length - 1)) % order.Length;
                ShowPage(order[index], true);
                navigationButtons[order[index]].Focus();
                return;
            }
            if (action == GamepadAction.Accept) {
                if (combo != null) {
                    combo.IsDropDownOpen = !combo.IsDropDownOpen;
                    return;
                }
                Expander expander = focused as Expander;
                if (expander != null && expander.IsEnabled) {
                    expander.IsExpanded = !expander.IsExpanded;
                    return;
                }
                ToggleButton toggle = focused as ToggleButton;
                if (toggle != null && toggle.IsEnabled) {
                    toggle.IsChecked = toggle is RadioButton || toggle.IsChecked != true;
                    return;
                }
                ButtonBase button = focused as ButtonBase;
                if (button != null && button.IsEnabled) {
                    button.RaiseEvent(new RoutedEventArgs(ButtonBase.ClickEvent));
                }
                return;
            }
            if (combo != null && !combo.IsDropDownOpen &&
                    (action == GamepadAction.Left || action == GamepadAction.Right)) {
                int delta = action == GamepadAction.Right ? 1 : -1;
                combo.SelectedIndex = Math.Max(0, Math.Min(
                    combo.Items.Count - 1, combo.SelectedIndex + delta));
                return;
            }
            UIElement element = focused as UIElement;
            if (element == null) {
                Button target = activePage == "multiplayer" ? multiplayerLaunchButton : activePage == "start" ? campaignLaunchButton : navigationButtons[activePage];
                if (target != null && target.IsEnabled && target.IsVisible) target.Focus();
                else navigationButtons[activePage].Focus();
                return;
            }
            FocusNavigationDirection direction = action == GamepadAction.Up
                ? FocusNavigationDirection.Up
                : action == GamepadAction.Down
                    ? FocusNavigationDirection.Down
                    : action == GamepadAction.Left
                        ? FocusNavigationDirection.Left
                        : FocusNavigationDirection.Right;
            element.MoveFocus(new TraversalRequest(direction));
        }

        private CheckBox CreateCheckBox(string label, bool value)
        {
            CheckBox checkBox = new CheckBox {
                Content = label,
                IsChecked = value,
                Foreground = palette.Text,
                MinHeight = 30,
                VerticalContentAlignment = VerticalAlignment.Center,
                Margin = new Thickness(0, 3, 0, 7),
                Cursor = Cursors.Hand
            };
            checkBox.Template = CreateCheckBoxTemplate(palette.Accent);
            AutomationProperties.SetName(checkBox, label);
            return checkBox;
        }

        private ControlTemplate CreateCheckBoxTemplate(Brush checkedBrush)
        {
            FrameworkElementFactory panel =
                new FrameworkElementFactory(typeof(DockPanel));

            FrameworkElementFactory box =
                new FrameworkElementFactory(typeof(Border), "CheckBoxBox");
            box.SetValue(FrameworkElement.WidthProperty, 16.0);
            box.SetValue(FrameworkElement.HeightProperty, 16.0);
            box.SetValue(FrameworkElement.VerticalAlignmentProperty,
                VerticalAlignment.Center);
            box.SetValue(Border.BackgroundProperty, palette.Surface);
            box.SetValue(Border.BorderBrushProperty, palette.Border);
            box.SetValue(Border.BorderThicknessProperty, new Thickness(1));
            box.SetValue(Border.CornerRadiusProperty, new CornerRadius(3));
            box.SetValue(DockPanel.DockProperty, Dock.Left);

            FrameworkElementFactory mark =
                new FrameworkElementFactory(typeof(TextBlock), "CheckBoxMark");
            mark.SetValue(TextBlock.TextProperty, "\u2713");
            mark.SetValue(TextBlock.FontFamilyProperty,
                new FontFamily("Segoe UI Symbol"));
            mark.SetValue(TextBlock.FontSizeProperty, 12.0);
            mark.SetValue(TextBlock.FontWeightProperty, FontWeights.Bold);
            mark.SetValue(TextBlock.ForegroundProperty, palette.Text);
            mark.SetValue(TextBlock.HorizontalAlignmentProperty,
                HorizontalAlignment.Center);
            mark.SetValue(TextBlock.VerticalAlignmentProperty,
                VerticalAlignment.Center);
            mark.SetValue(TextBlock.VisibilityProperty, Visibility.Hidden);
            box.AppendChild(mark);
            panel.AppendChild(box);

            FrameworkElementFactory presenter =
                new FrameworkElementFactory(typeof(ContentPresenter));
            presenter.SetBinding(
                ContentPresenter.ContentProperty,
                new System.Windows.Data.Binding("Content") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            presenter.SetBinding(
                ContentPresenter.ContentTemplateProperty,
                new System.Windows.Data.Binding("ContentTemplate") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            presenter.SetValue(FrameworkElement.VerticalAlignmentProperty,
                VerticalAlignment.Center);
            presenter.SetValue(FrameworkElement.MarginProperty,
                new Thickness(8, 0, 0, 0));
            panel.AppendChild(presenter);

            ControlTemplate template = new ControlTemplate(typeof(CheckBox));
            template.VisualTree = panel;
            Trigger selected = new Trigger {
                Property = CheckBox.IsCheckedProperty,
                Value = true
            };
            selected.Setters.Add(new Setter(
                Border.BackgroundProperty, checkedBrush, "CheckBoxBox"));
            selected.Setters.Add(new Setter(
                Border.BorderBrushProperty, checkedBrush, "CheckBoxBox"));
            selected.Setters.Add(new Setter(
                TextBlock.VisibilityProperty, Visibility.Visible, "CheckBoxMark"));
            template.Triggers.Add(selected);
            Trigger focus = new Trigger {
                Property = CheckBox.IsKeyboardFocusedProperty,
                Value = true
            };
            focus.Setters.Add(new Setter(
                Border.BorderBrushProperty, palette.Text, "CheckBoxBox"));
            focus.Setters.Add(new Setter(
                Border.BorderThicknessProperty, new Thickness(2), "CheckBoxBox"));
            template.Triggers.Add(focus);
            Trigger disabled = new Trigger {
                Property = CheckBox.IsEnabledProperty,
                Value = false
            };
            disabled.Setters.Add(new Setter(CheckBox.OpacityProperty, 0.45));
            template.Triggers.Add(disabled);
            return template;
        }

        private RadioButton CreateModeRadio(string label, bool selected)
        {
            RadioButton radio = new RadioButton {
                Content = label,
                GroupName = "NetworkMode",
                IsChecked = selected,
                Foreground = palette.Text,
                Background = palette.Surface,
                BorderBrush = palette.Border,
                Margin = new Thickness(0, 0, 26, 0),
                MinHeight = 32,
                VerticalContentAlignment = VerticalAlignment.Center,
                Cursor = Cursors.Hand
            };
            radio.Template = CreateModeRadioTemplate();
            AutomationProperties.SetName(radio, label);
            AutomationProperties.SetItemStatus(radio, "Centered");
            return radio;
        }

        private ControlTemplate CreateModeRadioTemplate()
        {
            FrameworkElementFactory panel =
                new FrameworkElementFactory(typeof(DockPanel));

            FrameworkElementFactory indicator =
                new FrameworkElementFactory(typeof(Border), "RadioIndicator");
            indicator.SetValue(FrameworkElement.WidthProperty, 16.0);
            indicator.SetValue(FrameworkElement.HeightProperty, 16.0);
            indicator.SetValue(FrameworkElement.VerticalAlignmentProperty,
                VerticalAlignment.Center);
            indicator.SetValue(Border.BackgroundProperty, palette.Surface);
            indicator.SetValue(Border.BorderBrushProperty, palette.Border);
            indicator.SetValue(Border.BorderThicknessProperty, new Thickness(1));
            indicator.SetValue(Border.CornerRadiusProperty, new CornerRadius(8));
            indicator.SetValue(DockPanel.DockProperty, Dock.Left);

            FrameworkElementFactory dot =
                new FrameworkElementFactory(typeof(Border), "RadioDot");
            dot.SetValue(FrameworkElement.WidthProperty, 8.0);
            dot.SetValue(FrameworkElement.HeightProperty, 8.0);
            dot.SetValue(FrameworkElement.HorizontalAlignmentProperty,
                HorizontalAlignment.Center);
            dot.SetValue(FrameworkElement.VerticalAlignmentProperty,
                VerticalAlignment.Center);
            dot.SetValue(Border.BackgroundProperty, palette.Accent);
            dot.SetValue(Border.CornerRadiusProperty, new CornerRadius(4));
            dot.SetValue(UIElement.VisibilityProperty, Visibility.Hidden);
            indicator.AppendChild(dot);
            panel.AppendChild(indicator);

            FrameworkElementFactory presenter =
                new FrameworkElementFactory(typeof(ContentPresenter));
            presenter.SetBinding(
                ContentPresenter.ContentProperty,
                new System.Windows.Data.Binding("Content") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            presenter.SetBinding(
                ContentPresenter.ContentTemplateProperty,
                new System.Windows.Data.Binding("ContentTemplate") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            presenter.SetValue(FrameworkElement.VerticalAlignmentProperty,
                VerticalAlignment.Center);
            presenter.SetValue(FrameworkElement.MarginProperty,
                new Thickness(9, 0, 0, 0));
            panel.AppendChild(presenter);

            ControlTemplate template = new ControlTemplate(typeof(RadioButton));
            template.VisualTree = panel;
            Trigger selected = new Trigger {
                Property = RadioButton.IsCheckedProperty,
                Value = true
            };
            selected.Setters.Add(new Setter(
                Border.BorderBrushProperty, palette.Accent, "RadioIndicator"));
            selected.Setters.Add(new Setter(
                UIElement.VisibilityProperty, Visibility.Visible, "RadioDot"));
            template.Triggers.Add(selected);
            Trigger focused = new Trigger {
                Property = RadioButton.IsKeyboardFocusedProperty,
                Value = true
            };
            focused.Setters.Add(new Setter(
                Border.BorderBrushProperty, palette.Text, "RadioIndicator"));
            focused.Setters.Add(new Setter(
                Border.BorderThicknessProperty, new Thickness(2), "RadioIndicator"));
            template.Triggers.Add(focused);
            Trigger disabled = new Trigger {
                Property = RadioButton.IsEnabledProperty,
                Value = false
            };
            disabled.Setters.Add(new Setter(RadioButton.OpacityProperty, 0.45));
            template.Triggers.Add(disabled);
            return template;
        }

        private TextBlock CreateBodyText()
        {
            return new TextBlock {
                Foreground = palette.Text,
                TextWrapping = TextWrapping.Wrap,
                LineHeight = 20
            };
        }

        private LanguageChoice[] GetLanguages()
        {
            return new[] {
                new LanguageChoice { Code = "last", Name = text.Get("Use last settings") },
                new LanguageChoice { Code = "auto", Name = "Auto" },
                new LanguageChoice { Code = "en-US", Name = "English (US)" },
                new LanguageChoice { Code = "en-GB", Name = "English (UK)" },
                new LanguageChoice { Code = "de", Name = "Deutsch" },
                new LanguageChoice { Code = "es", Name = "Espa\u00f1ol" },
                new LanguageChoice { Code = "ru", Name = "\u0420\u0443\u0441\u0441\u043a\u0438\u0439" },
                new LanguageChoice { Code = "pt-PT", Name = "Portugu\u00eas (European)" },
                new LanguageChoice { Code = "it", Name = "Italiano" },
                new LanguageChoice { Code = "tr", Name = "T\u00fcrk\u00e7e" },
                new LanguageChoice { Code = "fr", Name = "Fran\u00e7ais" },
                new LanguageChoice { Code = "cs", Name = "\u010ce\u0161tina" },
                new LanguageChoice { Code = "pl", Name = "Polski" }
            };
        }

        private BitmapSource LoadEmbeddedImage(string resourceName)
        {
            Stream stream = Assembly.GetExecutingAssembly()
                .GetManifestResourceStream(resourceName);
            if (stream == null) {
                return null;
            }
            using (stream) {
                return LoadBitmap(stream);
            }
        }

        private FontFamily LoadEmbeddedFontFamily(
            string resourceName, string fileName, string familyName)
        {
            try {
                Stream resource = Assembly.GetExecutingAssembly()
                    .GetManifestResourceStream(resourceName);
                if (resource == null) {
                    return FontFamily;
                }
                using (resource) {
                    string directory = Path.Combine(
                        Path.GetTempPath(),
                        "BladeOfAgonyLauncher",
                        "Fonts");
                    Directory.CreateDirectory(directory);
                    string path = Path.Combine(directory, fileName);
                    if (!File.Exists(path) ||
                        new FileInfo(path).Length != resource.Length) {
                        using (FileStream output = File.Create(path)) {
                            resource.CopyTo(output);
                        }
                    }
                    FontFamily family = new FontFamily(
                        new Uri(
                            directory.TrimEnd(Path.DirectorySeparatorChar) +
                            Path.DirectorySeparatorChar,
                            UriKind.Absolute),
                        "./#" + familyName);
                    GlyphTypeface glyphTypeface;
                    Typeface typeface = new Typeface(
                        family,
                        FontStyles.Normal,
                        FontWeights.Normal,
                        FontStretches.Normal);
                    return typeface.TryGetGlyphTypeface(out glyphTypeface)
                        ? family
                        : FontFamily;
                }
            } catch {
                return FontFamily;
            }
        }

        private string GetEngineVersionLabel()
        {
            string executable = LauncherPaths.EngineExecutable(baseDirectory);
            if (!File.Exists(executable)) {
                return "UZDoom not found";
            }
            try {
                FileVersionInfo version = FileVersionInfo.GetVersionInfo(executable);
                string product = string.IsNullOrWhiteSpace(version.ProductName)
                    ? "UZDoom"
                    : version.ProductName.Trim();
                string number = string.IsNullOrWhiteSpace(version.ProductVersion)
                    ? version.FileVersion
                    : version.ProductVersion;
                string label = string.IsNullOrWhiteSpace(number)
                    ? product
                    : product + " " + number.Trim();
                EngineReleaseChannel channel =
                    EngineVersionSupport.ReleaseChannel(baseDirectory);
                if (channel == EngineReleaseChannel.Preview) {
                    label += " (Preview)";
                } else if (channel == EngineReleaseChannel.Stable) {
                    label += " (Stable)";
                } else if (channel == EngineReleaseChannel.Unsupported) {
                    label += " (Unsupported)";
                }
                return label;
            }
            catch {
                return "UZDoom version unavailable";
            }
        }

        private BitmapSource LoadAddonImage(
            AddonDescriptor addon, int oneBasedIndex)
        {
            try {
                return imageCache.Get(addon.DescriptorPath, "addon-" + oneBasedIndex,
                    delegate { return ReadAddonImage(addon, oneBasedIndex); });
            } catch { return null; }
        }

        private BitmapSource ReadAddonImage(AddonDescriptor addon, int oneBasedIndex)
        {
            try {
                using (ZipArchive archive = ZipFile.OpenRead(addon.DescriptorPath)) {
                    ZipArchiveEntry found = null;
                    List<string> names = new List<string>();
                    if (oneBasedIndex >= 1 &&
                        oneBasedIndex <= addon.PreviewImages.Count) {
                        names.Add(addon.PreviewImages[oneBasedIndex - 1]);
                    } else if (oneBasedIndex >= 1) {
                        string prefix = "preview/" +
                            oneBasedIndex.ToString(
                                System.Globalization.CultureInfo.InvariantCulture);
                        names.Add(prefix + ".jpg");
                        names.Add(prefix + ".jpeg");
                        names.Add(prefix + ".png");
                    }
                    names.Add("preview/icon.png");
                    foreach (string name in names) {
                        foreach (ZipArchiveEntry entry in archive.Entries) {
                            if (string.Equals(
                                    entry.FullName.Replace('\\', '/'), name,
                                    StringComparison.OrdinalIgnoreCase)) {
                                found = entry;
                                break;
                            }
                        }
                        if (found != null) {
                            break;
                        }
                    }
                    if (found == null) {
                        return null;
                    }
                    using (Stream stream = found.Open()) {
                        return LoadBitmap(stream, 1280);
                    }
                }
            } catch {
                return null;
            }
        }

        private static BitmapSource LoadBitmap(Stream stream, int decodeWidth = 0)
        {
            MemoryStream copy = new MemoryStream();
            stream.CopyTo(copy);
            copy.Position = 0;
            BitmapImage image = new BitmapImage();
            image.BeginInit();
            image.CacheOption = BitmapCacheOption.OnLoad;
            if (decodeWidth > 0) image.DecodePixelWidth = decodeWidth;
            image.StreamSource = copy;
            image.EndInit();
            image.Freeze();
            copy.Dispose();
            return image;
        }

        private void SetWindowIcon()
        {
            try {
                Stream stream = Assembly.GetExecutingAssembly()
                    .GetManifestResourceStream("BladeLauncher.main.ico");
                if (stream != null) {
                    using (stream) {
                        Icon = BitmapFrame.Create(
                            stream,
                            BitmapCreateOptions.PreservePixelFormat,
                            BitmapCacheOption.OnLoad);
                    }
                }
            } catch {
                // The executable still has its native icon if WPF cannot decode it.
            }
        }

        private void UpdateResponsiveLayout()
        {
            if (navigationColumn == null) {
                return;
            }
            bool compact = ActualWidth < 900;
            navigationColumn.Width = new GridLength(compact ? 66 : 216);
            foreach (TextBlock label in navigationLabels) {
                label.Visibility = compact
                    ? Visibility.Collapsed
                    : Visibility.Visible;
            }
            if (navigationVersion != null) {
                navigationVersion.Visibility = compact
                    ? Visibility.Collapsed
                    : Visibility.Visible;
            }
        }
    }
}
