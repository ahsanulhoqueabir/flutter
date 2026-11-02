# Minor release: 1.2.3+4 -> 1.3.0+5
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
dart run scripts/version.dart minor
