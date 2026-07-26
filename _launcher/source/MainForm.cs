using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Globalization;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

namespace BladeOfAgonyLauncher
{
    internal sealed class MainForm : Form
    {
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

        private sealed class AspectRatioHost : Panel
        {
            private readonly Control content;

            internal AspectRatioHost(Control content)
            {
                this.content = content;
                Controls.Add(content);
                BackColor = SystemColors.Control;
            }

            protected override void OnLayout(LayoutEventArgs eventArgs)
            {
                base.OnLayout(eventArgs);
                content.Bounds = PreviewLayout.Fit16By9(ClientSize);
            }
        }

        private readonly string baseDirectory;
        private readonly PoCatalog catalog;
        private readonly LauncherOptions options;
        private readonly List<AddonDescriptor> addons = new List<AddonDescriptor>();

        private readonly ComboBox detailCombo = new ComboBox();
        private readonly ComboBox displacementCombo = new ComboBox();
        private readonly ComboBox languageCombo = new ComboBox();
        private readonly CheckBox commentaryCheck = new CheckBox();
        private readonly ListBox addonList = new ListBox();
        private readonly Label addonStatus = new Label();
        private readonly Label addonTitle = new Label();
        private readonly Label addonCredits = new Label();
        private readonly TextBox addonDescription = new TextBox();
        private readonly CoverPictureBox previewBox = new CoverPictureBox();
        private readonly Label previewCounter = new Label();
        private NoAddonChoice noAddonChoice;
        private AddonDescriptor previewAddon;
        private int previewIndex = 1;
        private int lastClickedAddonIndex = -1;
        private bool updatingAddonSelection;

        internal MainForm(string baseDirectory)
        {
            this.baseDirectory = baseDirectory;
            catalog = PoCatalog.Load(baseDirectory, CultureInfo.CurrentUICulture);
            options = LauncherOptions.Load(baseDirectory);

            Text = "Blade of Agony";
            StartPosition = FormStartPosition.CenterScreen;
            MinimumSize = new Size(900, 600);
            Size = new Size(1040, 720);
            Icon = Icon.ExtractAssociatedIcon(Application.ExecutablePath);

            Controls.Add(CreateRootLayout());
            LoadSettingsIntoControls();
            FormClosing += delegate { SaveSettingsFromControls(); };
        }

        private Control CreateRootLayout()
        {
            TableLayoutPanel root = new TableLayoutPanel();
            root.Dock = DockStyle.Fill;
            root.ColumnCount = 1;
            root.RowCount = 3;
            root.RowStyles.Add(new RowStyle(SizeType.Absolute, 150));
            root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            root.RowStyles.Add(new RowStyle(SizeType.Absolute, 58));

            PictureBox banner = new PictureBox();
            banner.Dock = DockStyle.Fill;
            banner.SizeMode = PictureBoxSizeMode.StretchImage;
            banner.Image = LoadEmbeddedImage("BladeLauncher.launcher.jpg");
            root.Controls.Add(banner, 0, 0);

            TableLayoutPanel content = new TableLayoutPanel();
            content.Dock = DockStyle.Fill;
            content.ColumnCount = 2;
            content.RowCount = 1;
            content.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 320));
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

