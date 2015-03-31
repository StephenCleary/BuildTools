# Set $artifactLocation before invoking this script.

$ErrorActionPreference = "Stop"

Function Verify-OnlyOnePackage
{
	param ($name)

	$location = $env:USERPROFILE + '\.k\packages\' + $name
	If ((Get-ChildItem $location).Count -ne 1)
	{
		throw 'Invalid number of packages installed at ' + $location
	}
}

Verify-OnlyOnePackage 'OpenCover'
Verify-OnlyOnePackage 'coveralls.io'
Verify-OnlyOnePackage 'ReportGenerator'

pushd
$original_KRE_APPBASE = $env:KRE_APPBASE
Try
{
	cd $artifactLocation
	$env:KRE_APPBASE = "../../../../../test/UnitTests"

	# Execute OpenCover with a target of "k test"
	iex ((Get-ChildItem ($env:USERPROFILE + '\.k\packages\OpenCover'))[0].FullName + '\OpenCover.Console.exe' + ' -register:user -target:"k.cmd" -targetargs:"test" -output:coverage.xml -skipautoprops -returntargetcode -filter:"+[Nito*]*"')

	# Either display or publish the results
	If ($env:CI -eq 'True')
	{
		iex ((Get-ChildItem ($env:USERPROFILE + '\.k\packages\coveralls.io'))[0].FullName + '\tools\coveralls.net.exe' + ' --opencover coverage.xml --full-sources')
	}
	Else
	{
		iex ((Get-ChildItem ($env:USERPROFILE + '\.k\packages\ReportGenerator'))[0].FullName + '\ReportGenerator.exe -reports:coverage.xml -targetdir:.')
		./index.htm
	}
}
Finally
{
	popd
	$env:KRE_APPBASE = $original_KRE_APPBASE
}