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
        private FrameworkElement BuildDiagnosticsPage()
        {
            StackPanel page = CreatePageContent();
            Grid heading = new Grid();
            heading.ColumnDefinitions.Add(new ColumnDefinition {
                Width = new GridLength(1, GridUnitType.Star)
            });
            heading.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
            heading.Children.Add(CreatePageTitle(
                text.Get("Diagnostics"), text.Get("Status"),
                "HeadingDiagnostics"));
            Button refresh = CreateCommandButton(
                "\uE72C", text.Get("Refresh"), false);
            AutomationProperties.SetAutomationId(refresh, "RefreshDiagnostics");
            refresh.Click += delegate {
                RefreshDataAsync(DataScope.All, false);
            };
            Grid.SetColumn(refresh, 1);
            heading.Children.Add(refresh);
            page.Children.Add(heading);

            MultiplayerCompatibilityStatus status =
                MultiplayerCompatibilityStatus.Inspect(baseDirectory);
            StackPanel state = new StackPanel { Margin = new Thickness(0, 20, 0, 20) };
            state.Children.Add(CreateStatusRow(
                text.Get("Engine"),
                status.EnginePresent
                    ? "UZDoom " + status.EngineVersion
                    : text.Get("Not found"),
                status.CorrectEngineVersion));
            state.Children.Add(CreateStatusRow(
                text.Get("Main game"),
                status.MainGamePresent
                    ? "boa.ipk3, " + status.MainGameDescription
                    : text.Get("Not found"),
                status.MainGamePresent));
            state.Children.Add(CreateStatusRow(
                text.Get("Content source"),
                contentCatalog.SourceDescription,
                contentCatalog.Error == null));
            state.Children.Add(CreateStatusRow(
                text.Get("Add-ons"),
                availableAddons.Count.ToString(
                    System.Globalization.CultureInfo.InvariantCulture) +
                    " " + text.Get("Detected"),
                true));
            state.Children.Add(CreateStatusRow(
                text.Get("Savegames"),
                savegames.Count.ToString(
                    System.Globalization.CultureInfo.InvariantCulture) + " " +
                    text.Get("Detected"),
                true));
            state.Children.Add(CreateStatusRow(
                text.Get("Save locations"),
                string.Join(Environment.NewLine,
                    SavegameService.GetSaveRoots(baseDirectory).ToArray()),
                RowState.Information));
            state.Children.Add(CreateStatusRow(
                text.Get("Engine capabilities"),
                engineCapabilities.Describe(text),
                engineCapabilities.LoadGame && engineCapabilities.Config));
            EngineReleaseChannel channel =
                EngineVersionSupport.ReleaseChannel(baseDirectory);
            state.Children.Add(CreateStatusRow(
                text.Get("Engine release channel"), text.Get(channel.ToString()),
                channel == EngineReleaseChannel.Stable ? RowState.Ready : channel == EngineReleaseChannel.Preview ? RowState.Information : RowState.Blocked));
            string uzdoomConfig = UZDoomConfiguration.FindExisting(baseDirectory);
            state.Children.Add(CreateStatusRow(
                text.Get("UZDoom configuration"),
                string.IsNullOrEmpty(uzdoomConfig)
                    ? text.Get("UZDoom will create a default configuration.")
                    : uzdoomConfig,
                RowState.Information));
            state.Children.Add(CreateStatusRow(
                text.Get("Launcher manifest"),
                launcherManifest.Source +
                    (string.IsNullOrWhiteSpace(launcherManifest.BoaVersion)
                        ? string.Empty
                        : ", BoA " + launcherManifest.BoaVersion),
                launcherManifest.FormatVersion == 1));
            ApplySelectedAddonsToOptions();
            PreflightResult preflight = displayPreflight;
            state.Children.Add(CreateStatusRow(
                text.Get("Launch preflight"),
                preflight.WarningCount == 0 ? text.Get(preflight.CanLaunch ? "Passed" : "Blocked") : text.Get("Warning") + ": " + preflight.WarningCount,
                !preflight.CanLaunch ? RowState.Blocked : preflight.WarningCount > 0 ? RowState.Warning : RowState.Ready));
            page.Children.Add(state);

            if (!preflight.CanLaunch || preflight.WarningCount > 0) {
                page.Children.Add(CreateSectionHeader(text.Get("Preflight details")));
                foreach (PreflightFinding finding in preflight.Findings) {
                    if (finding.Severity == PreflightSeverity.Information) continue;
                    page.Children.Add(CreateInfoBar(
                        FindingText(finding),
                        finding.Severity == PreflightSeverity.Blocking
                            ? palette.Error
                            : palette.Warning));
                }
            }
            CrashDiagnosis crash = CrashLogAnalyzer.AnalyzeLatest(baseDirectory);
            if (crash != null) {
                page.Children.Add(CreateInfoBar(
                    text.Get("Latest crash diagnosis") + ": " + text.Get("Crash:" + crash.Category),
                    palette.Warning));
            }

            page.Children.Add(CreateSectionHeader(text.Get("Command line")));
            TextBox command = CreateTextBox(
                LauncherCommand.BuildPrivacySafeDisplayCommand(options));
            command.IsReadOnly = true;
            command.TextWrapping = TextWrapping.Wrap;
            command.MinHeight = 76;
            command.Margin = new Thickness(0, 8, 0, 12);
            page.Children.Add(command);

            WrapPanel actions = new WrapPanel {
                Orientation = Orientation.Horizontal,
                Margin = new Thickness(-4, 4, -4, -4)
            };
            AutomationProperties.SetAutomationId(actions, "DiagnosticsActions");
            Button copy = CreateCommandButton(
                "\uE8C8", text.Get("Copy command"), false);
            copy.Margin = new Thickness(4);
            copy.Click += delegate {
                Clipboard.SetText(LauncherCommand.BuildPrivacySafeDisplayCommand(options));
                footerStatus.Text = text.Get("Copy command") + ": " + text.Get("Ready");
            };
            Button open = CreateCommandButton(
                "\uE8B7", text.Get("Open game folder"), false);
            open.Margin = new Thickness(4);
            open.Click += delegate {
                Process.Start(new ProcessStartInfo {
                    FileName = baseDirectory,
                    UseShellExecute = true
                });
            };
            actions.Children.Add(copy);
            actions.Children.Add(open);
            Button package = CreateCommandButton(
                "\uE7B8", text.Get("Create support package"), false);
            package.Margin = new Thickness(4);
            AutomationProperties.SetAutomationId(package, "CreateSupportPackage");
            package.Click += delegate { CreateSupportPackage(); };
            actions.Children.Add(package);
            Button verify = CreateCommandButton(
                "\uE9D9", text.Get("Verify installation"), false);
            verify.Margin = new Thickness(4);
            verify.Click += delegate {
                ApplySelectedAddonsToOptions();
                LauncherOptions snapshot = options.Snapshot();
                List<AddonDescriptor> selection = new List<AddonDescriptor>(selectedAddons);
                PreflightResult checkedResult = null;
                RunWorkAsync(delegate {
                    checkedResult = LauncherPreflight.Inspect(snapshot, selection);
                }, delegate {
                displayPreflight = checkedResult;
                UpdateReadiness();
                MessageBox.Show(
                    string.Join(Environment.NewLine,
                        checkedResult.Findings.Select(
                            delegate(PreflightFinding finding) {
                                return FindingText(finding);
                            }).ToArray()),
                    text.Get("Verify installation"),
                    MessageBoxButton.OK,
                    checkedResult.CanLaunch
                        ? MessageBoxImage.Information
                        : MessageBoxImage.Error);
                });
            };
            actions.Children.Add(verify);
            Button matrix = CreateCommandButton(
                "\uE8EF", text.Get("Validate add-on matrix"), false);
            matrix.Margin = new Thickness(4);
            AutomationProperties.SetAutomationId(matrix, "ValidateAddonMatrix");
            matrix.Click += delegate {
                List<AddonDescriptor> addons = new List<AddonDescriptor>(availableAddons);
                List<string> lines = null;
                RunWorkAsync(delegate {
                lines = AddonLoadOrderResolver.ValidatePairwiseMatrix(baseDirectory, addons);
                string report = Path.Combine(
                    LauncherPaths.DataDirectory(baseDirectory),
                    "addon-compatibility-matrix.txt");
                File.WriteAllLines(report, lines.ToArray(), new UTF8Encoding(false));
                }, delegate {
                int blocked = lines.Count(delegate(string line) {
                    return line.StartsWith("BLOCK ", StringComparison.Ordinal);
                });
                footerStatus.Text = string.Format(text.Get("Report saved: {0} passed, {1} blocked."), lines.Count - blocked, blocked);
                });
            };
            actions.Children.Add(matrix);
            page.Children.Add(actions);
            FrameworkElement diagnosticsPage = WrapPage(page);
            AutomationProperties.SetAutomationId(
                diagnosticsPage, "DiagnosticsScroll");
            return diagnosticsPage;
        }
    }
}
