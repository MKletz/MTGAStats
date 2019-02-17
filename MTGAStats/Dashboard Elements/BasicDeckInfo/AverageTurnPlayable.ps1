using module MTGAStats
param
(
    [Deck]$Deck,
    [String]$CardName
)

$Game = [Game]::New($Deck)

$Game.tutor($CardName)
[Card]$CardToCast = $Game.hand[0]
$Game.DrawOpeningHand()

[Boolean]$CanPlay = $false

While($CanPlay -eq $false)
{
    $Game.StartTurn()

    If ( $Land = $Game.hand | Where-Object -Property type_line -Like -Value "*Land*" | Get-Random )
    {
        $Game.PlayCard($Land)
    }

    [String[]]$ManaProduction = @()
    [int]$ManaProducers = 0
    $Game.BattleField | ForEach-Object -Process {
        If($Mana = $_.GetManaProduction())
        {
            $ManaProduction += $Mana
            $ManaProducers++
        }
    }

    [System.Collections.ArrayList]$MissingColors = @()
    $MissingColors += Compare-Object -ReferenceObject $ManaProduction -DifferenceObject $CardToCast.GetManaColorRequirements() | Where-Object -Property "SideIndicator" -EQ "=>"

    If( ($ManaProducers -ge $CardToCast.cmc) -and ($MissingColors.count -eq 0))
    {
        $CanPlay = $true
    }
    else
    {
        $Game.EndTurn()
    }  
}

Return ,$Game