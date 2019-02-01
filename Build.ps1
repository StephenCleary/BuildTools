Function WriteAndExecute([string]$command) {
	Write-Output $command
	Invoke-Expression $command
}

WriteAndExecute 'dotnet restore'
Push-Location
try {
    Get-ChildItem 'src' | ForEach-Object {
        $location = $_.FullName
        Write-Output "Entering $location"
        Set-Location $location
        WriteAndExecute 'dotnet pack -c Release --no-restore'
    }
} finally { Pop-Location }
