# Build validation

The public source patch was applied to a fresh checkout of the pinned
`release_21H2` upstream commit, including its submodules. On Windows 11 x64,
the patched checkout completed a Release x64 build with zero warnings and zero
errors on 2026-09-16.

The validation used Visual Studio 2022 Build Tools and Windows Driver Kit
10.0.22000.1, with NetAdapterCx 2.2. The helper is deliberately explicit about
that older toolchain because this upstream sample does not build cleanly against
the current NetAdapterCx 2.4 defaults.

From a patched upstream working tree, run:

```powershell
& .\tools\Build-Validated.ps1 -SourceRoot C:\path\to\NCM-Driver-for-Windows
```

The helper disables automatic test signing and two legacy package-validation
steps that do not run reliably under Visual Studio 2022 with this historical
WDK build integration. It is a source-build check only. Its output is unsigned,
is not a release package, and must not be installed on a normal Secure-Boot
system.

It does compile and link the host driver, generates the sample catalog, and
checks catalog signability through `Inf2Cat`. Release signing and broader test
coverage remain required; see [RELEASE-CHECKLIST.md](RELEASE-CHECKLIST.md).
