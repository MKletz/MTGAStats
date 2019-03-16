Start-Job -ScriptBlock { Install-Module -Name "PowerShellGet" -Force } | Wait-Job

Set-PSRepository -Name "psgallery" -InstallationPolicy Trusted
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

Register-PackageSource -ProviderName "NuGet" -Name "NuGet" -Location "https://www.nuget.org/api/v2" -Trusted
Install-Package -Name "MathNet.Numerics" -Source "NuGet"

[String]$PrivateFunctiondir = "$($ModulesDir)\MTGAStats\Functions\Private"
New-item -Path $PrivateFunctiondir -ItemType Directory | Out-Null
Invoke-WebRequest -Uri https://github.com/RamblingCookieMonster/Invoke-Parallel/blob/master/Invoke-Parallel/Invoke-Parallel.ps1 -OutFile "$($ModulesDir)\MTGAStats\Functions\Private\Invoke-Parallel.ps1"