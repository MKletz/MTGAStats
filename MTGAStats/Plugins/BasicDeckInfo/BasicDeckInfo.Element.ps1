using module MTGAStats
param
(
    [Parameter(Mandatory=$true)]    
    [Deck]$Deck,
    [Parameter(Mandatory=$true)]    
    $Settings
)

$MainDeckData = $Deck.MainDeck | Group-Object -Property Name -NoElement
$SideBoardData = $Deck.Sideboard | Group-Object -Property Name -NoElement

$ProductionData = ($Deck.MainDeck).manaproduction.symbol | Group-Object -NoElement
[String]$ProductionLabel = $ProductionData.Name

$RequirementsData = ($Deck.MainDeck).mana_cost | Where-Object -FilterScript {$_.Colors} | Group-Object -Property symbol
[String]$RequirementsLabel = $RequirementsData.Name

New-UDRow {

    New-UDColumn -Content {
        New-UDGrid -Title "MainDeck"  -Headers @("Name", "Count") -Properties @("Name", "Count") -FontColor "black" -PageSize $MainDeckData.Count -Endpoint {
            $MainDeckData | Out-UDGridData
        }
    } 

    New-UDColumn -Content {
        New-UDGrid -Title "Sideboard"  -Headers @("Name", "Count") -Properties @("Name", "Count") -FontColor "black" -PageSize $SideBoardData.Count -Endpoint {
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