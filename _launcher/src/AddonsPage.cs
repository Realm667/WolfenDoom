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
        private FrameworkElement BuildAddonsPage()
        {
            Grid page = new Grid {
                Margin = new Thickness(28, 24, 28, 24)
            };
            page.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            page.RowDefinitions.Add(new RowDefinition {
                Height = new GridLength(1, GridUnitType.Star)
            });
            Grid heading = new Grid { Margin = new Thickness(0, 0, 0, 14) };
            heading.ColumnDefinitions.Add(new ColumnDefinition {
                Width = new GridLength(1, GridUnitType.Star)
            });
            heading.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
            StackPanel title = new StackPanel();
            title.Children.Add(CreateHeading(
                text.Get("Add-ons"), "HeadingAddons"));
            addonSelectionCount = new TextBlock {
                Foreground = palette.Muted,
                Margin = new Thickness(0, 5, 0, 0)
            };
            title.Children.Add(addonSelectionCount);
            heading.Children.Add(title);
            Button scan = CreateCommandButton(
                "\uE72C", text.Get("Scan add-ons"), false);
            scan.ToolTip = text.Get("Refresh");
            scan.Click += delegate {
                RefreshDataAsync(DataScope.Addons, false);
            };
            Grid.SetColumn(scan, 1);
            heading.Children.Add(scan);
            page.Children.Add(heading);

            Grid layout = new Grid();
            layout.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(360) });
            layout.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(18) });
            layout.ColumnDefinitions.Add(new ColumnDefinition {
                Width = new GridLength(1, GridUnitType.Star)
            });
            layout.RowDefinitions.Add(new RowDefinition {
                Height = new GridLength(1, GridUnitType.Star)
            });
            Grid.SetRow(layout, 1);
            page.Children.Add(layout);

            Grid listArea = new Grid();
            listArea.RowDefinitions.Add(new RowDefinition {
                Height = new GridLength(1, GridUnitType.Star)
            });
            listArea.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            addonList = new ListBox {
                Background = palette.Surface,
                Foreground = palette.Text,
                BorderBrush = palette.Border,
                BorderThickness = new Thickness(1),
                SelectionMode = SelectionMode.Extended,
                Padding = new Thickness(4)
            };
            AutomationProperties.SetName(addonList, text.Get("Add-on load order"));
            AutomationProperties.SetAutomationId(addonList, "AddonList");
            listArea.Children.Add(addonList);

            StackPanel orderButtons = new StackPanel {
                Orientation = Orientation.Horizontal,
                HorizontalAlignment = HorizontalAlignment.Right,
                Margin = new Thickness(0, 10, 0, 0)
            };
            addonResolveOrder = CreateCommandButton(
                "\uE8AB", "Resolve load order", false);
            addonResolveOrder.IsEnabled = selectedAddons.Count > 1;
            addonResolveOrder.Click += delegate {
                AddonLoadOrderResult resolved =
                    AddonLoadOrderResolver.Resolve(selectedAddons);
                if (!resolved.CanResolve) {
                    MessageBox.Show(string.Join(Environment.NewLine,
                            resolved.Messages.ToArray()),
                        text.Get("Compatibility"), MessageBoxButton.OK,
                        MessageBoxImage.Error);
                    return;
                }
                selectedAddons.Clear();
                selectedAddons.AddRange(resolved.Ordered);
                ApplySelectedAddonsToOptions();
                footerStatus.Text = resolved.Messages.Count > 0
                    ? resolved.Messages[0]
                    : "Load order resolved.";
                PopulateAddonList();
            };
            orderButtons.Children.Add(addonResolveOrder);
            addonMoveUp = CreateIconButton("\uE70E", text.Get("Move up"));
            addonMoveUp.Content = "\u2191";
            addonMoveUp.FontFamily = new FontFamily("Segoe UI Symbol");
            addonMoveDown = CreateIconButton("\u2193", text.Get("Move down"));
            addonMoveDown.FontFamily = new FontFamily("Segoe UI Symbol");
            AutomationProperties.SetAutomationId(addonMoveUp, "MoveAddonUp");
            AutomationProperties.SetAutomationId(addonMoveDown, "MoveAddonDown");
            addonMoveUp.Click += delegate { MoveSelectedAddon(-1); };
            addonMoveDown.Click += delegate { MoveSelectedAddon(1); };
            orderButtons.Children.Add(addonMoveUp);
            orderButtons.Children.Add(addonMoveDown);
            Grid.SetRow(orderButtons, 1);
            listArea.Children.Add(orderButtons);
            layout.Children.Add(listArea);

            FrameworkElement details = BuildAddonDetails();
            Grid.SetColumn(details, 2);
            layout.Children.Add(details);

            PopulateAddonList();
            return page;
        }

        private FrameworkElement BuildAddonDetails()
        {
            Border shell = new Border {
                Background = palette.Surface,
                Padding = new Thickness(22)
            };
            Grid layout = new Grid();
            layout.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            layout.RowDefinitions.Add(new RowDefinition {
                Height = new GridLength(1, GridUnitType.Star)
            });
            layout.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
            shell.Child = layout;

            StackPanel heading = new StackPanel();
            addonTitle = new TextBlock {
                Text = text.Get("Select an add-on to view its details."),
                Foreground = palette.Text,
                FontSize = 21,
                FontWeight = FontWeights.SemiBold,
                TextWrapping = TextWrapping.Wrap
            };
            addonCredits = new TextBlock {
                Foreground = palette.Muted,
                FontSize = 12,
                Margin = new Thickness(0, 3, 0, 8),
                TextWrapping = TextWrapping.NoWrap,
                TextTrimming = TextTrimming.CharacterEllipsis,
                MaxHeight = 18
            };
            heading.Children.Add(addonTitle);
            heading.Children.Add(addonCredits);
            layout.Children.Add(heading);

            ScrollViewer detailsScroll = new ScrollViewer {
                VerticalScrollBarVisibility = ScrollBarVisibility.Auto,
                HorizontalScrollBarVisibility = ScrollBarVisibility.Disabled,
                PanningMode = PanningMode.VerticalOnly
            };
            StackPanel details = new StackPanel();
            detailsScroll.Content = details;
            addonDescription = CreateBodyText();
            details.Children.Add(CreateDetailGroup(
                text.Get("Description"), addonDescription));
            addonRequirements = CreateBodyText();
            details.Children.Add(CreateDetailGroup(
                text.Get("Requirements"), addonRequirements));
            addonCompatibility = CreateBodyText();
            details.Children.Add(CreateDetailGroup(
                text.Get("Compatibility"), addonCompatibility));
            Grid.SetRow(detailsScroll, 1);
            layout.Children.Add(detailsScroll);

            addonPreviewViewport = new Border {
                Background = palette.SurfaceAlternative,
                ClipToBounds = true,
                Margin = new Thickness(0, 14, 0, 0),
                MinHeight = 140
            };
            addonPreviewViewport.SizeChanged += delegate {
                if (addonPreviewViewport.ActualWidth > 0) {
                    addonPreviewViewport.Height =
                        addonPreviewViewport.ActualWidth * 9.0 / 16.0;
                }
            };
            addonPreview = new Image {
                Stretch = Stretch.UniformToFill,
                HorizontalAlignment = HorizontalAlignment.Stretch,
                VerticalAlignment = VerticalAlignment.Stretch
            };
            Grid previewLayer = new Grid();
            previewLayer.Children.Add(addonPreview);

            addonPreviewPrevious = CreateIconButton(
                "\uE76B", "Previous screenshot");
            addonPreviewPrevious.HorizontalAlignment = HorizontalAlignment.Left;
            addonPreviewPrevious.VerticalAlignment = VerticalAlignment.Center;
            addonPreviewPrevious.Margin = new Thickness(10);
            addonPreviewPrevious.Opacity = 0.92;
            addonPreviewPrevious.Visibility = Visibility.Collapsed;
            AutomationProperties.SetAutomationId(
                addonPreviewPrevious, "AddonPreviewPrevious");
            addonPreviewPrevious.Click += delegate { ChangeAddonPreview(-1); };
            previewLayer.Children.Add(addonPreviewPrevious);

            addonPreviewNext = CreateIconButton(
                "\uE76C", "Next screenshot");
            addonPreviewNext.HorizontalAlignment = HorizontalAlignment.Right;
            addonPreviewNext.VerticalAlignment = VerticalAlignment.Center;
            addonPreviewNext.Margin = new Thickness(10);
            addonPreviewNext.Opacity = 0.92;
            addonPreviewNext.Visibility = Visibility.Collapsed;
            AutomationProperties.SetAutomationId(
                addonPreviewNext, "AddonPreviewNext");
            addonPreviewNext.Click += delegate { ChangeAddonPreview(1); };
            previewLayer.Children.Add(addonPreviewNext);

            addonPreviewCounter = new TextBlock {
                Foreground = palette.Text,
                Background = palette.Navigation,
                FontSize = 11,
                Padding = new Thickness(8, 4, 8, 4),
                HorizontalAlignment = HorizontalAlignment.Center,
                VerticalAlignment = VerticalAlignment.Bottom,
                Margin = new Thickness(0, 0, 0, 9),
                Visibility = Visibility.Collapsed
            };
            AutomationProperties.SetAutomationId(
                addonPreviewCounter, "AddonPreviewCounter");
            previewLayer.Children.Add(addonPreviewCounter);
            AutomationProperties.SetName(
                addonPreview, "AddonPreviewViewport");
            AutomationProperties.SetAutomationId(
                addonPreview, "AddonPreviewViewport");
            addonPreviewViewport.Child = previewLayer;
            AutomationProperties.SetName(
                addonPreviewViewport, "AddonPreviewViewport");
            Grid.SetRow(addonPreviewViewport, 2);
            layout.Children.Add(addonPreviewViewport);
            return shell;
        }

        private FrameworkElement CreateDetailGroup(string label, TextBlock value)
        {
            StackPanel group = new StackPanel { Margin = new Thickness(0, 0, 0, 16) };
            group.Children.Add(new TextBlock {
                Text = label.ToUpperInvariant(),
                Foreground = palette.Muted,
                FontSize = 11,
                FontWeight = FontWeights.SemiBold,
                Margin = new Thickness(0, 0, 0, 5)
            });
            group.Children.Add(value);
            return group;
        }
    }
}
