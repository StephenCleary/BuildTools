if (($oldVersion -eq "") -or ($newVersion -eq ""))
{
    throw [InvalidOperationException] "Pass the current version and the new version numbers to this script."
}

$oldVersionPreIndex = $oldVersion.IndexOf("-");
if ($oldVersionPreIndex -eq -1)
{
    $shortOldVersion = $oldVersion;
}
else
{
    $shortOldVersion = $oldVersion.Substring(0, $oldVersionPreIndex);
}

$newVersionPreIndex = $newVersion.IndexOf("-");
if ($newVersionPreIndex -eq -1)
{
    $shortNewVersion = $newVersion;
}
else
{
    $shortNewVersion = $newVersion.Substring(0, $newVersionPreIndex);
}

$files = (dir *assemblyinfo.cs) + (dir src/*/project.json) + (dir **/*.nuspec)

ForEach($file in $files)
{
    $originalContent = [String]::Join("`r`n", (Get-Content $file))
    $content = $originalContent.Replace($oldVersion, $newVersion)
    if ($shortOldVersion -ne $shortNewVersion)
    {
        $content = $content.Replace($shortOldVersion, $shortNewVersion)
    }
    if ($originalContent -ne $content)
    {
        Set-Content -Value $content -Path $file
        Write-Output "Updated $file"
    }
}

Set-Clipboard ("v" + $newVersion)
Write-Output "Remember to tag!"
