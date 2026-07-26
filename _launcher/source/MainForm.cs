using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Windows.Forms;

namespace BladeOfAgonyLauncher
{
    internal sealed class MainForm : Form
    {
        [DllImport("dwmapi.dll")]
        private static extern int DwmSetWindowAttribute(
            IntPtr window, int attribute, ref int value, int valueSize);

        private sealed class LanguageChoice
        {
            internal readonly string Code;
            internal readonly string Label;

            internal LanguageChoice(string code, string label)
            {
                Code = code;
                Label = label;
            }

            public override string ToString()
            {
                return Label;
            }
        }

        private sealed class NoAddonChoice
        {
            private readonly string label;

            internal NoAddonChoice(string label)
            {
                this.label = label;
            }

            public override string ToString()
            {
                return label;
            }
        }

        private sealed class ThemePalette
        {
            internal Color Background;
            internal Color Surface;
            internal Color Input;
            internal Color Text;
            internal Color MutedText;
            internal Color Border;
            internal Color Accent;
            internal Color AccentText;
            internal Color Error;
            internal bool DarkTitleBar;

            internal static ThemePalette For(LauncherTheme theme)
            {
                if (theme == LauncherTheme.Light) {
                    return new ThemePalette {
                        Background = Color.FromArgb(240, 240, 240),
                        Surface = Color.White,
                        Input = Color.White,
                        Text = Color.FromArgb(30, 30, 30),
                        MutedText = Color.FromArgb(100, 100, 100),
                        Border = Color.FromArgb(200, 200, 200),
                        Accent = Color.FromArgb(0, 102, 153),
                        AccentText = Color.White,
                        Error = Color.FromArgb(180, 35, 24),
                        DarkTitleBar = false
                    };
                }
                if (theme == LauncherTheme.BladeOfAgony) {
                    return new ThemePalette {
                        Background = Color.FromArgb(0x11, 0x27, 0x3A),
                        Surface = Color.FromArgb(0x19, 0x34, 0x4A),
                        Input = Color.FromArgb(0x0B, 0x1D, 0x2B),
                        Text = Color.FromArgb(238, 244, 248),
                        MutedText = Color.FromArgb(175, 192, 206),
                        Border = Color.FromArgb(53, 80, 102),
                        Accent = Color.FromArgb(0x66, 0x81, 0x97),
                        AccentText = Color.White,
                        Error = Color.FromArgb(224, 122, 122),
                        DarkTitleBar = true
                    };
                }
                return new ThemePalette {
                    Background = Color.FromArgb(0x3B, 0x3B, 0x3B),
                    Surface = Color.FromArgb(72, 72, 72),
                    Input = Color.FromArgb(43, 43, 43),
                    Text = Color.FromArgb(242, 242, 242),
                    MutedText = Color.FromArgb(190, 190, 190),
                    Border = Color.FromArgb(82, 82, 82),
                    Accent = Color.FromArgb(102, 129, 151),
                    AccentText = Color.White,
                    Error = Color.FromArgb(224, 122, 122),
                    DarkTitleBar = true
                };
            }
        }

        private sealed class CoverPictureBox : Control
        {
            private Image image;

            internal Image Image
            {
                get { return image; }
                set
                {
                    image = value;
                    Invalidate();
                }
            }

            internal CoverPictureBox()
            {
                SetStyle(
                    ControlStyles.AllPaintingInWmPaint |
                    ControlStyles.OptimizedDoubleBuffer |
                    ControlStyles.ResizeRedraw |
                    ControlStyles.UserPaint,
                    true);
                BackColor = Color.Black;
            }

            protected override void OnPaint(PaintEventArgs e)
            {
                e.Graphics.Clear(BackColor);
                if (image == null || ClientSize.Width < 1 || ClientSize.Height < 1) {
                    return;
                }

                RectangleF source = PreviewLayout.CoverSource(image.Size, ClientSize);

                e.Graphics.InterpolationMode = InterpolationMode.HighQualityBicubic;
                e.Graphics.PixelOffsetMode = PixelOffsetMode.HighQuality;
                e.Graphics.DrawImage(
                    image,
                    new Rectangle(0, 0, ClientSize.Width, ClientSize.Height),
                    source,
                    GraphicsUnit.Pixel);
            }
        }

        private sealed class ChevronButton : Button
        {
            private readonly int direction;

            internal ChevronButton(int direction)
            {
                this.direction = direction < 0 ? -1 : 1;
                Text = string.Empty;
            }

            protected override void OnPaint(PaintEventArgs eventArgs)
            {
                base.OnPaint(eventArgs);
                eventArgs.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
                int centerX = ClientSize.Width / 2;
                int centerY = ClientSize.Height / 2;
                int tipX = centerX + direction * 2;
                int edgeX = centerX - direction * 2;
                using (Pen pen = new Pen(ForeColor, 1.6f)) {
                    eventArgs.Graphics.DrawLine(pen, edgeX, centerY - 4, tipX, centerY);
                    eventArgs.Graphics.DrawLine(pen, tipX, centerY, edgeX, centerY + 4);
                }
            }
        }

        private readonly string baseDirectory;
        private PoCatalog catalog;
        private readonly LauncherOptions options;
        private readonly List<AddonDescriptor> addons = new List<AddonDescriptor>();

