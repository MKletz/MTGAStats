using module MTGAStats
param
(
    [Parameter(Mandatory=$true)]    
    [Deck]$Deck,
    [Parameter(Mandatory=$true)]    
    $Settings
)
$ChartData = @()

$Deck.MainDeck | Where-Object -FilterScript {$_.CMC -gt 0 -and $_.layout -eq "normal"} | Select-Object -Property Name -Unique | ForEach-Object -Process {
    $SimulationSplat = @{ 
        Path = "D:\gitHub\MTGAStats\MTGAStats\Simulations\TurnPlayable.Simulation.ps1"
        Iterations = [int]$Settings.Iterations
        SimulationParameters = @{
            Deck = $Deck
            CardName = $_.name
        }
    }
    $Results = Invoke-MTGAStatsSimulation @SimulationSplat

    $ChartData += [pscustomobject]@{
        Name = $_.name
        AverageTurn = ($Results.Turn | Measure-Object -Average).Average
        AverageLands = ($Results | ForEach-Object -Process {$_.GetLandCount()} | Measure-Object -Average).Average
    }
}

New-UDRow {
    New-UDColumn -Content {
        New-UDGrid -Title "Average Turn Castable" -Headers @("Name", "Turn", "Land Count") -Properties @("Name", "AverageTurn", "AverageLands") -FontColor "black" -Endpoint {
            $ChartData | Out-UDGridData
        } 
    }
}