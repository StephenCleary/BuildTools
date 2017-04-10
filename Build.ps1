dotnet restore
cd src
Get-ChildItem | foreach {
  cd $_
  dotnet pack -c Release --include-symbols
  cd ..
}
cd ..
