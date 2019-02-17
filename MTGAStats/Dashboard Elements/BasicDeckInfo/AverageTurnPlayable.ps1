using module MTGAStats
param
(
    [Deck]$Deck,
    [String]$CardName,
    [Boolean]$CardInOpeningHand = $true,
    [int]$StartingHandSize = 7,
    [Boolean]$OnPlay = $true
)

[int]$TurnCount = 1
[System.Collections.ArrayList]$Library = $Deck.MainDeck
[System.Collections.ArrayList]$Hand = @()
[System.Collections.ArrayList]$Lands = @()

[Boolean]$CanPlay = $false
[Boolean]$CardDrawn = $false
[Card]$CardToCast = $Deck.MainDeck | Where-Object -Property "Name" -EQ -Value $CardName | Select-Object -First 1

If($CardInOpeningHand)
{
    $StartingHandSize--
    for ($i = 0; $i -lt ($Library.Count -1); $i++) {
        If($Hand.Count -eq 0 -and $Library[$i].name -eq $CardName)
        {
            $Hand += $Library[$i]
            $Library.RemoveAt($i)
        }
    }
}
1..$StartingHandSize | ForEach-Object -Process {
    [int]$DeckIndex = Get-Random -Minimum 0 -Maximum ($Library.Count -1)
    $Hand += $Library[$DeckIndex]
    $Library.RemoveAt($DeckIndex)
}

While($CanPlay -eq $false)
{
    [Boolean]$PlayedLand = $false

    If( !($OnPlay -and $TurnCount -eq 1) )
    {
        $Index = Get-Random -Minimum 0 -Maximum ($Library.Count -1)
        $Hand += $Library[$Index]
        $Library.RemoveAt($Index)
    }

    for ($i = 0; $i -lt $Hand.Count; $i++)
    {
        If(!$PlayedLand -and $Hand[$i].type_line -like "*Land*" )
        {
            $Lands += $Hand[$i]
            $Hand.RemoveAt($i)
            $PlayedLand = $true

        }
    }

    [String[]]$ManaProduction = @()
    $Lands | ForEach-Object -Process {
        $ManaProduction += $_.GetManaProduction()
    }

    [System.Collections.ArrayList]$MissingColors = @()
    $MissingColors += Compare-Object -ReferenceObject $ManaProduction -DifferenceObject $CardToCast.GetManaColorRequirements() | Where-Object -Property "SideIndicator" -EQ "=>"

    $CardDrawn = ($Hand).Name -contains $CardToCast.name

    If( ($Lands.Count -ge $CardToCast.cmc) -and ($MissingColors.count -eq 0) -and $CardDrawn )
    {
        $CanPlay = $true
    }
    else
    {
        $TurnCount++
    }  
}

[PSCustomObject]@{
    Turn = $TurnCount
    LandsInPlay = $Lands.Count
}