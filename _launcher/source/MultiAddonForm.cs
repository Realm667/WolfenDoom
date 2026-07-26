using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace BladeOfAgonyLauncher
{
    internal sealed class MultiAddonForm : Form
    {
        private readonly ListBox availableList = new ListBox();
        private readonly ListBox loadOrderList = new ListBox();
        private readonly PoCatalog catalog;

        internal List<AddonDescriptor> SelectedAddons
        {
            get
            {
                List<AddonDescriptor> result = new List<AddonDescriptor>();
                foreach (object item in loadOrderList.Items) {
                    result.Add((AddonDescriptor)item);
                }
                return result;
            }
        }

        internal MultiAddonForm(
            IList<AddonDescriptor> allAddons, IList<AddonDescriptor> selectedAddons, PoCatalog catalog)
        {
            this.catalog = catalog;
            Text = "Blade of Agony: " + catalog.Get("Select multiple addons").ToLowerInvariant();
            StartPosition = FormStartPosition.CenterParent;
            MinimumSize = new Size(620, 420);
            Size = new Size(720, 500);
            MaximizeBox = false;
            MinimizeBox = false;
            ShowInTaskbar = false;

            HashSet<string> selectedPaths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (AddonDescriptor addon in selectedAddons) {
                loadOrderList.Items.Add(addon);
                selectedPaths.Add(addon.DescriptorPath);
            }
            foreach (AddonDescriptor addon in allAddons) {
                if (!selectedPaths.Contains(addon.DescriptorPath)) {
                    availableList.Items.Add(addon);
                }
            }

            Controls.Add(CreateLayout());
            AcceptButton = FindButtonByDialogResult(DialogResult.OK);
            CancelButton = FindButtonByDialogResult(DialogResult.Cancel);
        }

        private Control CreateLayout()
        {
            TableLayoutPanel root = new TableLayoutPanel();
            root.Dock = DockStyle.Fill;
            root.Padding = new Padding(12);
            root.ColumnCount = 3;
            root.RowCount = 3;
            root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
            root.ColumnStyles.Add(new ColumnStyle(SizeType.Absolute, 64));
            root.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 50));
            root.RowStyles.Add(new RowStyle(SizeType.Absolute, 26));
            root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
            root.RowStyles.Add(new RowStyle(SizeType.Absolute, 46));

            Label availableLabel = new Label();
            availableLabel.Text = catalog.Get("Available addons:");
            availableLabel.Dock = DockStyle.Fill;
            availableLabel.TextAlign = ContentAlignment.BottomLeft;
            root.Controls.Add(availableLabel, 0, 0);

            Label orderLabel = new Label();
            orderLabel.Text = catalog.Get("Load order:");
            orderLabel.Dock = DockStyle.Fill;
            orderLabel.TextAlign = ContentAlignment.BottomLeft;
            root.Controls.Add(orderLabel, 2, 0);

            availableList.Dock = DockStyle.Fill;
            availableList.IntegralHeight = false;
            availableList.DoubleClick += delegate { MoveSelected(availableList, loadOrderList); };
            root.Controls.Add(availableList, 0, 1);

            loadOrderList.Dock = DockStyle.Fill;
            loadOrderList.IntegralHeight = false;
            loadOrderList.DoubleClick += delegate { MoveSelected(loadOrderList, availableList); };
            root.Controls.Add(loadOrderList, 2, 1);

            FlowLayoutPanel arrows = new FlowLayoutPanel();
            arrows.Dock = DockStyle.Fill;
            arrows.FlowDirection = FlowDirection.TopDown;
            arrows.WrapContents = false;
            arrows.Padding = new Padding(10, 18, 10, 0);
            arrows.Controls.Add(CreateArrowButton(">", delegate { MoveSelected(availableList, loadOrderList); }));
            arrows.Controls.Add(CreateArrowButton("<", delegate { MoveSelected(loadOrderList, availableList); }));
            arrows.Controls.Add(CreateArrowButton("Up", delegate { MoveLoadItem(-1); }));
            arrows.Controls.Add(CreateArrowButton("Down", delegate { MoveLoadItem(1); }));
            root.Controls.Add(arrows, 1, 1);

            FlowLayoutPanel actions = new FlowLayoutPanel();
            actions.Dock = DockStyle.Fill;
            actions.FlowDirection = FlowDirection.RightToLeft;
            actions.Padding = new Padding(0, 8, 0, 0);

            Button cancel = new Button();
            cancel.Text = catalog.Get("Cancel");
            cancel.DialogResult = DialogResult.Cancel;
            cancel.AutoSize = true;
            cancel.MinimumSize = new Size(92, 30);

            Button apply = new Button();
            apply.Text = catalog.Get("Apply");
            apply.DialogResult = DialogResult.OK;
            apply.AutoSize = true;
            apply.MinimumSize = new Size(92, 30);

            actions.Controls.Add(cancel);
            actions.Controls.Add(apply);
            root.Controls.Add(actions, 0, 2);
            root.SetColumnSpan(actions, 3);
            return root;
        }

        private Button CreateArrowButton(string text, EventHandler click)
        {
            Button button = new Button();
            button.Text = text;
            button.Size = new Size(42, 31);
            button.Margin = new Padding(0, 3, 0, 3);
            button.Click += click;
            return button;
        }

        private void MoveSelected(ListBox source, ListBox destination)
        {
            AddonDescriptor selected = source.SelectedItem as AddonDescriptor;
            if (selected == null) {
                return;
            }
            source.Items.Remove(selected);
            destination.Items.Add(selected);
            destination.SelectedItem = selected;
        }

        private void MoveLoadItem(int direction)
        {
            int sourceIndex = loadOrderList.SelectedIndex;
            int targetIndex = sourceIndex + direction;
            if (sourceIndex < 0 || targetIndex < 0 || targetIndex >= loadOrderList.Items.Count) {
                return;
            }
            object item = loadOrderList.Items[sourceIndex];
            loadOrderList.Items.RemoveAt(sourceIndex);
            loadOrderList.Items.Insert(targetIndex, item);
            loadOrderList.SelectedIndex = targetIndex;
        }

        private Button FindButtonByDialogResult(DialogResult result)
        {
            return FindButtonRecursive(this, result);
        }

        private static Button FindButtonRecursive(Control parent, DialogResult result)
        {
            foreach (Control child in parent.Controls) {
                Button button = child as Button;
                if (button != null && button.DialogResult == result) {
                    return button;
                }
                Button nested = FindButtonRecursive(child, result);
                if (nested != null) {
                    return nested;
                }
            }
            return null;
        }
    }
}
