using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Windows.Forms;

namespace BladeOfAgonyLauncher
{
    internal sealed class ThemedComboBox : ComboBox
    {
        internal Color BorderColor = Color.Gray;
        internal Color SurfaceColor = Color.DimGray;
        internal Color AccentColor = Color.SteelBlue;
        internal Color AccentTextColor = Color.White;
        internal Color MutedTextColor = Color.Silver;

        internal ThemedComboBox()
        {
            DrawMode = DrawMode.OwnerDrawFixed;
            DropDownStyle = ComboBoxStyle.DropDownList;
            FlatStyle = FlatStyle.Flat;
            ItemHeight = Math.Max(Font.Height + 4, 19);
        }

        protected override void OnFontChanged(EventArgs eventArgs)
        {
            base.OnFontChanged(eventArgs);
            ItemHeight = Math.Max(Font.Height + 4, 19);
        }

        protected override void OnDrawItem(DrawItemEventArgs eventArgs)
        {
            if (eventArgs.Index < 0 || eventArgs.Index >= Items.Count) {
                return;
            }

            bool selected = (eventArgs.State & DrawItemState.Selected) != 0;
            Color background = selected ? AccentColor : BackColor;
            Color foreground = selected
                ? AccentTextColor
                : (Enabled ? ForeColor : MutedTextColor);
            using (Brush brush = new SolidBrush(background)) {
                eventArgs.Graphics.FillRectangle(brush, eventArgs.Bounds);
            }
            TextRenderer.DrawText(
                eventArgs.Graphics,
                Items[eventArgs.Index].ToString(),
                Font,
                new Rectangle(
                    eventArgs.Bounds.Left + 6,
                    eventArgs.Bounds.Top,
                    Math.Max(0, eventArgs.Bounds.Width - 12),
                    eventArgs.Bounds.Height),
                foreground,
                TextFormatFlags.Left | TextFormatFlags.VerticalCenter |
                TextFormatFlags.EndEllipsis | TextFormatFlags.NoPrefix);
        }

        protected override void WndProc(ref Message message)
        {
            base.WndProc(ref message);
            if ((message.Msg == 0x000F || message.Msg == 0x0085) &&
                IsHandleCreated && !DroppedDown) {
                DrawClosedControl();
            }
        }

        private void DrawClosedControl()
        {
            using (Graphics graphics = Graphics.FromHwnd(Handle)) {
                Rectangle bounds = ClientRectangle;
                if (bounds.Width < 2 || bounds.Height < 2) {
                    return;
                }

                using (Brush inputBrush = new SolidBrush(BackColor)) {
                    graphics.FillRectangle(inputBrush, bounds);
                }

                int buttonWidth = Math.Min(26, bounds.Width);
                Rectangle button = new Rectangle(
                    bounds.Right - buttonWidth, bounds.Top + 1,
                    buttonWidth - 1, Math.Max(0, bounds.Height - 2));
                using (Brush surfaceBrush = new SolidBrush(SurfaceColor)) {
                    graphics.FillRectangle(surfaceBrush, button);
                }

                string value = SelectedItem == null ? Text : SelectedItem.ToString();
                TextRenderer.DrawText(
                    graphics,
                    value,
                    Font,
                    new Rectangle(
                        bounds.Left + 6,
                        bounds.Top + 1,
                        Math.Max(0, bounds.Width - buttonWidth - 9),
                        Math.Max(0, bounds.Height - 2)),
                    Enabled ? ForeColor : MutedTextColor,
                    TextFormatFlags.Left | TextFormatFlags.VerticalCenter |
                    TextFormatFlags.EndEllipsis | TextFormatFlags.NoPrefix);

                graphics.SmoothingMode = SmoothingMode.AntiAlias;
                int centerX = button.Left + button.Width / 2;
                int centerY = button.Top + button.Height / 2;
                using (Pen arrowPen = new Pen(
                    Enabled ? ForeColor : MutedTextColor, 1.5f)) {
                    graphics.DrawLine(arrowPen, centerX - 4, centerY - 2, centerX, centerY + 2);
                    graphics.DrawLine(arrowPen, centerX, centerY + 2, centerX + 4, centerY - 2);
                }

                using (Pen borderPen = new Pen(BorderColor)) {
                    graphics.DrawRectangle(
                        borderPen,
                        bounds.Left,
                        bounds.Top,
                        bounds.Width - 1,
                        bounds.Height - 1);
                    graphics.DrawLine(
                        borderPen,
                        button.Left,
                        bounds.Top + 1,
                        button.Left,
                        bounds.Bottom - 2);
                }
            }
        }
    }

