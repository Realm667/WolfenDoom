# Local standalone deployment

After a successful Windows build, `build.ps1` synchronizes launcher release
files when a target is configured. To enable it for all future builds on
your account, including builds from a clean export, run once:

```powershell
[Environment]::SetEnvironmentVariable('BOA_LAUNCHER_STANDALONE', 'D:\Games\Blade of Agony', 'User')
```

A process-level variable or `-StandaloneDirectory <path>` overrides the user
setting. Use `-SkipStandaloneSync` for an isolated build. Unconfigured
machines build normally without deploying. A configured but unavailable
target fails the build step rather than silently leaving an old launcher.

Deployment checks release hashes, copies only declared files, and installs
the manifest last. It never mirrors or deletes unrelated files. INI files,
in particular `boa-launcher.ini`, are explicitly forbidden. UZDoom updates
are independent of this workflow.
