using module MTGAStats
param
(
    [Deck]$Deck,
    [String]$CardName,
    [Boolean]$OnPlay = $True
)

$Game = [Game]::New($Deck)
$Game.OnPlay = $OnPlay
$Game.tutor($CardName)

[Card]$CardToCast = $Game.Hand.Cards[0]

$Game.DrawOpeningHand()

Do
{
    $Game.StartTurn()

    If($Land = $Game.Hand.Cards | Where-Object -Property SuperType -like "*Land" | Get-Random)
    {
        $Game.BattleField.AddCard($Land)
    }

    $Game.EndTurn()  
}
Until( $Game.BattleField.IsCastable($CardToCast) )

$Game