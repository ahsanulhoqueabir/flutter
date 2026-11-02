# Release build with automatic version bump. Example: .\scripts\build.ps1 appbundle --env prod
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
dart run scripts/build.dart @args
exit $LASTEXITCODE
