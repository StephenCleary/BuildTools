# BuildTools
Miscellaneous tools for building .NET Core libraries.

## Version.ps1

Update version numbers in source files.

Usage: `./Version.ps1 <oldversion> <newversion>`. This utility understands prerelease versioning.

Effects:
- `SharedAssemblyInfo.cs` files will have their `AssemblyVersion`, `AssemblyFileVersion`, and `AssemblyInformationalVersion` attributes updated.
- `*.csproj` files will have their `VersionPrefix` and `VersionSuffix` elements updated.
- `*.nuspec` files will have the old version text replaced with the new version text. Note that this may update versions of dependencies, so you need to check the output.

## Build.ps1

Does a single `restore` followed by a `pack` for each project under `src`. This script assumes:
- A single `.sln` file is in the current directory, with referenes to all projects under `src`.
- Each project to build is in a subfolder under `src`.

## Coverage.ps1

When run locally, uses `coverlet` and `ReportGenerator` to create a code coverage report. `ReportGenerator` will be installed if necessary.

When run on a build machine, uses `coverlet` and `codecov.io` to update code coverage metrics. `coveralls.net` will be installed if necessary.