    internal class ThemedTextBox : TextBox
    {
        internal Color BorderColor = Color.Gray;

        internal ThemedTextBox()
        {
            BorderStyle = BorderStyle.FixedSingle;
        }

        protected override void WndProc(ref Message message)
        {
            base.WndProc(ref message);
            if ((message.Msg == 0x000F || message.Msg == 0x0085) && IsHandleCreated) {
                using (Graphics graphics = Graphics.FromHwnd(Handle))
                using (Pen pen = new Pen(BorderColor)) {
                    Rectangle bounds = ClientRectangle;
                    if (bounds.Width > 1 && bounds.Height > 1) {
                        graphics.DrawRectangle(
                            pen, bounds.Left, bounds.Top, bounds.Width - 1, bounds.Height - 1);
                    }
                }
            }
        }
    }

    internal sealed class ThemedNumericUpDown : UserControl
    {
        internal Color BorderColor = Color.Gray;
        internal Color SurfaceColor = Color.DimGray;
        internal Color MutedTextColor = Color.Silver;
        internal Color AccentColor = Color.SteelBlue;

        private readonly TextBox editor = new TextBox();
        private decimal minimum;
        private decimal maximum = 100;
        private decimal currentValue;

        internal decimal Minimum
        {
            get { return minimum; }
            set
            {
                minimum = value;
                if (maximum < minimum) {
                    maximum = minimum;
                }
                Value = currentValue;
            }
        }

        internal decimal Maximum
        {
            get { return maximum; }
            set
            {
                maximum = Math.Max(minimum, value);
                Value = currentValue;
            }
        }

        internal decimal Value
        {
            get { return currentValue; }
            set
            {
                currentValue = Math.Max(minimum, Math.Min(maximum, value));
                editor.Text = Decimal.Truncate(currentValue).ToString(
                    System.Globalization.CultureInfo.InvariantCulture);
                Invalidate();
            }
        }

        internal ThemedNumericUpDown()
        {
            SetStyle(
                ControlStyles.AllPaintingInWmPaint |
                ControlStyles.OptimizedDoubleBuffer |
                ControlStyles.ResizeRedraw |
                ControlStyles.UserPaint,
                true);
            Height = 23;
            MinimumSize = new Size(48, 23);
            TabStop = true;

            editor.BorderStyle = BorderStyle.None;
            editor.Location = new Point(6, 4);
            editor.TextAlign = HorizontalAlignment.Left;
            editor.KeyDown += EditorKeyDown;
            editor.Leave += delegate { CommitEditor(); };
            Controls.Add(editor);
            Value = 0;
        }

        protected override void OnResize(EventArgs eventArgs)
        {
            base.OnResize(eventArgs);
            editor.Width = Math.Max(0, ClientSize.Width - 34);
            editor.Height = Math.Max(0, ClientSize.Height - 7);
        }

        protected override void OnFontChanged(EventArgs eventArgs)
        {
            base.OnFontChanged(eventArgs);
            editor.Font = Font;
        }

        protected override void OnBackColorChanged(EventArgs eventArgs)
        {
            base.OnBackColorChanged(eventArgs);
            editor.BackColor = BackColor;
        }

        protected override void OnForeColorChanged(EventArgs eventArgs)
        {
            base.OnForeColorChanged(eventArgs);
            editor.ForeColor = ForeColor;
        }

        protected override void OnEnabledChanged(EventArgs eventArgs)
        {
            base.OnEnabledChanged(eventArgs);
            editor.Enabled = Enabled;
            Invalidate();
        }

        protected override void OnMouseDown(MouseEventArgs eventArgs)
        {
            base.OnMouseDown(eventArgs);
            if (!Enabled) {
                return;
            }
            if (eventArgs.X >= ClientSize.Width - 25) {
                ChangeValue(eventArgs.Y < ClientSize.Height / 2 ? 1 : -1);
            } else {
                editor.Focus();
            }
        }

