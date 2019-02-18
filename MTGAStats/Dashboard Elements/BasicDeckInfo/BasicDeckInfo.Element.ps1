using module MTGAStats
param
(
    [Parameter(Mandatory=$true)]    
    [Deck]$Deck
)


$MainDeckData = $Deck.MainDeck | Group-Object -Property Name -NoElement
$SideBoardData = $Deck.Sideboard | Group-Object -Property Name -NoElement

[String]$ProductionLabel = ($Deck.GetManaProduction() | Group-Object).Name
$ProductionData = $Deck.GetManaProduction() | Group-Object

[String]$RequirementsLabel = ($Deck.GetManaColorRequirements() | Group-Object).Name
$RequirementsData = $Deck.GetManaColorRequirements() | Group-Object

New-UDRow {
    New-UDGrid -Title "MainDeck"  -Headers @("Name", "Count") -Properties @("Name", "Count") -FontColor "black" -Endpoint {
        $MainDeckData | Out-UDGridData
    }  

    New-UDGrid -Title "Sideboard"  -Headers @("Name", "Count") -Properties @("Name", "Count") -FontColor "black" -Endpoint {
        $SideBoardData | Out-UDGridData
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