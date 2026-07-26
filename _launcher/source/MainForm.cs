using System;
using System.Collections.Generic;
using System.Drawing;
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

        private readonly string baseDirectory;
        private readonly PoCatalog catalog;
        private readonly LauncherOptions options;
        private readonly List<AddonDescriptor> addons = new List<AddonDescriptor>();

        private readonly ComboBox detailCombo = new ComboBox();
        private readonly ComboBox displacementCombo = new ComboBox();
        private readonly ComboBox languageCombo = new ComboBox();
        private readonly CheckBox commentaryCheck = new CheckBox();
        private readonly CheckBox useAddonCheck = new CheckBox();
        private readonly ListBox addonList = new ListBox();
        private readonly Label addonStatus = new Label();
        private readonly Label addonTitle = new Label();
        private readonly Label addonCredits = new Label();
        private readonly TextBox addonDescription = new TextBox();
        private readonly PictureBox previewBox = new PictureBox();
        private readonly Label previewCounter = new Label();
        private int previewIndex = 1;

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
                new LanguageChoice(null, catalog.Get("Use last settings")),
                new LanguageChoice("auto", "Auto"),
                new LanguageChoice("cs", "Cesky"),
                new LanguageChoice("de", "Deutsch"),
                new LanguageChoice("default", "English (US)"),
                new LanguageChoice("en-GB", "English (UK)"),
                new LanguageChoice("es", "Espanol"),
                new LanguageChoice("fr", "Francais"),
                new LanguageChoice("it", "Italiano"),
                new LanguageChoice("pl", "Polski"),
                new LanguageChoice("ptg", "Portugues"),
                new LanguageChoice("ru", "Russkiy"),
                new LanguageChoice("tr", "Turkce")
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
            panel.RowCount = 5;
            panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 42));
            panel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 58));
            panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 31));
            panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 34));
            panel.RowStyles.Add(new RowStyle(SizeType.Absolute, 28));
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
            Button multi = new Button();
            multi.Text = catalog.Get("Select multiple addons");
            multi.AutoSize = true;
            multi.Click += delegate { SelectMultipleAddons(); };
            tools.Controls.Add(scan);
            tools.Controls.Add(multi);
            panel.Controls.Add(tools, 0, 1);
            panel.SetColumnSpan(tools, 2);

            addonList.Dock = DockStyle.Fill;
            addonList.IntegralHeight = false;
            addonList.SelectedIndexChanged += delegate { SelectSingleAddon(); };
            panel.Controls.Add(addonList, 0, 2);
            panel.SetRowSpan(addonList, 2);

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

            previewBox.Dock = DockStyle.Fill;
            previewBox.SizeMode = PictureBoxSizeMode.Zoom;
            previewBox.BackColor = Color.Black;
            details.Controls.Add(previewBox);
            panel.Controls.Add(details, 1, 2);
            panel.SetRowSpan(details, 2);

            useAddonCheck.Text = catalog.Get("Launch with:");
            useAddonCheck.AutoSize = true;
            useAddonCheck.CheckedChanged += delegate { UpdateAddonStatus(); };
            panel.Controls.Add(useAddonCheck, 0, 4);

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
            panel.Controls.Add(previewTools, 1, 4);
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
            languageCombo.SelectedIndex = 0;
            commentaryCheck.Checked = options.DeveloperCommentary;
            useAddonCheck.Checked = options.UseAddon;
            ScanAddons();
        }

        private void SaveSettingsFromControls()
        {
            options.DetailPreset = detailCombo.SelectedIndex;
            options.DisplacementTextures = displacementCombo.SelectedIndex == 1;
            options.DeveloperCommentary = commentaryCheck.Checked;
            LanguageChoice language = languageCombo.SelectedItem as LanguageChoice;
            options.Language = language == null ? null : language.Code;
            options.UseAddon = useAddonCheck.Checked;
            options.Save();
        }

        private void ScanAddons()
        {
            string selectedPath = options.SingleAddon == null ? null : options.SingleAddon.DescriptorPath;
            addons.Clear();
            addons.AddRange(AddonDescriptor.Scan(baseDirectory, CultureInfo.CurrentUICulture));
            addonList.BeginUpdate();
            addonList.Items.Clear();
            foreach (AddonDescriptor addon in addons) {
                addonList.Items.Add(addon);
                if (selectedPath != null &&
                    string.Equals(selectedPath, addon.DescriptorPath, StringComparison.OrdinalIgnoreCase)) {
                    addonList.SelectedItem = addon;
                }
            }
            addonList.EndUpdate();
            if (addonList.SelectedIndex < 0 && addons.Count > 0 && options.MultiAddons.Count == 0) {
                addonList.SelectedIndex = 0;
            }
            UpdateAddonStatus();
        }

        private void SelectSingleAddon()
        {
            AddonDescriptor selected = addonList.SelectedItem as AddonDescriptor;
            if (selected == null) {
                return;
            }
            options.SingleAddon = selected;
            options.MultiAddons.Clear();
            previewIndex = 1;
            ShowAddon(selected);
            UpdateAddonStatus();
        }

        private void SelectMultipleAddons()
        {
            if (addons.Count == 0) {
                ScanAddons();
            }
            List<AddonDescriptor> selected = new List<AddonDescriptor>();
            if (options.MultiAddons.Count > 0) {
                selected.AddRange(options.MultiAddons);
            } else if (options.SingleAddon != null) {
                selected.Add(options.SingleAddon);
            }

            using (MultiAddonForm dialog = new MultiAddonForm(addons, selected, catalog)) {
                if (dialog.ShowDialog(this) != DialogResult.OK) {
                    return;
                }
                options.MultiAddons = dialog.SelectedAddons;
                options.SingleAddon = null;
                addonList.ClearSelected();
                useAddonCheck.Checked = options.MultiAddons.Count > 0;
                ClearAddonDetails();
                UpdateAddonStatus();
            }
        }

        private void ShowAddon(AddonDescriptor addon)
        {
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
            AddonDescriptor addon = addonList.SelectedItem as AddonDescriptor;
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
            addonTitle.Text = string.Empty;
            addonCredits.Text = string.Empty;
            addonDescription.Text = string.Empty;
            previewCounter.Text = string.Empty;
            ReplacePreviewImage(null);
        }

        private void UpdateAddonStatus()
        {
            options.UseAddon = useAddonCheck.Checked;
            if (!options.UseAddon) {
                addonStatus.Text = catalog.Get("No addon selected.");
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