        protected override void OnMouseWheel(MouseEventArgs eventArgs)
        {
            base.OnMouseWheel(eventArgs);
            if (Enabled && eventArgs.Delta != 0) {
                ChangeValue(eventArgs.Delta > 0 ? 1 : -1);
            }
        }

        protected override void OnPaint(PaintEventArgs eventArgs)
        {
            Rectangle bounds = ClientRectangle;
            eventArgs.Graphics.Clear(BackColor);
            if (bounds.Width < 2 || bounds.Height < 2) {
                return;
            }

            int buttonWidth = Math.Min(25, bounds.Width);
            Rectangle buttons = new Rectangle(
                bounds.Right - buttonWidth, bounds.Top + 1,
                buttonWidth - 1, bounds.Height - 2);
            using (Brush brush = new SolidBrush(SurfaceColor)) {
                eventArgs.Graphics.FillRectangle(brush, buttons);
            }
            using (Pen borderPen = new Pen(BorderColor)) {
                eventArgs.Graphics.DrawRectangle(
                    borderPen, bounds.Left, bounds.Top, bounds.Width - 1, bounds.Height - 1);
                eventArgs.Graphics.DrawLine(
                    borderPen, buttons.Left, bounds.Top + 1,
                    buttons.Left, bounds.Bottom - 2);
                eventArgs.Graphics.DrawLine(
                    borderPen, buttons.Left, bounds.Top + bounds.Height / 2,
                    bounds.Right - 2, bounds.Top + bounds.Height / 2);
            }

            eventArgs.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
            Color arrowColor = Enabled ? ForeColor : MutedTextColor;
            using (Pen arrowPen = new Pen(arrowColor, 1.4f)) {
                int centerX = buttons.Left + buttons.Width / 2;
                int upperY = bounds.Top + bounds.Height / 4 + 1;
                int lowerY = bounds.Top + (bounds.Height * 3) / 4 - 1;
                eventArgs.Graphics.DrawLine(
                    arrowPen, centerX - 3, upperY + 1, centerX, upperY - 2);
                eventArgs.Graphics.DrawLine(
                    arrowPen, centerX, upperY - 2, centerX + 3, upperY + 1);
                eventArgs.Graphics.DrawLine(
                    arrowPen, centerX - 3, lowerY - 1, centerX, lowerY + 2);
                eventArgs.Graphics.DrawLine(
                    arrowPen, centerX, lowerY + 2, centerX + 3, lowerY - 1);
            }
        }

        private void EditorKeyDown(object sender, KeyEventArgs eventArgs)
        {
            if (eventArgs.KeyCode == Keys.Up) {
                ChangeValue(1);
                eventArgs.Handled = true;
            } else if (eventArgs.KeyCode == Keys.Down) {
                ChangeValue(-1);
                eventArgs.Handled = true;
            } else if (eventArgs.KeyCode == Keys.Enter) {
                CommitEditor();
                eventArgs.Handled = true;
            }
        }

        private void CommitEditor()
        {
            decimal parsed;
            if (Decimal.TryParse(
                    editor.Text,
                    System.Globalization.NumberStyles.Integer,
                    System.Globalization.CultureInfo.InvariantCulture,
                    out parsed)) {
                Value = parsed;
            } else {
                Value = currentValue;
            }
        }

        private void ChangeValue(int direction)
        {
            CommitEditor();
            Value = currentValue + direction;
        }
    }

    internal sealed class ThemedBorderPanel : Panel
    {
        internal Color BorderColor = Color.Gray;

        internal ThemedBorderPanel()
        {
            SetStyle(
                ControlStyles.AllPaintingInWmPaint |
                ControlStyles.OptimizedDoubleBuffer |
                ControlStyles.ResizeRedraw |
                ControlStyles.UserPaint,
                true);
            Padding = new Padding(1);
        }

        protected override void OnPaint(PaintEventArgs eventArgs)
        {
            base.OnPaint(eventArgs);
            using (Pen pen = new Pen(BorderColor)) {
                eventArgs.Graphics.DrawRectangle(
                    pen, 0, 0, Math.Max(0, ClientSize.Width - 1),
                    Math.Max(0, ClientSize.Height - 1));
            }
        }
    }