        private readonly ThemedComboBox detailCombo = new ThemedComboBox();
        private readonly ThemedComboBox displacementCombo = new ThemedComboBox();
        private readonly ThemedComboBox languageCombo = new ThemedComboBox();
        private readonly ThemedComboBox interfaceLanguageCombo = new ThemedComboBox();
        private readonly ThemedComboBox themeCombo = new ThemedComboBox();
        private readonly ThemedCheckBox commentaryCheck = new ThemedCheckBox();
        private readonly ThemedSegmentedControl multiplayerModeControl =
            new ThemedSegmentedControl();
        private readonly TableLayoutPanel multiplayerSettingsPanel = new TableLayoutPanel();
        private readonly Label multiplayerPlayersLabel = new Label();
        private readonly Label multiplayerStartMapLabel = new Label();
        private readonly Label multiplayerHostLabel = new Label();
        private readonly Label multiplayerPortLabel = new Label();
        private readonly Label multiplayerSkillLabel = new Label();
        private readonly Label multiplayerValidation = new Label();
        private readonly ThemedNumericUpDown multiplayerPlayers = new ThemedNumericUpDown();
        private readonly ThemedTextBox multiplayerStartMap = new ThemedTextBox();
        private readonly ThemedTextBox multiplayerHost = new ThemedTextBox();
        private readonly ThemedNumericUpDown multiplayerPort = new ThemedNumericUpDown();
        private readonly ThemedNumericUpDown multiplayerSkill = new ThemedNumericUpDown();
        private readonly ThemedCheckBox multiplayerCheats = new ThemedCheckBox();
        private readonly ListBox addonList = new ListBox();
        private readonly ThemedBorderPanel addonListFrame = new ThemedBorderPanel();
        private readonly Label addonStatus = new Label();
        private readonly Label addonTitle = new Label();
        private readonly Label addonCredits = new Label();
        private readonly TextBox addonDescription = new TextBox();
        private readonly CoverPictureBox previewBox = new CoverPictureBox();
        private readonly Label previewCounter = new Label();
        private readonly Button playButton = new Button();
        private NoAddonChoice noAddonChoice;
        private ThemePalette palette;
        private AddonDescriptor previewAddon;
        private int previewIndex = 1;
        private int lastClickedAddonIndex = -1;
        private bool updatingAddonSelection;

        internal MainForm(string baseDirectory)
        {
            this.baseDirectory = baseDirectory;
            options = LauncherOptions.Load(baseDirectory);
            catalog = PoCatalog.Load(baseDirectory, options.InterfaceLanguage);
            palette = ThemePalette.For(options.Theme);

            Text = "Blade of Agony";
            StartPosition = FormStartPosition.CenterScreen;
            Font = new Font("Segoe UI", 9.0f);
            MinimumSize = new Size(940, 690);
            Size = new Size(1080, 790);
            Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);

            Controls.Add(CreateRootLayout());
            LoadSettingsIntoControls();
            ApplyTheme(this);
            interfaceLanguageCombo.SelectedIndexChanged += delegate { ChangeInterfaceLanguage(); };
            themeCombo.SelectedIndexChanged += delegate { ChangeTheme(); };
            FormClosing += delegate { SaveSettingsFromControls(); };
        }

        protected override void OnHandleCreated(EventArgs eventArgs)
        {
            base.OnHandleCreated(eventArgs);
            ApplyTitleBarTheme();
        }

