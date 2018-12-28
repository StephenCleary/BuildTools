# Expected variables:
#   $testProjectLocations - an array of relative paths to projects that can run "dotnet test".
#   $outputLocation - the relative path where test results should be stored. This path does not have to exist.
#   $dotnetTestArgs (optional) - arguments to pass to "dotnet test".

$ErrorActionPreference = "Stop"

md -Force $outputLocation | Out-Null
$outputPath = (Resolve-Path $outputLocation).Path
$outputFile = Join-Path $outputPath -childpath 'coverage.xml'
For ($i = 0; $i -ne $testProjectLocations.length; ++$i)
{
	$testProjectLocations[$i] = (Resolve-Path $testProjectLocations[$i]).Path
}
Remove-Item $outputPath -Force -Recurse
md -Force $outputLocation | Out-Null

Write-Output $outputPath
Write-Output $outputFile

Function Verify-OnlyOnePackage
{
	param ($name)

	$location = $env:USERPROFILE + '\.nuget\packages\' + $name
	If ((Get-ChildItem $location).Count -ne 1)
	{
		throw 'Invalid number of packages installed at ' + $location
	}
}

Verify-OnlyOnePackage 'OpenCover'
Verify-OnlyOnePackage 'coveralls.io'
Verify-OnlyOnePackage 'ReportGenerator'

pushd
Try
{
	ForEach ($testProjectLocation in $testProjectLocations)
	{
		cd $testProjectLocation

		# Execute OpenCover with a target of "dotnet test"
		$command = (Get-ChildItem ($env:USERPROFILE + '\.nuget\packages\OpenCover'))[0].FullName + '\tools\OpenCover.Console.exe' + ' -register:user -oldStyle -mergeoutput -target:dotnet.exe "-targetargs:test --no-restore ' + $dotnetTestArgs + '" "-output:' + $outputFile + '" -skipautoprops -returntargetcode "-excludebyattribute:System.Diagnostics.DebuggerNonUserCodeAttribute" "-filter:+[Nito*]*"'
		Write-Output $command
		iex $command
	}

	# Either display or publish the results
	If ($env:CI -eq 'True')
	{
		$command = (Get-ChildItem ($env:USERPROFILE + '\.nuget\packages\coveralls.io'))[0].FullName + '\tools\coveralls.net.exe' + ' --opencover "' + $outputFile + '" --full-sources'
		Write-Output $command
		iex $command
	}
	Else
	{
		$command = (Get-ChildItem ($env:USERPROFILE + '\.nuget\packages\ReportGenerator'))[0].FullName + '\tools\net47\ReportGenerator.exe -reports:"' + $outputFile + '" -targetdir:"' + $outputPath + '"'
		Write-Output $command
		iex $command
		cd $outputPath
		./index.htm
	}
}
Finally
{
	popd
}
