# Major release: 1.2.3+4 -> 2.0.0+5
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
dart run scripts/version.dart major
