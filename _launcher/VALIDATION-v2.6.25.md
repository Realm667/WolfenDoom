# 2.6.25 release checks

Run build.ps1, Test-Optimizations.ps1 -SkipBuild and Test-ReleaseUI.ps1
from a clean Windows checkout. Package with package.ps1 -SkipBuild to
verify the release manifest against the staged files and ZIP contents.