        private Control CreateSettingsPanel()
        {
            TableLayoutPanel panel = new TableLayoutPanel();
            panel.Dock = DockStyle.Fill;
            panel.ColumnCount = 1;
            panel.RowCount = 10;
            panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            for (int row = 0; row < 9; row++) {
                panel.RowStyles.Add(new RowStyle(SizeType.AutoSize));
            }
            panel.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

            detailCombo.DropDownStyle = ComboBoxStyle.DropDownList;
            detailCombo.Dock = DockStyle.Top;
            detailCombo.Items.AddRange(new object[] {
                catalog.Get("Use last settings"),
                catalog.Get("Reset to default settings"),
                catalog.Get("Very low detail (fastest)"),
                catalog.Get("Low detail (faster)"),
                catalog.Get("Normal detail"),
                catalog.Get("High detail (prettier)"),
                catalog.Get("Very high detail (beautiful)")
            });

            displacementCombo.DropDownStyle = ComboBoxStyle.DropDownList;
            displacementCombo.Dock = DockStyle.Top;
            displacementCombo.Items.AddRange(new object[] {
                catalog.Get("Disable (faster)"),
                catalog.Get("Enable (beautiful)")
            });

            languageCombo.DropDownStyle = ComboBoxStyle.DropDownList;
            languageCombo.Dock = DockStyle.Top;
            languageCombo.Items.AddRange(new object[] {
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

            commentaryCheck.Text = catalog.Get("Developer commentary");
            commentaryCheck.AutoSize = true;
            commentaryCheck.Margin = new Padding(0, 18, 0, 0);

            panel.Controls.Add(CreateSettingLabel(catalog.Get("Detail preset:")));
            panel.Controls.Add(detailCombo);
            panel.Controls.Add(CreateSpacer());
            panel.Controls.Add(CreateSettingLabel(catalog.Get("Displacement textures:")));
            panel.Controls.Add(displacementCombo);
            panel.Controls.Add(CreateSpacer());
            panel.Controls.Add(CreateSettingLabel(catalog.Get("Game language:")));
            panel.Controls.Add(languageCombo);
            panel.Controls.Add(commentaryCheck);
            return panel;
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
            heading.Text = catalog.Get("Launch with:");
            heading.Dock = DockStyle.Fill;
            heading.Font = new Font(Font, FontStyle.Bold);
            heading.TextAlign = ContentAlignment.MiddleLeft;
            panel.Controls.Add(heading, 0, 0);

            addonStatus.Text = catalog.Get("No addon selected.");
            addonStatus.Dock = DockStyle.Fill;
            addonStatus.TextAlign = ContentAlignment.MiddleLeft;
            panel.Controls.Add(addonStatus, 1, 0);

            FlowLayoutPanel tools = new FlowLayoutPanel();
            tools.Dock = DockStyle.Fill;
            tools.FlowDirection = FlowDirection.LeftToRight;
            Button scan = new Button();
            scan.Text = catalog.Get("Scan for addons");
            scan.AutoSize = true;
            scan.Click += delegate { ScanAddons(); };
            tools.Controls.Add(scan);
            panel.Controls.Add(tools, 0, 1);
            panel.SetColumnSpan(tools, 2);

            addonList.Dock = DockStyle.Fill;
            addonList.IntegralHeight = false;
            addonList.SelectionMode = SelectionMode.MultiExtended;
            addonList.DrawMode = DrawMode.OwnerDrawFixed;
            addonList.ItemHeight = Math.Max(Font.Height + 6, 22);
            addonList.DrawItem += DrawAddonItem;
            addonList.MouseDown += delegate(object sender, MouseEventArgs eventArgs) {
                lastClickedAddonIndex = addonList.IndexFromPoint(eventArgs.Location);
            };
            addonList.SelectedIndexChanged += delegate { SynchronizeAddonSelection(); };
            panel.Controls.Add(addonList, 0, 2);

            TableLayoutPanel details = new TableLayoutPanel();
            details.Dock = DockStyle.Fill;
            details.ColumnCount = 1;
            details.RowCount = 4;
            details.RowStyles.Add(new RowStyle(SizeType.Absolute, 28));
            details.RowStyles.Add(new RowStyle(SizeType.Absolute, 24));
            details.RowStyles.Add(new RowStyle(SizeType.Percent, 55));
            details.RowStyles.Add(new RowStyle(SizeType.Percent, 45));

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
            addonDescription.ScrollBars = ScrollBars.Vertical;
            details.Controls.Add(addonDescription);

            AspectRatioHost previewHost = new AspectRatioHost(previewBox);
            previewHost.Dock = DockStyle.Fill;
            details.Controls.Add(previewHost);
            panel.Controls.Add(details, 1, 2);

            FlowLayoutPanel previewTools = new FlowLayoutPanel();
            previewTools.Dock = DockStyle.Fill;
            previewTools.FlowDirection = FlowDirection.RightToLeft;
            Button next = new Button();
            next.Text = ">";
            next.Size = new Size(34, 26);
            next.Click += delegate { ChangePreview(1); };
            Button previous = new Button();
            previous.Text = "<";
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

        private Control CreateActionBar()
        {
            TableLayoutPanel bar = new TableLayoutPanel();
            bar.Dock = DockStyle.Fill;
            bar.Padding = new Padding(18, 10, 18, 10);
            bar.BorderStyle = BorderStyle.FixedSingle;
            bar.ColumnCount = 3;
            bar.RowCount = 1;
            bar.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100));
            bar.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 142));
            bar.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 120));

            Button exit = new Button();
            exit.Text = catalog.Get("Exit");
            exit.Dock = DockStyle.Fill;
            exit.Margin = new Padding(8, 0, 0, 0);
            exit.Click += delegate { Close(); };

            Button play = new Button();
            play.Text = catalog.Get("Play");
            play.Dock = DockStyle.Fill;
            play.Margin = new Padding(0);
            play.Font = new Font(Font, FontStyle.Bold);
            play.Click += delegate { LaunchGame(); };

            bar.Controls.Add(play, 1, 0);
            bar.Controls.Add(exit, 2, 0);
            return bar;
        }

        private void LoadSettingsIntoControls()
        {
            detailCombo.SelectedIndex = 0;
            displacementCombo.SelectedIndex = options.DisplacementTextures ? 1 : 0;
            SelectLanguage(options.Language);
            commentaryCheck.Checked = options.DeveloperCommentary;
            ScanAddons();
        }

        private void SaveSettingsFromControls()
        {
            options.DetailPreset = detailCombo.SelectedIndex;
            options.DisplacementTextures = displacementCombo.SelectedIndex == 1;
            options.DeveloperCommentary = commentaryCheck.Checked;
            LanguageChoice language = languageCombo.SelectedItem as LanguageChoice;
            options.Language = LauncherOptions.NormalizeLanguage(language == null ? "en" : language.Code);
            options.Save();
        }

        private void SelectLanguage(string code)
        {
            string normalized = LauncherOptions.NormalizeLanguage(code);
            for (int index = 0; index < languageCombo.Items.Count; index++) {
                LanguageChoice choice = languageCombo.Items[index] as LanguageChoice;
                if (choice != null && string.Equals(choice.Code, normalized, StringComparison.OrdinalIgnoreCase)) {
                    languageCombo.SelectedIndex = index;
                    return;
                }
            }
            languageCombo.SelectedIndex = 0;
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
            addons.AddRange(AddonDescriptor.Scan(baseDirectory, CultureInfo.CurrentUICulture));
            updatingAddonSelection = true;
            addonList.BeginUpdate();
            addonList.Items.Clear();
            noAddonChoice = new NoAddonChoice(GetNoAddonsLabel());
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
            Color background = selected ? SystemColors.Highlight : addonList.BackColor;
            Color foreground = disabled
                ? SystemColors.GrayText
                : (selected ? SystemColors.HighlightText : addonList.ForeColor);

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

        private static string GetNoAddonsLabel()
        {
            string language = CultureInfo.CurrentUICulture.TwoLetterISOLanguageName.ToLowerInvariant();
            if (language == "de") {
                return "Keine Addons";
            }
            if (language == "cs") {
                return "\u017d\u00e1dn\u00e9 dopl\u0148ky";
            }
            if (language == "pl") {
                return "Brak dodatk\u00f3w";
            }
            if (language == "ru") {
                return "\u0411\u0435\u0437 \u0434\u043e\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u0439";
            }
            return "No addons";
        }

        private void ShowAddon(AddonDescriptor addon)
        {
            previewAddon = addon;
            addonTitle.Text = addon.Title;
            addonCredits.Text = addon.Credits.Length == 0 ? string.Empty : "by " + addon.Credits;
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
                addonStatus.Text = GetNoAddonsLabel();
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

        private static Label CreateSettingLabel(string text)
        {
            Label label = new Label();
            label.Text = text;
            label.AutoSize = true;
            label.Margin = new Padding(0, 0, 0, 5);
            return label;
        }

        private static Control CreateSpacer()
        {
            Panel spacer = new Panel();
            spacer.Height = 18;
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