        private Control CreateRootLayout()
        {
            TableLayoutPanel root = new TableLayoutPanel();
            root.Dock = DockStyle.Fill;
            root.ColumnCount = 1;
            root.RowCount = 3;
            root.RowStyles.Add(new RowStyle(SizeType.Absolute, 196));
            root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            root.RowStyles.Add(new RowStyle(SizeType.Absolute, 58));

            root.Controls.Add(CreateHeader(), 0, 0);

            TableLayoutPanel content = new TableLayoutPanel();
            content.Dock = DockStyle.Fill;
            content.ColumnCount = 2;
            content.RowCount = 1;
            content.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 350));
            content.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));

            Panel settingsHost = new Panel();
            settingsHost.Dock = DockStyle.Fill;
            settingsHost.Padding = new Padding(18, 14, 14, 12);
            settingsHost.Controls.Add(CreateSettingsPanel());

            Panel addonHost = new Panel();
            addonHost.Dock = DockStyle.Fill;
            addonHost.Padding = new Padding(14, 14, 18, 12);
            addonHost.Controls.Add(CreateAddonPanel());

            content.Controls.Add(settingsHost, 0, 0);
            content.Controls.Add(addonHost, 1, 0);
            root.Controls.Add(content, 0, 1);

            root.Controls.Add(CreateActionBar(), 0, 2);
            return root;
        }

        private Control CreateHeader()
        {
            TableLayoutPanel header = new TableLayoutPanel();
            header.Dock = DockStyle.Fill;
            header.ColumnCount = 1;
            header.RowCount = 2;
            header.RowStyles.Add(new RowStyle(SizeType.Absolute, 46));
            header.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            TableLayoutPanel toolbar = new TableLayoutPanel();
            toolbar.Dock = DockStyle.Fill;
            toolbar.Padding = new Padding(18, 8, 18, 8);
            toolbar.ColumnCount = 5;
            toolbar.RowCount = 1;
            toolbar.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            toolbar.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 145));
            toolbar.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 170));
            toolbar.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 100));
            toolbar.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 155));

            Label title = new Label();
            title.Text = "Blade of Agony Launcher";
            title.Dock = DockStyle.Fill;
            title.Font = new Font(Font.FontFamily, 10.0f, FontStyle.Bold);
            title.TextAlign = ContentAlignment.MiddleLeft;

            Label interfaceLanguageLabel = new Label();
            SetLocalizedText(interfaceLanguageLabel, "Interface language:");
            interfaceLanguageLabel.Dock = DockStyle.Fill;
            interfaceLanguageLabel.TextAlign = ContentAlignment.MiddleRight;
            interfaceLanguageLabel.Margin = new Padding(6, 0, 8, 0);

            PopulateLanguageChoices(interfaceLanguageCombo);
            interfaceLanguageCombo.Dock = DockStyle.Fill;
            interfaceLanguageCombo.Margin = new Padding(0);

            Label designLabel = new Label();
            SetLocalizedText(designLabel, "Design:");
            designLabel.Dock = DockStyle.Fill;
            designLabel.TextAlign = ContentAlignment.MiddleRight;
            designLabel.Margin = new Padding(8, 0, 8, 0);

            themeCombo.Dock = DockStyle.Fill;
            themeCombo.Margin = new Padding(0);

            toolbar.Controls.Add(title, 0, 0);
            toolbar.Controls.Add(interfaceLanguageLabel, 1, 0);
            toolbar.Controls.Add(interfaceLanguageCombo, 2, 0);
            toolbar.Controls.Add(designLabel, 3, 0);
            toolbar.Controls.Add(themeCombo, 4, 0);

            PictureBox banner = new PictureBox();
            banner.Dock = DockStyle.Fill;
            banner.SizeMode = PictureBoxSizeMode.StretchImage;
            banner.Image = LoadEmbeddedImage("BladeLauncher.launcher.jpg");
            header.Controls.Add(toolbar, 0, 0);
            header.Controls.Add(banner, 0, 1);
            return header;
        }

        private Control CreateSettingsPanel()
        {
            TableLayoutPanel panel = new TableLayoutPanel();
            panel.Dock = DockStyle.Fill;
            panel.ColumnCount = 2;
            panel.RowCount = 8;
            panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 46));
            panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 54));
            for (int row = 0; row < 7; row++) {
                panel.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            }
            panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            PopulateLanguageChoices(languageCombo);

            SetLocalizedText(commentaryCheck, "Developer commentary");
            commentaryCheck.AutoSize = true;
            commentaryCheck.Margin = new Padding(0, 5, 0, 8);

            Label graphics = CreateSectionHeader("Graphics");
            panel.Controls.Add(graphics, 0, 0);
            panel.SetColumnSpan(graphics, 2);
            AddSettingRow(panel, 1, "Detail preset:", detailCombo);
            AddSettingRow(panel, 2, "Displacement textures:", displacementCombo);

            Label game = CreateSectionHeader("Game");
            panel.Controls.Add(game, 0, 3);
            panel.SetColumnSpan(game, 2);
            AddSettingRow(panel, 4, "Game language:", languageCombo);
            panel.Controls.Add(commentaryCheck, 0, 5);
            panel.SetColumnSpan(commentaryCheck, 2);

            Control multiplayer = CreateMultiplayerPanel();
            panel.Controls.Add(multiplayer, 0, 6);
            panel.SetColumnSpan(multiplayer, 2);
            RefreshChoiceText();
            return panel;
        }

        private static void PopulateLanguageChoices(ThemedComboBox combo)
        {
            combo.Items.AddRange(new object[] {
                new LanguageChoice("en", "English (default)"),
                new LanguageChoice("de", "Deutsch"),
                new LanguageChoice("es", "Espa\u00f1ol"),
                new LanguageChoice("ru", "\u0420\u0443\u0441\u0441\u043a\u0438\u0439"),
                new LanguageChoice("ptb", "Portugu\u00eas (Brasil)"),
                new LanguageChoice("it", "Italiano"),
                new LanguageChoice("tr", "T\u00fcrk\u00e7e"),
                new LanguageChoice("fr", "Fran\u00e7ais"),
                new LanguageChoice("cs", "\u010ce\u0161tina"),
                new LanguageChoice("pl", "Polski")
            });
        }

        private Label CreateSectionHeader(string key)
        {
            Label label = new Label();
            SetLocalizedText(label, key);
            label.AutoSize = true;
            label.Font = new Font(Font.FontFamily, 9.5f, FontStyle.Bold);
            label.Margin = new Padding(0, 5, 0, 7);
            return label;
        }

        private Control CreateMultiplayerPanel()
        {
            ThemedGroupBox group = new ThemedGroupBox();
            SetLocalizedText(group, "Multiplayer");
            group.Dock = DockStyle.Top;
            group.AutoSize = true;
            group.AutoSizeMode = AutoSizeMode.GrowAndShrink;
            group.Padding = new Padding(10, 16, 10, 8);

            multiplayerSettingsPanel.Dock = DockStyle.Top;
            multiplayerSettingsPanel.AutoSize = true;
            multiplayerSettingsPanel.ColumnCount = 2;
            multiplayerSettingsPanel.RowCount = 8;
            multiplayerSettingsPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 48));
            multiplayerSettingsPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 52));
            for (int row = 0; row < 8; row++) {
                multiplayerSettingsPanel.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            }

            multiplayerModeControl.Dock = DockStyle.Top;
            multiplayerModeControl.Margin = new Padding(0, 2, 0, 6);
            multiplayerModeControl.Text = "MultiplayerMode";
            multiplayerModeControl.SelectedIndexChanged += delegate {
                UpdateMultiplayerControls();
            };

            multiplayerPlayers.Minimum = 2;
            multiplayerPlayers.Maximum = 8;
            multiplayerPlayers.Dock = DockStyle.Fill;
            multiplayerStartMap.CharacterCasing = CharacterCasing.Upper;
            multiplayerStartMap.MaxLength = 16;
            multiplayerStartMap.Dock = DockStyle.Fill;
            multiplayerHost.MaxLength = 255;
            multiplayerHost.Dock = DockStyle.Fill;
            multiplayerHost.TextChanged += delegate { UpdateMultiplayerValidation(); };
            multiplayerStartMap.TextChanged += delegate { UpdateMultiplayerValidation(); };
            multiplayerPort.Minimum = 1;
            multiplayerPort.Maximum = 65535;
            multiplayerPort.Dock = DockStyle.Fill;
            multiplayerSkill.Minimum = 1;
            multiplayerSkill.Maximum = 5;
            multiplayerSkill.Dock = DockStyle.Fill;
            SetLocalizedText(multiplayerCheats, "Allow cheats");
            multiplayerCheats.AutoSize = true;
            multiplayerCheats.Margin = new Padding(3, 3, 3, 2);

            multiplayerSettingsPanel.Controls.Add(multiplayerModeControl, 0, 0);
            multiplayerSettingsPanel.SetColumnSpan(multiplayerModeControl, 2);
            AddSettingRow(
                multiplayerSettingsPanel, 1, "Players (including host):",
                multiplayerPlayers, multiplayerPlayersLabel);
            AddSettingRow(
                multiplayerSettingsPanel, 2, "Start map:",
                multiplayerStartMap, multiplayerStartMapLabel);
            AddSettingRow(
                multiplayerSettingsPanel, 3, "Host / IP:",
                multiplayerHost, multiplayerHostLabel);
            AddSettingRow(
                multiplayerSettingsPanel, 4, "UDP port:",
                multiplayerPort, multiplayerPortLabel);
            AddSettingRow(
                multiplayerSettingsPanel, 5, "Skill:",
                multiplayerSkill, multiplayerSkillLabel);
            multiplayerSettingsPanel.Controls.Add(multiplayerCheats, 1, 6);
            multiplayerValidation.AutoSize = true;
            multiplayerValidation.Margin = new Padding(0, 5, 0, 2);
            multiplayerSettingsPanel.Controls.Add(multiplayerValidation, 0, 7);
            multiplayerSettingsPanel.SetColumnSpan(multiplayerValidation, 2);
            group.Controls.Add(multiplayerSettingsPanel);
            return group;
        }

        private void AddSettingRow(TableLayoutPanel panel, int row, string key, Control value)
        {
            AddSettingRow(panel, row, key, value, new Label());
        }

        private void AddSettingRow(
            TableLayoutPanel panel, int row, string key, Control value, Label label)
        {
            SetLocalizedText(label, key);
            label.AutoSize = true;
            label.Margin = new Padding(0, 3, 5, 2);
            label.AutoEllipsis = true;
            panel.Controls.Add(label, 0, row);
            value.Margin = new Padding(0, 2, 0, 2);
            panel.Controls.Add(value, 1, row);
        }

        private Control CreateAddonPanel()
        {
            TableLayoutPanel panel = new TableLayoutPanel();
            panel.Dock = DockStyle.Fill;
            panel.ColumnCount = 2;
            panel.RowCount = 4;
            panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 42));
            panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 58));
            panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 31));
            panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
            panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));

            Label heading = new Label();
            SetLocalizedText(heading, "Launch with:");
            heading.Dock = DockStyle.Fill;
            heading.Font = new Font(Font, FontStyle.Bold);
            heading.TextAlign = ContentAlignment.MiddleLeft;
            panel.Controls.Add(heading, 0, 0);

            SetLocalizedText(addonStatus, "No addon selected.");
            addonStatus.Dock = DockStyle.Fill;
            addonStatus.TextAlign = ContentAlignment.MiddleLeft;
            panel.Controls.Add(addonStatus, 1, 0);

            FlowLayoutPanel tools = new FlowLayoutPanel();
            tools.Dock = DockStyle.Fill;
            tools.FlowDirection = FlowDirection.LeftToRight;
            Button scan = new Button();
            SetLocalizedText(scan, "Scan for addons");
            scan.AutoSize = true;
            scan.Click += delegate { ScanAddons(); };
            tools.Controls.Add(scan);
            panel.Controls.Add(tools, 0, 1);
            panel.SetColumnSpan(tools, 2);

            addonList.Dock = DockStyle.Fill;
            addonList.IntegralHeight = false;
            addonList.BorderStyle = BorderStyle.None;
            addonList.SelectionMode = SelectionMode.MultiExtended;
            addonList.DrawMode = DrawMode.OwnerDrawFixed;
            addonList.ItemHeight = Math.Max(Font.Height + 6, 22);
            addonList.DrawItem += DrawAddonItem;
            addonList.MouseDown += delegate(object sender, MouseEventArgs eventArgs) {
                lastClickedAddonIndex = addonList.IndexFromPoint(eventArgs.Location);
            };
            addonList.SelectedIndexChanged += delegate { SynchronizeAddonSelection(); };
            addonListFrame.Dock = DockStyle.Fill;
            addonListFrame.Controls.Add(addonList);
            panel.Controls.Add(addonListFrame, 0, 2);

            TableLayoutPanel details = new TableLayoutPanel();
            details.Dock = DockStyle.Fill;
            details.ColumnCount = 1;
            details.RowCount = 4;
            details.RowStyles.Add(new RowStyle(SizeType.Absolute, 28));
            details.RowStyles.Add(new RowStyle(SizeType.Absolute, 24));
            details.RowStyles.Add(new RowStyle(SizeType.Percent, 55));
            details.RowStyles.Add(new RowStyle(SizeType.Absolute, 180));

            addonTitle.Dock = DockStyle.Fill;
            addonTitle.Font = new Font(Font.FontFamily, 11, FontStyle.Bold);
            addonTitle.TextAlign = ContentAlignment.MiddleLeft;
            details.Controls.Add(addonTitle);
            addonCredits.Dock = DockStyle.Fill;
            addonCredits.ForeColor = SystemColors.GrayText;
            details.Controls.Add(addonCredits);

            addonDescription.Dock = DockStyle.Fill;
            addonDescription.Multiline = true;
            addonDescription.ReadOnly = true;
            addonDescription.BorderStyle = BorderStyle.None;
            addonDescription.BackColor = SystemColors.Control;
            addonDescription.ScrollBars = ScrollBars.None;
            details.Controls.Add(addonDescription);

            previewBox.Dock = DockStyle.Fill;
            previewBox.Margin = new Padding(0);
            previewBox.Text = "AddonPreviewViewport";
            details.Controls.Add(previewBox);
            details.SizeChanged += delegate { ResizePreviewRow(details); };
            details.Layout += delegate { ResizePreviewRow(details); };
            panel.Controls.Add(details, 1, 2);

            FlowLayoutPanel previewTools = new FlowLayoutPanel();
            previewTools.Dock = DockStyle.Fill;
            previewTools.FlowDirection = FlowDirection.RightToLeft;
            Button next = new ChevronButton(1);
            next.Size = new Size(34, 26);
            next.Click += delegate { ChangePreview(1); };
            Button previous = new ChevronButton(-1);
            previous.Size = new Size(34, 26);
            previous.Click += delegate { ChangePreview(-1); };
            previewCounter.AutoSize = true;
            previewCounter.Padding = new Padding(4, 5, 4, 0);
            previewTools.Controls.Add(next);
            previewTools.Controls.Add(previous);
            previewTools.Controls.Add(previewCounter);
            panel.Controls.Add(previewTools, 1, 3);
            return panel;
        }

        private static void ResizePreviewRow(TableLayoutPanel details)
        {
            if (details.ClientSize.Width < 1 || details.RowStyles.Count < 4) {
                return;
            }
            int desiredHeight = PreviewLayout.HeightFor16By9Width(details.ClientSize.Width);
            RowStyle previewRow = details.RowStyles[3];
            if (Math.Abs(previewRow.Height - desiredHeight) > 0.5f) {
                previewRow.SizeType = SizeType.Absolute;
                previewRow.Height = desiredHeight;
            }
        }

        private Control CreateActionBar()
        {
            TableLayoutPanel bar = new TableLayoutPanel();
            bar.Dock = DockStyle.Fill;
            bar.Padding = new Padding(18, 10, 18, 10);
            bar.ColumnCount = 3;
            bar.RowCount = 1;
            bar.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            bar.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 142));
            bar.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 120));

            Button exit = new Button();
            SetLocalizedText(exit, "Exit");
            exit.Dock = DockStyle.Fill;
            exit.Margin = new Padding(8, 0, 0, 0);
            exit.Click += delegate { Close(); };

            SetLocalizedText(playButton, "Play");
            playButton.Dock = DockStyle.Fill;
            playButton.Margin = new Padding(0);
            playButton.Font = new Font(Font, FontStyle.Bold);
            playButton.Click += delegate { LaunchGame(); };

            bar.Controls.Add(playButton, 1, 0);
            bar.Controls.Add(exit, 2, 0);
            return bar;
        }

        private void LoadSettingsIntoControls()
        {
            detailCombo.SelectedIndex = 0;
            displacementCombo.SelectedIndex = options.DisplacementTextures ? 1 : 0;
            SelectLanguage(languageCombo, options.Language);
            SelectLanguage(interfaceLanguageCombo, options.InterfaceLanguage);
            commentaryCheck.Checked = options.DeveloperCommentary;
            SelectTheme(options.Theme);
            multiplayerModeControl.SelectedIndex = (int)options.NetworkMode;
            multiplayerPlayers.Value = Math.Max(
                multiplayerPlayers.Minimum, Math.Min(multiplayerPlayers.Maximum, options.MultiplayerPlayers));
            multiplayerStartMap.Text = LauncherOptions.NormalizeMapName(options.MultiplayerStartMap);
            multiplayerHost.Text = LauncherOptions.NormalizeHost(options.MultiplayerHost);
            multiplayerPort.Value = Math.Max(
                multiplayerPort.Minimum, Math.Min(multiplayerPort.Maximum, options.MultiplayerPort));
            multiplayerSkill.Value = Math.Max(
                multiplayerSkill.Minimum, Math.Min(multiplayerSkill.Maximum, options.MultiplayerSkill));
            multiplayerCheats.Checked = options.MultiplayerCheats;
            UpdateMultiplayerControls();
            ScanAddons();
        }

        private void SaveSettingsFromControls()
        {
            options.DetailPreset = detailCombo.SelectedIndex;
            options.DisplacementTextures = displacementCombo.SelectedIndex == 1;
            options.DeveloperCommentary = commentaryCheck.Checked;
            LanguageChoice language = languageCombo.SelectedItem as LanguageChoice;
            options.Language = LauncherOptions.NormalizeLanguage(language == null ? "en" : language.Code);
            LanguageChoice interfaceLanguage =
                interfaceLanguageCombo.SelectedItem as LanguageChoice;
            options.InterfaceLanguage = LauncherOptions.NormalizeLanguage(
                interfaceLanguage == null ? "en" : interfaceLanguage.Code);
            options.Theme = themeCombo.SelectedIndex >= 0
                ? (LauncherTheme)themeCombo.SelectedIndex
                : LauncherTheme.Dark;
            options.NetworkMode = multiplayerModeControl.SelectedIndex >= 0
                ? (MultiplayerMode)multiplayerModeControl.SelectedIndex
                : MultiplayerMode.SinglePlayer;
            options.MultiplayerPlayers = Decimal.ToInt32(multiplayerPlayers.Value);
            options.MultiplayerStartMap = LauncherOptions.NormalizeMapName(multiplayerStartMap.Text);
            options.MultiplayerHost = LauncherOptions.NormalizeHost(multiplayerHost.Text);
            options.MultiplayerPort = Decimal.ToInt32(multiplayerPort.Value);
            options.MultiplayerSkill = Decimal.ToInt32(multiplayerSkill.Value);
            options.MultiplayerCheats = multiplayerCheats.Checked;
            options.Save();
        }

        private void ChangeInterfaceLanguage()
        {
            LanguageChoice language = interfaceLanguageCombo.SelectedItem as LanguageChoice;
            if (language == null) {
                return;
            }
            options.InterfaceLanguage = LauncherOptions.NormalizeLanguage(language.Code);
            catalog = PoCatalog.Load(baseDirectory, options.InterfaceLanguage);
            ApplyLocalization(this);
            RefreshChoiceText();
            ScanAddons();
        }

        private void ChangeTheme()
        {
            if (themeCombo.SelectedIndex < 0) {
                return;
            }
            options.Theme = (LauncherTheme)themeCombo.SelectedIndex;
            palette = ThemePalette.For(options.Theme);
            ApplyTheme(this);
        }

        private void RefreshChoiceText()
        {
            int detail = detailCombo.SelectedIndex;
            detailCombo.BeginUpdate();
            detailCombo.Items.Clear();
            detailCombo.Items.AddRange(new object[] {
                catalog.Get("Use last settings"),
                catalog.Get("Reset to default settings"),
                catalog.Get("Very low detail (fastest)"),
                catalog.Get("Low detail (faster)"),
                catalog.Get("Normal detail"),
                catalog.Get("High detail (prettier)"),
                catalog.Get("Very high detail (beautiful)")
            });
            detailCombo.SelectedIndex = detail >= 0 ? detail : 0;
            detailCombo.EndUpdate();

            int displacement = displacementCombo.SelectedIndex;
            displacementCombo.BeginUpdate();
            displacementCombo.Items.Clear();
            displacementCombo.Items.AddRange(new object[] {
                catalog.Get("Disable (faster)"),
                catalog.Get("Enable (beautiful)")
            });
            displacementCombo.SelectedIndex = displacement >= 0 ? displacement : 1;
            displacementCombo.EndUpdate();

            int multiplayer = multiplayerModeControl.SelectedIndex;
            multiplayerModeControl.SetItems(
                catalog.Get("Single player"),
                catalog.Get("Host co-op"),
                catalog.Get("Join co-op"));
            multiplayerModeControl.AccessibleName = catalog.Get("Multiplayer");
            multiplayerModeControl.SelectedIndex = multiplayer >= 0 ? multiplayer : 0;

            int theme = themeCombo.SelectedIndex;
            themeCombo.BeginUpdate();
            themeCombo.Items.Clear();
            themeCombo.Items.AddRange(new object[] {
                catalog.Get("Dark"),
                catalog.Get("Light"),
                "Blade of Agony"
            });
            themeCombo.SelectedIndex = theme >= 0 ? theme : (int)LauncherTheme.Dark;
            themeCombo.EndUpdate();
            UpdateMultiplayerControls();
        }

        private void SelectTheme(LauncherTheme theme)
        {
            int index = (int)theme;
            themeCombo.SelectedIndex = index >= 0 && index < themeCombo.Items.Count
                ? index
                : (int)LauncherTheme.Dark;
        }

        private void UpdateMultiplayerControls()
        {
            bool hosting = multiplayerModeControl.SelectedIndex == (int)MultiplayerMode.Host;
            bool joining = multiplayerModeControl.SelectedIndex == (int)MultiplayerMode.Join;

            SetMultiplayerRowVisible(1, hosting);
            SetMultiplayerRowVisible(2, hosting);
            SetMultiplayerRowVisible(3, joining);
            SetMultiplayerRowVisible(4, hosting || joining);
            SetMultiplayerRowVisible(5, hosting);
            SetMultiplayerRowVisible(6, hosting);
            UpdateMultiplayerValidation();
            multiplayerSettingsPanel.PerformLayout();
        }

        private void SetMultiplayerRowVisible(int row, bool visible)
        {
            for (int column = 0; column < multiplayerSettingsPanel.ColumnCount; column++) {
                Control control = multiplayerSettingsPanel.GetControlFromPosition(column, row);
                if (control != null) {
                    control.Visible = visible;
                }
            }
            RowStyle style = multiplayerSettingsPanel.RowStyles[row];
            style.SizeType = visible ? SizeType.AutoSize : SizeType.Absolute;
            style.Height = 0;
        }

        private void UpdateMultiplayerValidation()
        {
            bool hosting = multiplayerModeControl.SelectedIndex == (int)MultiplayerMode.Host;
            bool joining = multiplayerModeControl.SelectedIndex == (int)MultiplayerMode.Join;
            string error = string.Empty;

            if (hosting && !LauncherOptions.IsValidMapName(multiplayerStartMap.Text)) {
                error = catalog.Get("Enter a valid start map.");
            } else if (joining && !LauncherOptions.IsValidHost(multiplayerHost.Text)) {
                error = catalog.Get("Enter a valid host name or IPv4 address.");
            }

            multiplayerStartMap.BorderColor =
                hosting && !LauncherOptions.IsValidMapName(multiplayerStartMap.Text)
                    ? palette.Error
                    : palette.Border;
            multiplayerHost.BorderColor =
                joining && !LauncherOptions.IsValidHost(multiplayerHost.Text)
                    ? palette.Error
                    : palette.Border;
            multiplayerStartMap.Invalidate();
            multiplayerHost.Invalidate();

            multiplayerValidation.Text = error;
            multiplayerValidation.ForeColor = palette.Error;
            bool showError = error.Length > 0;
            multiplayerValidation.Visible = showError;
            RowStyle validationStyle = multiplayerSettingsPanel.RowStyles[7];
            validationStyle.SizeType = showError ? SizeType.AutoSize : SizeType.Absolute;
            validationStyle.Height = 0;
            playButton.Enabled = !showError;
        }

        private void ApplyLocalization(Control parent)
        {
            string key = parent.Tag as string;
            if (key != null) {
                parent.Text = catalog.Get(key);
            }
            foreach (Control child in parent.Controls) {
                ApplyLocalization(child);
            }
        }

        private void ApplyTheme(Control parent)
        {
            Color background = palette.Background;
            Color foreground = palette.Text;

            if (parent is TextBox || parent is ComboBox || parent is ListBox ||
                parent is NumericUpDown || parent is ThemedNumericUpDown) {
                background = palette.Input;
            } else if (parent is ThemedSegmentedControl) {
                background = palette.Background;
            } else if (parent is ThemedBorderPanel) {
                background = palette.Input;
            } else if (parent is Button) {
                background = object.ReferenceEquals(parent, playButton)
                    ? palette.Accent
                    : palette.Surface;
                foreground = object.ReferenceEquals(parent, playButton)
                    ? palette.AccentText
                    : palette.Text;
            } else if (parent is PictureBox) {
                background = Color.Black;
            }
            if (object.ReferenceEquals(parent, addonDescription)) {
                background = palette.Background;
            }
            if (object.ReferenceEquals(parent, previewBox)) {
                background = Color.Black;
            }
            if (object.ReferenceEquals(parent, addonCredits)) {
                foreground = palette.MutedText;
            }

            parent.BackColor = background;
            parent.ForeColor = foreground;

            Button button = parent as Button;
            if (button != null) {
                button.UseVisualStyleBackColor = false;
                button.FlatStyle = FlatStyle.Flat;
                button.FlatAppearance.BorderColor = palette.Border;
                button.FlatAppearance.MouseOverBackColor = palette.Accent;
                button.FlatAppearance.MouseDownBackColor = palette.Input;
            }
            CheckBox checkBox = parent as CheckBox;
            if (checkBox != null) {
                checkBox.UseVisualStyleBackColor = false;
            }
            ComboBox comboBox = parent as ComboBox;
            if (comboBox != null) {
                comboBox.FlatStyle = FlatStyle.Flat;
            }
            ThemedComboBox themedCombo = parent as ThemedComboBox;
            if (themedCombo != null) {
                themedCombo.BorderColor = palette.Border;
                themedCombo.SurfaceColor = palette.Surface;
                themedCombo.AccentColor = palette.Accent;
                themedCombo.AccentTextColor = palette.AccentText;
                themedCombo.MutedTextColor = palette.MutedText;
                themedCombo.Invalidate();
            }
            ThemedSegmentedControl segmented = parent as ThemedSegmentedControl;
            if (segmented != null) {
                segmented.BorderColor = palette.Border;
                segmented.SurfaceColor = palette.Surface;
                segmented.AccentColor = palette.Accent;
                segmented.AccentTextColor = palette.AccentText;
                segmented.MutedTextColor = palette.MutedText;
                segmented.Invalidate();
            }
            ThemedTextBox themedText = parent as ThemedTextBox;
            if (themedText != null) {
                themedText.BorderColor = palette.Border;
                themedText.Invalidate();
            }
            ThemedNumericUpDown themedNumber = parent as ThemedNumericUpDown;
            if (themedNumber != null) {
                themedNumber.BorderColor = palette.Border;
                themedNumber.SurfaceColor = palette.Surface;
                themedNumber.MutedTextColor = palette.MutedText;
                themedNumber.Invalidate();
            }
            ThemedGroupBox themedGroup = parent as ThemedGroupBox;
            if (themedGroup != null) {
                themedGroup.BorderColor = palette.Border;
                themedGroup.Invalidate();
            }
            ThemedBorderPanel themedBorder = parent as ThemedBorderPanel;
            if (themedBorder != null) {
                themedBorder.BorderColor = palette.Border;
                themedBorder.Invalidate();
            }
            ThemedCheckBox themedCheck = parent as ThemedCheckBox;
            if (themedCheck != null) {
                themedCheck.BorderColor = palette.Border;
                themedCheck.InputColor = palette.Input;
                themedCheck.AccentColor = palette.Accent;
                themedCheck.AccentTextColor = palette.AccentText;
                themedCheck.MutedTextColor = palette.MutedText;
                themedCheck.Invalidate();
            }

            foreach (Control child in parent.Controls) {
                ApplyTheme(child);
            }
            if (object.ReferenceEquals(parent, this)) {
                addonList.Invalidate();
                UpdateMultiplayerValidation();
                ApplyTitleBarTheme();
            }
        }

        private void ApplyTitleBarTheme()
        {
            if (!IsHandleCreated || palette == null) {
                return;
            }
            int enabled = palette.DarkTitleBar ? 1 : 0;
            try {
                int result = DwmSetWindowAttribute(Handle, 20, ref enabled, sizeof(int));
                if (result != 0) {
                    DwmSetWindowAttribute(Handle, 19, ref enabled, sizeof(int));
                }
            } catch (DllNotFoundException) {
                // Older Windows versions do not provide DWM theme attributes.
            } catch (EntryPointNotFoundException) {
                // Keep the standard title bar when the API is unavailable.
            }
        }

        private static void SelectLanguage(ThemedComboBox combo, string code)
        {
            string normalized = LauncherOptions.NormalizeLanguage(code);
            for (int index = 0; index < combo.Items.Count; index++) {
                LanguageChoice choice = combo.Items[index] as LanguageChoice;
                if (choice != null && string.Equals(choice.Code, normalized, StringComparison.OrdinalIgnoreCase)) {
                    combo.SelectedIndex = index;
                    return;
                }
            }
            combo.SelectedIndex = 0;
        }

        private void ScanAddons()
        {
            HashSet<string> selectedPaths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            if (options.UseAddon) {
                if (options.MultiAddons.Count > 0) {
                    foreach (AddonDescriptor addon in options.MultiAddons) {
                        selectedPaths.Add(addon.DescriptorPath);
                    }
                } else if (options.SingleAddon != null) {
                    selectedPaths.Add(options.SingleAddon.DescriptorPath);
                }
            }

            addons.Clear();
            addons.AddRange(AddonDescriptor.Scan(baseDirectory, options.InterfaceLanguage));
            updatingAddonSelection = true;
            addonList.BeginUpdate();
            addonList.Items.Clear();
            noAddonChoice = new NoAddonChoice(catalog.Get("No addons"));
            addonList.Items.Add(noAddonChoice);
            foreach (AddonDescriptor addon in addons) {
                addonList.Items.Add(addon);
                if (selectedPaths.Contains(addon.DescriptorPath)) {
                    addonList.SetSelected(addonList.Items.Count - 1, true);
                }
            }
            if (addonList.SelectedIndices.Count == 0) {
                addonList.SetSelected(0, true);
            }
            addonList.EndUpdate();
            updatingAddonSelection = false;
            lastClickedAddonIndex = -1;
            SynchronizeAddonSelection();
        }

        private void SynchronizeAddonSelection()
        {
            if (updatingAddonSelection || addonList.Items.Count == 0) {
                return;
            }

            updatingAddonSelection = true;
            bool noAddonsSelected = addonList.GetSelected(0);
            if (noAddonsSelected && lastClickedAddonIndex == 0) {
                for (int index = 1; index < addonList.Items.Count; index++) {
                    addonList.SetSelected(index, false);
                }
            } else if (noAddonsSelected && addonList.SelectedIndices.Count > 1) {
                addonList.SetSelected(0, false);
            }
            if (addonList.SelectedIndices.Count == 0) {
                addonList.SetSelected(0, true);
            }

            List<AddonDescriptor> selectedAddons = new List<AddonDescriptor>();
            foreach (object item in addonList.SelectedItems) {
                AddonDescriptor addon = item as AddonDescriptor;
                if (addon != null) {
                    selectedAddons.Add(addon);
                }
            }

            options.UseAddon = selectedAddons.Count > 0;
            if (selectedAddons.Count == 1) {
                options.SingleAddon = selectedAddons[0];
                options.MultiAddons.Clear();
            } else if (selectedAddons.Count > 1) {
                options.SingleAddon = null;
                options.MultiAddons = selectedAddons;
            } else {
                options.SingleAddon = null;
                options.MultiAddons.Clear();
            }
            updatingAddonSelection = false;

            AddonDescriptor detailsAddon = null;
            if (lastClickedAddonIndex > 0 && lastClickedAddonIndex < addonList.Items.Count &&
                addonList.GetSelected(lastClickedAddonIndex)) {
                detailsAddon = addonList.Items[lastClickedAddonIndex] as AddonDescriptor;
            }
            if (detailsAddon == null && selectedAddons.Count > 0) {
                detailsAddon = selectedAddons[0];
            }
            if (detailsAddon == null) {
                previewAddon = null;
                ClearAddonDetails();
            } else {
                if (!object.ReferenceEquals(previewAddon, detailsAddon)) {
                    previewIndex = 1;
                }
                ShowAddon(detailsAddon);
            }
            addonList.Invalidate();
            UpdateAddonStatus();
        }

        private void DrawAddonItem(object sender, DrawItemEventArgs eventArgs)
        {
            if (eventArgs.Index < 0 || eventArgs.Index >= addonList.Items.Count) {
                return;
            }
            bool noAddonsMode = addonList.Items.Count > 0 && addonList.GetSelected(0);
            bool disabled = noAddonsMode && eventArgs.Index > 0;
            bool selected = !disabled && (eventArgs.State & DrawItemState.Selected) != 0;
            Color background = selected ? palette.Accent : addonList.BackColor;
            Color foreground = disabled
                ? palette.MutedText
                : (selected ? palette.AccentText : addonList.ForeColor);

            using (Brush backgroundBrush = new SolidBrush(background)) {
                eventArgs.Graphics.FillRectangle(backgroundBrush, eventArgs.Bounds);
            }
            TextRenderer.DrawText(
                eventArgs.Graphics,
                addonList.Items[eventArgs.Index].ToString(),
                addonList.Font,
                new Rectangle(
                    eventArgs.Bounds.Left + 4,
                    eventArgs.Bounds.Top,
                    Math.Max(0, eventArgs.Bounds.Width - 8),
                    eventArgs.Bounds.Height),
                foreground,
                TextFormatFlags.Left | TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis);
            if (selected) {
                eventArgs.DrawFocusRectangle();
            }
        }

        private void ShowAddon(AddonDescriptor addon)
        {
            previewAddon = addon;
            addonTitle.Text = addon.Title;
            addonCredits.Text = addon.Credits.Length == 0
                ? string.Empty
                : catalog.Get("by") + " " + addon.Credits;
            addonDescription.Text =
                catalog.Get("Description:") + Environment.NewLine + addon.Description + Environment.NewLine +
                Environment.NewLine + catalog.Get("Requirements:") + Environment.NewLine + addon.Requirements;
            ReplacePreviewImage(addon.LoadPreview(previewIndex));
            previewCounter.Text = addon.PreviewImageCount > 0
                ? previewIndex + " / " + addon.PreviewImageCount
                : string.Empty;
        }

        private void ChangePreview(int direction)
        {
            AddonDescriptor addon = previewAddon;
            if (addon == null || addon.PreviewImageCount < 1) {
                return;
            }
            previewIndex += direction;
            if (previewIndex < 1) {
                previewIndex = addon.PreviewImageCount;
            } else if (previewIndex > addon.PreviewImageCount) {
                previewIndex = 1;
            }
            ShowAddon(addon);
        }

        private void ClearAddonDetails()
        {
            previewAddon = null;
            addonTitle.Text = string.Empty;
            addonCredits.Text = string.Empty;
            addonDescription.Text = string.Empty;
            previewCounter.Text = string.Empty;
            ReplacePreviewImage(null);
        }

        private void UpdateAddonStatus()
        {
            if (!options.UseAddon) {
                addonStatus.Text = catalog.Get("No addons");
            } else if (options.MultiAddons.Count > 0) {
                string first = options.MultiAddons[0].Title;
                int extra = options.MultiAddons.Count - 1;
                addonStatus.Text = extra > 0
                    ? first + catalog.Get(", and %d more").Replace("%d", extra.ToString(CultureInfo.CurrentCulture))
                    : first;
            } else if (options.SingleAddon != null) {
                addonStatus.Text = options.SingleAddon.Title;
            } else {
                addonStatus.Text = catalog.Get("No addon selected.");
            }
        }

        private void LaunchGame()
        {
            try {
                SaveSettingsFromControls();
                LauncherCommand.Start(options);
                Close();
            } catch (Exception exception) {
                MessageBox.Show(this, exception.Message, "Blade of Agony", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void ReplacePreviewImage(Image next)
        {
            Image previous = previewBox.Image;
            previewBox.Image = next;
            if (previous != null) {
                previous.Dispose();
            }
        }

        private Label CreateSettingLabel(string key)
        {
            Label label = new Label();
            SetLocalizedText(label, key);
            label.AutoSize = true;
            label.Margin = new Padding(0, 0, 0, 3);
            return label;
        }

        private void SetLocalizedText(Control control, string key)
        {
            control.Tag = key;
            control.Text = catalog.Get(key);
        }

        private static Control CreateSpacer()
        {
            Panel spacer = new Panel();
            spacer.Height = 4;
            return spacer;
        }

        private static Image LoadEmbeddedImage(string resourceName)
        {
            using (Stream stream = Assembly.GetExecutingAssembly().GetManifestResourceStream(resourceName)) {
                if (stream == null) {
                    return null;
                }
                using (Image source = Image.FromStream(stream)) {
                    return new Bitmap(source);
                }
            }
        }
    }
}
