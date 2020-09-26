# BuildTools
Miscellaneous tools for building .NET Core libraries.

## .github/workflows/build.yml

Common build script. On every push, regardless of branch:
- Builds.
- Runs all tests, collecting code coverage.
- Creates NuGet packages.
- Uploads results.
  - Note: NuGet publishing will fail unless the version number is new.

## .github/workflows/tag.yml

On every push, regardless of branch:
- Check to see if the current project version has a tag; if not, creates and pushes a tag to the repo.

## Directory.Build.props

Enforces the [C# OSS project checklist/guidelines](https://github.com/StephenCleary/Docs/tree/master/libraries).

This file expects another file to be present - `project.props` - which should define common properties such as `Author`.

## Directory.Build.targets

Enables two additional features, which can be enabled in the project file or `project.props`:
- Metapackages. Set `<IsMetapackage>true</IsMetapackage>` to create a metapackage (a NuGet package that only references other NuGet packages).
- Dotnet tools. Set `<ToolCommandName>mytool</ToolCommandName>` to create a dotnet tool package.
