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
[Card]$CardToCast = $Game.Hand[0]
$Game.DrawOpeningHand()

Do
{
    $Game.StartTurn()

    [int]$LandIndex = $Game.SearchZoneForCard("Hand", "SuperType", "*Land")
    If ( $LandIndex -ne -1 )
    {
        $Game.PlayCard($Game.Hand[$LandIndex])
    }

    $Game.EndTurn()
}
Until( $Game.IsCastable($CardToCast) )

Return ,$Game