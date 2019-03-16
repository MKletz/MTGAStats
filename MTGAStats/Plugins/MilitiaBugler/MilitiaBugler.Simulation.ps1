using module MTGAStats
param
(
    $Deck,
    [Boolean]$OnPlay = $True,
    [int]$MaxTurn = 15
)

$Game = [Game]::New($Deck)
$Game.OnPlay = $OnPlay
$Game.tutor("Militia Bugler")

$Game.DrawOpeningHand()

#Start on turn 3 since that's when Bugler is likely castable
$Game.StartTurn()
$Game.StartTurn()

$Results = @()

Do
{
    $Result = [PSCustomObject]@{
        Turn = $Game.Turn
        Success = $False
    }
    
    $Game.StartTurn()

    $Game.TopCardsToEffectZone(4)

    If($Hit= $Game.EffectZone.Cards | Where-Object -Property Power -LE -Value 2 | Get-Random)
    {
        $Game.Hand.AddCard($Hit)
        $Game.EmptyEffectZoneToBottom()
        $Result.Success = $True
    }

    $Game.EndTurn()
    
    $Results += $Result
}
Until( $Game.Turn -eq $MaxTurn )

,$Results