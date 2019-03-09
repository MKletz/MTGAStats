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
      [Boolean]$FilesMissing = (Test-Path -Path ($Global:CardDataPath,$Global:SymbologyDataPath) | Measure-Object -Average).Average -lt 1

      If($Force -or $FilesMissing)
      {
         $Download = $true
      }
      ElseIf($AgeCheck)
      {
         $TimeSinceDataUpdate = New-TimeSpan -Start (Get-Item -Path $Global:CardDataPath).LastWriteTime -End ([datetime]::Now)

         If($TimeSinceDataUpdate.TotalHours -gt $Age)
         {
            $Download = $true
         }
      }
      
      If($Download)
      {
         $CardJSONs = (Invoke-WebRequest -Uri "https://archive.scryfall.com/json/scryfall-default-cards.json" -UseBasicParsing).Content | ConvertFrom-Json
         $CardJSONs.Where({$_.arena_id}) | Export-Clixml -Path $Global:CardDataPath -Force

         $Symbology = Invoke-RestMethod -Uri "https://api.scryfall.com/symbology"
         $Symbology.Data | Export-Clixml -Path $Global:SymbologyDataPath -Force
      }
   }
   End
   {
   }
}