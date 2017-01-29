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

$files = @(dir SharedAssemblyInfo.cs -recurse) + @(dir src/*/project.json) + @(dir *.nuspec -recurse)

ForEach($file in $files)
{
    $content = $originalContent = Get-Content $file
    if ($file.FullName.EndsWith(".cs"))
    {
        $content = $content -replace "AssemblyVersion\(`"$shortOldVersion`"\)", "AssemblyVersion(`"$shortNewVersion`")"
        $content = $content -replace "AssemblyFileVersion\(`"$shortOldVersion`"\)", "AssemblyFileVersion(`"$shortNewVersion`")"
        $content = $content -replace "AssemblyInformationalVersion\(`"$oldVersion`"\)", "AssemblyInformationalVersion(`"$newVersion`")"
    }
    else
    {
        $content = $content -replace "$oldVersion", "$newVersion"
    }
    if ([String]::Join("`r`n", $originalContent) -ne [String]::Join("`r`n", $content))
    {
        Set-Content -Value $content -Path $file
        Write-Output "Updated $file"
    }
}

Set-Clipboard ("v" + $newVersion)
Write-Output "Remember to tag!"
