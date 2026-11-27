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
        private TextBlock CreateHeading(string value, string automationId)
        {
            TextBlock heading = new TextBlock {
                Text = value,
                Foreground = palette.Text,
                FontFamily = unicaOneFont,
                FontSize = 28,
                FontWeight = FontWeights.Normal
            };
            AutomationProperties.SetAutomationId(heading, automationId);
            AutomationProperties.SetItemStatus(heading, unicaOneFont.Source);
            return heading;
        }

        private StackPanel CreateSection(string heading)
        {
            StackPanel section = new StackPanel {
                Width = 390,
                Margin = new Thickness(0, 0, 34, 20)
            };
            section.Children.Add(CreateSectionHeader(heading));
            return section;
        }

        private TextBlock CreateSectionHeader(string value)
        {
            return new TextBlock {
                Text = value,
                Foreground = palette.Text,
                FontSize = 17,
                FontWeight = FontWeights.SemiBold,
                Margin = new Thickness(0, 0, 0, 12)
            };
        }

        private FrameworkElement CreateField(string label, Control control)
        {
            StackPanel field = new StackPanel { Margin = new Thickness(0, 0, 0, 13) };
            field.Children.Add(new TextBlock {
                Text = label,
                Foreground = palette.Muted,
                FontSize = 12,
                Margin = new Thickness(1, 0, 0, 5)
            });
            if (double.IsNaN(control.Height) || control.Height < 36) {
                control.Height = 36;
            }
            field.Children.Add(control);
            AutomationProperties.SetName(control, label);
            return field;
        }

        private FrameworkElement CreateInfoBar(string message, Brush accent)
        {
            Border border = new Border {
                Background = palette.Surface,
                BorderBrush = accent,
                BorderThickness = new Thickness(4, 0, 0, 0),
                Padding = new Thickness(14, 11, 14, 11),
                Margin = new Thickness(0, 16, 0, 0)
            };
            border.Child = new TextBlock {
                Text = message,
                Foreground = palette.Text,
                TextWrapping = TextWrapping.Wrap
            };
            return border;
        }

        private FrameworkElement CreateStatusRow(
            string label, string value, bool good)
        {
            return CreateStatusRow(label, value, good ? RowState.Ready : RowState.Blocked);
        }

        private enum RowState { Ready, Information, Warning, Blocked }

        private FrameworkElement CreateStatusRow(string label, string value, RowState severity)
        {
            Border row = new Border {
                BorderBrush = palette.Border,
                BorderThickness = new Thickness(0, 0, 0, 1),
                Padding = new Thickness(0, 10, 0, 10)
            };
            Grid grid = new Grid();
            grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(145) });
            grid.ColumnDefinitions.Add(new ColumnDefinition {
                Width = new GridLength(1, GridUnitType.Star)
            });
            grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
            grid.Children.Add(new TextBlock {
                Text = label, TextWrapping = TextWrapping.Wrap,
                Foreground = palette.Text,
                FontWeight = FontWeights.SemiBold
            });
            TextBlock valueText = new TextBlock {
                Text = value,
                Foreground = palette.Muted,
                TextWrapping = TextWrapping.Wrap
            };
            Grid.SetColumn(valueText, 1);
            grid.Children.Add(valueText);
            TextBlock status = new TextBlock {
                Text = severity == RowState.Ready ? "\uE73E" : severity == RowState.Warning ? "\uE7BA" : severity == RowState.Information ? "\uE946" : "\uEA39",
                FontFamily = new FontFamily("Segoe Fluent Icons, Segoe MDL2 Assets"),
                Foreground = severity == RowState.Ready ? palette.Good : severity == RowState.Warning ? palette.Warning : severity == RowState.Information ? palette.Muted : palette.Error,
                FontSize = 17,
                Margin = new Thickness(12, 0, 0, 0)
            };
            var badge = new StackPanel { Orientation = Orientation.Horizontal, VerticalAlignment = VerticalAlignment.Center };
            badge.Children.Add(status);
            badge.Children.Add(new TextBlock { Text = text.Get(severity.ToString()), Foreground = palette.Text, Margin = new Thickness(5,0,0,0) });
            Grid.SetColumn(badge, 2);
            grid.Children.Add(badge);
            row.Child = grid;
            return row;
        }

        private Button CreateButton(string label, bool primary)
        {
            Button button = new Button {
                Content = label,
                Foreground = primary ? palette.AccentText : palette.Text,
                Background = primary ? palette.ButtonFill : palette.SurfaceAlternative,
                BorderBrush = primary ? palette.Accent : palette.Border,
                BorderThickness = new Thickness(1),
                Padding = new Thickness(14, 7, 14, 7),
                Cursor = Cursors.Hand,
                MinHeight = 34,
                FontWeight = FontWeights.SemiBold
            };
            button.Template = CreateButtonTemplate();
            return button;
        }

        private Button CreateIconButton(string glyph, string tooltip)
        {
            Button button = CreateButton(glyph, false);
            button.FontFamily = new FontFamily("Segoe Fluent Icons, Segoe MDL2 Assets");
            button.FontSize = 15;
            button.Width = 38;
            button.Height = 36;
            button.Margin = new Thickness(4, 0, 0, 0);
            button.Padding = new Thickness(0);
            button.HorizontalContentAlignment = HorizontalAlignment.Center;
            button.VerticalContentAlignment = VerticalAlignment.Center;
            button.ToolTip = tooltip;
            AutomationProperties.SetName(button, tooltip);
            return button;
        }

        private Button CreateCommandButton(
            string glyph, string label, bool primary)
        {
            Button button = CreateButton(string.Empty, primary);
            StackPanel panel = new StackPanel {
                Orientation = Orientation.Horizontal,
                VerticalAlignment = VerticalAlignment.Center
            };
            panel.Children.Add(new TextBlock {
                Text = glyph,
                FontFamily = new FontFamily(
                    "Segoe Fluent Icons, Segoe MDL2 Assets"),
                FontSize = 15,
                VerticalAlignment = VerticalAlignment.Center,
                Margin = new Thickness(0, 0, 9, 0)
            });
            panel.Children.Add(new TextBlock {
                Text = label,
                FontWeight = FontWeights.SemiBold,
                VerticalAlignment = VerticalAlignment.Center
            });
            foreach (TextBlock item in panel.Children) {
                item.SetBinding(
                    TextBlock.ForegroundProperty,
                    new System.Windows.Data.Binding("Foreground") {
                        Source = button
                    });
            }
            button.Content = panel;
            AutomationProperties.SetName(button, label);
            return button;
        }

        private ControlTemplate CreateButtonTemplate()
        {
            FrameworkElementFactory border =
                new FrameworkElementFactory(typeof(Border));
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
            border.SetValue(Border.CornerRadiusProperty, new CornerRadius(4));
            border.SetValue(Border.SnapsToDevicePixelsProperty, true);

            FrameworkElementFactory presenter =
                new FrameworkElementFactory(typeof(ContentPresenter));
            presenter.SetBinding(
                ContentPresenter.HorizontalAlignmentProperty,
                new System.Windows.Data.Binding("HorizontalContentAlignment") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            presenter.SetBinding(
                ContentPresenter.VerticalAlignmentProperty,
                new System.Windows.Data.Binding("VerticalContentAlignment") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            presenter.SetValue(
                ContentPresenter.RecognizesAccessKeyProperty, true);
            presenter.SetBinding(
                ContentPresenter.MarginProperty,
                new System.Windows.Data.Binding("Padding") {
                    RelativeSource = System.Windows.Data.RelativeSource.TemplatedParent
                });
            border.AppendChild(presenter);

            ControlTemplate template = new ControlTemplate(typeof(Button));
            template.VisualTree = border;
            Trigger hover = new Trigger {
                Property = Button.IsMouseOverProperty,
                Value = true
            };
            hover.Setters.Add(new Setter(
                Button.BorderBrushProperty, palette.AccentHover));
            template.Triggers.Add(hover);
            Trigger focus = new Trigger {
                Property = Button.IsKeyboardFocusedProperty,
                Value = true
            };
            focus.Setters.Add(new Setter(
                Button.BorderBrushProperty, palette.Text));
            focus.Setters.Add(new Setter(
                Button.BorderThicknessProperty, new Thickness(2)));
            template.Triggers.Add(focus);
            Trigger disabled = new Trigger {
                Property = Button.IsEnabledProperty,
                Value = false
            };
            disabled.Setters.Add(new Setter(Button.OpacityProperty, 0.45));
            template.Triggers.Add(disabled);
            return template;
        }

        private ComboBox CreateComboBox()
        {
            ComboBox combo = new ComboBox {
                Background = palette.Surface,
                Foreground = options.Theme == LauncherTheme.Light
                    ? palette.Text
                    : Brushes.Black,
                BorderBrush = palette.Border,
                BorderThickness = new Thickness(1),
                Padding = new Thickness(8, 0, 8, 0),
                MinWidth = 150,
                MaxDropDownHeight = 360,
                VerticalContentAlignment = VerticalAlignment.Center
            };
            combo.IsEnabledChanged += delegate {
                combo.Foreground = combo.IsEnabled
                    ? (options.Theme == LauncherTheme.Light
                        ? palette.Text
                        : Brushes.Black)
                    : palette.Muted;
            };
            return combo;
        }

        private TextBox CreateTextBox(string value)
        {
            return new TextBox {
                Text = value,
                Background = palette.Surface,
                Foreground = palette.Text,
                BorderBrush = palette.Border,
                BorderThickness = new Thickness(1),
                Padding = new Thickness(9, 6, 9, 6),
                CaretBrush = palette.Text
            };
        }

        private PasswordBox CreatePasswordBox()
        {
            return new PasswordBox {
                Background = palette.Surface,
                Foreground = palette.Text,
                BorderBrush = palette.Border,
                BorderThickness = new Thickness(1),
                Padding = new Thickness(9, 6, 9, 6),
                MinWidth = 150,
                CaretBrush = palette.Text
            };
        }
    }
}