    internal sealed class ThemedCheckBox : CheckBox
    {
        internal Color BorderColor = Color.Gray;
        internal Color InputColor = Color.DimGray;
        internal Color AccentColor = Color.SteelBlue;
        internal Color AccentTextColor = Color.White;
        internal Color MutedTextColor = Color.Silver;

        internal ThemedCheckBox()
        {
            SetStyle(
                ControlStyles.AllPaintingInWmPaint |
                ControlStyles.OptimizedDoubleBuffer |
                ControlStyles.ResizeRedraw |
                ControlStyles.UserPaint,
                true);
            AutoSize = true;
        }

        public override Size GetPreferredSize(Size proposedSize)
        {
            Size text = TextRenderer.MeasureText(
                Text, Font, Size.Empty,
                TextFormatFlags.NoPadding | TextFormatFlags.NoPrefix);
            return new Size(text.Width + 24, Math.Max(17, text.Height + 2));
        }

        protected override void OnPaint(PaintEventArgs eventArgs)
        {
            eventArgs.Graphics.Clear(BackColor);
            int boxSize = 14;
            int boxY = Math.Max(0, (ClientSize.Height - boxSize) / 2);
            Rectangle box = new Rectangle(0, boxY, boxSize, boxSize);
            using (Brush inputBrush = new SolidBrush(Checked ? AccentColor : InputColor)) {
                eventArgs.Graphics.FillRectangle(inputBrush, box);
            }
            using (Pen borderPen = new Pen(Checked ? AccentColor : BorderColor)) {
                eventArgs.Graphics.DrawRectangle(
                    borderPen, box.Left, box.Top, box.Width - 1, box.Height - 1);
            }

            if (Checked) {
                eventArgs.Graphics.SmoothingMode = SmoothingMode.AntiAlias;
                using (Pen checkPen = new Pen(AccentTextColor, 1.6f)) {
                    eventArgs.Graphics.DrawLine(
                        checkPen, box.Left + 3, box.Top + 7, box.Left + 6, box.Top + 10);
                    eventArgs.Graphics.DrawLine(
                        checkPen, box.Left + 6, box.Top + 10, box.Left + 11, box.Top + 4);
                }
            }

            TextRenderer.DrawText(
                eventArgs.Graphics,
                Text,
                Font,
                new Rectangle(
                    21, 0, Math.Max(0, ClientSize.Width - 21), ClientSize.Height),
                Enabled ? ForeColor : MutedTextColor,
                TextFormatFlags.Left | TextFormatFlags.VerticalCenter |
                TextFormatFlags.EndEllipsis | TextFormatFlags.NoPrefix);
        }
    }

    internal sealed class ThemedGroupBox : GroupBox
    {
        internal Color BorderColor = Color.Gray;

        internal ThemedGroupBox()
        {
            SetStyle(
                ControlStyles.AllPaintingInWmPaint |
                ControlStyles.OptimizedDoubleBuffer |
                ControlStyles.ResizeRedraw |
                ControlStyles.UserPaint,
                true);
        }

        protected override void OnPaint(PaintEventArgs eventArgs)
        {
            eventArgs.Graphics.Clear(BackColor);
            Size textSize = TextRenderer.MeasureText(
                Text, Font, Size.Empty, TextFormatFlags.NoPadding);
            int top = Math.Max(0, textSize.Height / 2);
            Rectangle border = new Rectangle(
                0, top, Math.Max(0, ClientSize.Width - 1),
                Math.Max(0, ClientSize.Height - top - 1));

            using (Pen pen = new Pen(BorderColor)) {
                eventArgs.Graphics.DrawRectangle(pen, border);
            }

            Rectangle textBackground = new Rectangle(
                8, 0, textSize.Width + 8, textSize.Height);
            using (Brush brush = new SolidBrush(BackColor)) {
                eventArgs.Graphics.FillRectangle(brush, textBackground);
            }
            TextRenderer.DrawText(
                eventArgs.Graphics,
                Text,
                Font,
                new Point(12, 0),
                ForeColor,
                TextFormatFlags.NoPadding | TextFormatFlags.NoPrefix);
        }
    }
}
