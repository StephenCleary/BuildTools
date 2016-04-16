# Set $artifactLocation and $testProjectLocation before invoking this script.

$ErrorActionPreference = "Stop"

$libPath = Resolve-Path $artifactLocation

Function Verify-OnlyOnePackage
{
	param ($name)

	$location = $env:USERPROFILE + '\.dnx\packages\' + $name
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
	cd $testProjectLocation

	# Execute OpenCover with a target of "dnx test"
	iex ((Get-ChildItem ($env:USERPROFILE + '\.dnx\packages\OpenCover'))[0].FullName + '\tools\OpenCover.Console.exe' + ' -register:user -target:"dnx.exe" -targetargs:"--lib ' + $libPath + ' test" -output:coverage.xml -skipautoprops -returntargetcode -excludebyattribute:"System.Diagnostics.DebuggerNonUserCodeAttribute" -filter:"+[Nito*]*"')

	# Either display or publish the results
	If ($env:CI -eq 'True')
	{
		iex ((Get-ChildItem ($env:USERPROFILE + '\.dnx\packages\coveralls.io'))[0].FullName + '\tools\coveralls.net.exe' + ' --opencover coverage.xml --full-sources')
	}
	Else
	{
		iex ((Get-ChildItem ($env:USERPROFILE + '\.dnx\packages\ReportGenerator'))[0].FullName + '\tools\ReportGenerator.exe -reports:coverage.xml -targetdir:.')
		./index.htm
	}
}
Finally
{
	popd
}
