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
function ConvertFrom-MTGAStatsDeckJSON
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [parameter(ValueFromPipeline=$True,Mandatory=$True)]
        $Deck
    )

    Begin
    {
    }
    Process
    {
        Write-Verbose -Message "Converting $($Deck.Name)"
        [String[]]$ManaProduction = @()
        [String[]]$ManaRequirements = @()
        
        [System.Collections.ArrayList]$MainDeck = @()
        $Deck.mainDeck | ForEach-Object -Process {
            $Card = New-MTGAStatsCard -ArenaId $_.id -Quantity $_.quantity
            $MainDeck += $Card
            
            If($Card.type_line -Like "*Land*")
            {
                $ManaProduction += Get-MTGAStatsManaProduction -Card $Card
            }
            Else
            {
                $ManaRequirements += Get-MTGAStatsManaRequirment -Card $Card
            }
        }

        [System.Collections.ArrayList]$Sideboard = @()
        $Deck.sideboard | ForEach-Object -Process {
            $Sideboard += New-MTGAStatsCard -ArenaId $_.id -Quantity $_.quantity
        }

        [PSCustomObject]@{
            Name = $Deck.name
            Format = $Deck.format
            MainDeck = $MainDeck
            SideBoard = $Sideboard
            ManaProduction = $ManaProduction
            ManaRequirements = $ManaRequirements
        }
    }
    End
    {
    }
}