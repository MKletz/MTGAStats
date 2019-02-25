<#
.Synopsis
   Downloads card/symbology data from Scryfall. Will download regardless of parameters if files are not present.
.DESCRIPTION
   Downloads card/symbology data from Scryfall. Will download regardless of parameters if files are not present.
.PARAMETER AgeCheck
   Download if data is over a certain age.
.PARAMETER Age
   Age value for AgeCheck in hours. Default is 24.
.PARAMETER Force
   Will refresh data regardless of age. 
.EXAMPLE
   Update-MTGAStatsScryFallCardData -AgeCheck -Age 48
.EXAMPLE
   Update-MTGAStatsScryFallCardData -Force
#>
function Update-MTGAStatsScryFallCardData
{
   [CmdletBinding()]
   Param
   (
      [Switch]$AgeCheck,
      [Int]$Age = 24,
      [Switch]$Force
   )

   Begin
   {
   }
   Process
   {
      [Boolean]$Download = $false
      If($Force -or !(Test-Path -Path ($Script:CardDataPath,$Script:SymbologyDataPath) ) )
      {
         $Download = $true
      }
      Else
      {
         $TimeSinceDataUpdate = New-TimeSpan -Start (Get-Item -Path $Script:CardDataPath).LastWriteTime -End ([datetime]::Now)

         If($TimeSinceDataUpdate.TotalHours -gt $Age)
         {
            $Download = $true
         }
      }
      
      If($Download)
      {
         $CardJSONs = (Invoke-WebRequest -Uri "https://archive.scryfall.com/json/scryfall-default-cards.json" -UseBasicParsing).Content | ConvertFrom-Json
         $CardJSONs.Where({$_.arena_id}) | Export-Clixml -Path $Script:CardDataPath -Force

         Invoke-RestMethod -Uri "https://archive.scryfall.com/json/scryfall-default-cards.json" | Out-File -FilePath -Path $Script:SymbologyDataPath -Force
      }
   }
   End
   {
   }
}