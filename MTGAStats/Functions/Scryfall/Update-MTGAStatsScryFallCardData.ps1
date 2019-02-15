<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Update-MTGAStatsScryFallCardData
{
    [CmdletBinding()]
    Param
    (
    )

    Begin
    {
    }
    Process
    {
        $CardJSONs = (Invoke-WebRequest -Uri "https://archive.scryfall.com/json/scryfall-default-cards.json" -UseBasicParsing).Content | ConvertFrom-Json
        $CardJSONs.Where({$_.arena_id}) | Export-Clixml -Path $Script:ScryfallDataPath -Force
    }
    End
    {
    }
}