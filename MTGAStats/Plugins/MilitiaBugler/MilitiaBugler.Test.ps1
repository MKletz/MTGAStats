using module MTGAStats
param
(
    [Parameter(Mandatory=$true)]    
    $Deck
)

If( $Deck.Maindeck | Where-Object -FilterScript {$_.Name -eq "Militia Bugler"} )
{
    $True
}
Else
{
    $False
}