Start-Job -ScriptBlock { Install-Module -Name "PowerShellGet" -Force } | Wait-Job

Import-Module -Name "PowerShellGet"  -MinimumVersion 2.0.0
Install-Module -Name "UniversalDashboard.Community" -Force -AcceptLicense

[String]$ModulesDir = "C:\Program Files\WindowsPowerShell\Modules"
[String]$ZipPath = "$($ModulesDir)\MTGAStats-Master.zip"
[String]$ExtractPath = "$($ModulesDir)\MTGAStats-Master"
[String]$MTGAStatsPath = "$($ExtractPath)\MTGAStats-Master\MTGAStats"

Invoke-WebRequest -Uri "https://github.com/MKletz/MTGAStats/archive/master.zip" -UseBasicParsing -OutFile $ZipPath

Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath

Move-Item -Path $MTGAStatsPath -Destination $ModulesDir

Remove-Item -Path $ZipPath -Force
Remove-Item -Path $ExtractPath -Recurse -Force