using module MTGAStats
param
(
    [Parameter(Mandatory=$true)]    
    $Deck,
    [Parameter(Mandatory=$true)]    
    $Settings
)

$Properties = @(
    "Name",
    "Count",
    @{
        Name = 'Opener'
        Expression = {
            $Percentage = (1 - [MathNet.Numerics.Distributions.Hypergeometric]::CDF($Deck.MainDeck.Count,$_.Count,7,0)) * 100
            "$([Math]::Round($Percentage,2))%"
        }
    },
    @{
        Name = 'OnCurve'
        Expression = {
            $Play = (1 - [MathNet.Numerics.Distributions.Hypergeometric]::CDF($Deck.MainDeck.Count,$_.Count, (7 + $_.group[0].cmc),0)) * 100
            $Draw = (1 - [MathNet.Numerics.Distributions.Hypergeometric]::CDF($Deck.MainDeck.Count,$_.Count, (8 + $_.group[0].cmc),0)) * 100
            "$([Math]::Round($Play,2))%/$([Math]::Round($Draw,2))%"
        }
    }
)

$MainDeckData = $Deck.MainDeck | Group-Object -Property Name | Select-Object -Property $Properties
$SideBoardData = $Deck.Sideboard | Group-Object -Property Name | Select-Object -Property $Properties
[String[]]$DeckHeaders = @("Name", "Count", "Opener", "On Curve P/D")
[String[]]$Properties = @("Name", "Count", "Opener", "OnCurve")

$ProductionData = (($Deck.MainDeck).manaproduction) | Group-Object -NoElement
[String]$ProductionLabel = $ProductionData.Name

$RequirementsData = (($Deck.MainDeck).mana_cost) | Where-Object -FilterScript {$_.Colors} | Group-Object -Property symbol -NoElement
[String]$RequirementsLabel = $RequirementsData.Name

New-UDRow {

    New-UDColumn -Content {
        New-UDGrid -Title "MainDeck - $($Deck.MainDeck.Count)"  -Headers $DeckHeaders -Properties $Properties -FontColor "black" -PageSize $MainDeckData.Count -Endpoint {
            $MainDeckData | Out-UDGridData
        }
    } 

    New-UDColumn -Content {
        New-UDGrid -Title "Sideboard - $($Deck.Sideboard.Count)"  -Headers $DeckHeaders -Properties $Properties -FontColor "black" -PageSize $SideBoardData.Count -Endpoint {
            $SideBoardData | Out-UDGridData
        }
    }

    New-UDColumn -Content {
        New-UDChart -Type Pie -Labels $ProductionLabel -Title "Mana Production" -Endpoint {
            $ProductionData | Out-UDChartData -DataProperty Count -LabelProperty Name
        }
    }

    New-UDColumn -Content {
        New-UDChart -Type Pie -Labels $RequirementsLabel -Title "Mana Requirements" -Endpoint {
            $RequirementsData | Out-UDChartData -DataProperty Count -LabelProperty Name
        }
    }
}