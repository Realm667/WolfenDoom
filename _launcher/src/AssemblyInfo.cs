using System.Reflection;
using System.Runtime.InteropServices;

[assembly: AssemblyTitle("Blade of Agony Launcher")]
[assembly: AssemblyDescription("Modern WPF launcher for Blade of Agony and UZDoom 5.0.3 or newer")]
[assembly: AssemblyCompany("Clean-room reconstruction")]
[assembly: AssemblyProduct("Blade of Agony Launcher")]
[assembly: AssemblyCopyright("Blade of Agony assets remain property of their respective owners")]
[assembly: ComVisible(false)]
[assembly: Guid("f6e5148b-4d9e-4be8-b9b6-226302494fbb")]
[assembly: AssemblyVersion(BladeOfAgonyLauncher.LauncherVersion.Assembly)]
[assembly: AssemblyFileVersion(BladeOfAgonyLauncher.LauncherVersion.Assembly)]

namespace BladeOfAgonyLauncher
{
    internal static class LauncherVersion
    {
        internal const string Number = "2.6.25";
        internal const string Assembly = Number + ".0";
    }
}
