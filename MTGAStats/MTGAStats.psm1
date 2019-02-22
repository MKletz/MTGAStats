﻿[String]$FunctionRoot = Join-Path -Path $PSScriptRoot -ChildPath "Functions" -Resolve
[String]$Script:DataRoot = Join-Path -Path $PSScriptRoot -ChildPath "Data" -Resolve
[String]$Script:ScryfallDataPath = "$($Script:DataRoot)\scryfall-default-cards.xml"
[String]$Script:ScryfallSymbology = "$($Script:DataRoot)\Symbology.json"
[String]$Script:PluginsPath = Join-Path -Path $PSScriptRoot -ChildPath "Plugins" -Resolve

Get-ChildItem -Path $FunctionRoot -Filter "*.ps1" -Recurse | ForEach-Object -Process {
    . $_.FullName | Out-Null
}

If(!(Test-Path -Path $Script:ScryfallDataPath))
{
    Write-Verbose -Message "Card data not found. Downloading from Scryfall."
    Update-MTGAStatsScryFallCardData
}
Else
{
    $TimeSinceDataUpdate = New-TimeSpan -Start (Get-Item -Path $Script:ScryfallDataPath).LastWriteTime -End ([datetime]::Now)
    If($TimeSinceDataUpdate.TotalHours -gt 24)
    {
        Write-Verbose -Message "Card data is old. Downloading from Scryfall."
        Update-MTGAStatsScryFallCardData
    }
}

[System.Collections.ArrayList]$Global:CardData = @()
$Global:CardData += Import-Clixml -Path $Script:ScryfallDataPath

[System.Collections.ArrayList]$Global:Symbology = @()
$Global:Symbology += Get-Content -Path $Script:ScryfallSymbology | ConvertFrom-Json | Select-Object -ExpandProperty data

class Symbol
{
    [String]$symbol
    [String]$loose_variant
    [String]$english
    [Boolean]$transposable
    [Boolean]$represents_mana
    [Boolean]$appears_in_mana_costs
    [int]$cmc
    [Boolean]$funny
    [String[]]$colors
    [String[]]$gatherer_alternates

    [String]ToString()
    {
        Return $this.symbol
    }

    [Boolean]CanPayFor([Symbol]$Symbol)
    {
        [Boolean]$CanPayFor = $False
        
        $LikeColors = Compare-Object -ReferenceObject $this.colors -DifferenceObject $Symbol.colors -IncludeEqual -ExcludeDifferent
        If($this.cmc -ge $Symbol.cmc -and $LikeColors)
        {
            $CanPayFor = $True
        }

        Return $CanPayFor
    }

    #Constructor
    Symbol([String]$Symbol)
    {
        If( $ScryfallData = $Global:Symbology.Where({ $_.Symbol -eq $Symbol.Trim() }) )
        {
            $this.symbol = $ScryfallData.symbol
            $this.loose_variant = $ScryfallData.loose_variant
            $this.english = $ScryfallData.english
            $this.transposable = $ScryfallData.transposable
            $this.represents_mana = $ScryfallData.represents_mana
            $this.appears_in_mana_costs = $ScryfallData.appears_in_mana_costs
            $this.cmc = $ScryfallData.cmc
            $this.funny = $ScryfallData.funny
            $this.colors = $ScryfallData.colors
            $this.gatherer_alternates = $ScryfallData.gatherer_alternates
        }
        Else
        {
            throw "No symbology data found for $($Symbol)"    
        }
    }
}

class Card
{
    #region Parameters
    [String]$id
    [String]$oracle_id
    [Int32]$mtgo_id
    [Int32]$arena_id
    [Int32]$tcgplayer_id
    [String]$name
    [String]$lang
    [String]$released_at
    [String]$uri
    [String]$scryfall_uri
    [String]$layout
    [Boolean]$highres_image
    [Symbol[]]$mana_cost
    [int]$cmc
    [String]$type_line
    [String]$oracle_text
    [String]$power
    [String]$toughness
    [String]$colors
    [String]$color_identity
    [Boolean]$reserved
    [Boolean]$foil
    [Boolean]$nonfoil
    [Boolean]$oversized
    [Boolean]$promo
    [Boolean]$reprint
    [String]$set
    [String]$set_name
    [String]$set_uri
    [String]$set_search_uri
    [String]$scryfall_set_uri
    [String]$rulings_uri
    [String]$prints_search_uri
    [String]$collector_number
    [Boolean]$digital
    [String]$rarity
    [String]$flavor_text
    [String]$illustration_id
    [String]$artist
    [String]$border_color
    [String]$frame
    [String]$frame_effect
    [Boolean]$full_art
    [Boolean]$story_spotlight
    [Int32]$edhrec_rank

    [string]$SuperType
    [String]$SubType
    [Boolean]$Legendary = $False
    [String[]]$SplitNames
    [Zone]$Zone
    [int]$ZoneId 
    [Symbol[]]$ManaProduction
    #endregion
    [Card[]]Split()
    {
        [Card[]]$Return = @()

        If( $this.layout -eq "Split" -or $this.layout -eq "Flip" )
        {
            $Return += [Card]::new($this)
            $Return += [Card]::new($this)

            ("name", "mana_cost", "type_line", "SuperType") | ForEach-Object -Process {
                [String[]]$Split =  ($this.$_ -split " // ")
                $Return[0].$_ = $Split[0]
                $Return[1].$_ = $Split[1]
            }
        }
        Else
        {
            $Return += $this
        }

        Return $Return
    }

   # Constructors
   Card ([String]$ArenaId)
    {
        Try
        {
            $ScryfallCardData = $Global:CardData.Where({$_.arena_id -eq $ArenaId})
        }
        Catch
        {
            throw "Card data not found for arenaID $($_.arena_id)"
        }
        #Direct from Scryfall
        $this.id = $ScryfallCardData.id
        $this.oracle_id = $ScryfallCardData.oracle_id
        $this.mtgo_id = $ScryfallCardData.mtgo_id
        $this.arena_id = $ScryfallCardData.arena_id
        $this.tcgplayer_id = $ScryfallCardData.tcgplayer_id
        $this.name = $ScryfallCardData.name
        $this.lang = $ScryfallCardData.lang
        $this.released_at = $ScryfallCardData.released_at
        $this.uri = $ScryfallCardData.uri
        $this.scryfall_uri = $ScryfallCardData.scryfall_uri
        $this.layout = $ScryfallCardData.layout
        $this.highres_image = $ScryfallCardData.highres_image
        $this.cmc = $ScryfallCardData.cmc
        $this.type_line = $ScryfallCardData.type_line.Replace('â','-')
        $this.oracle_text = $ScryfallCardData.oracle_text
        $this.power = $ScryfallCardData.power
        $this.toughness = $ScryfallCardData.toughness
        $this.reserved = $ScryfallCardData.reserved
        $this.foil = $ScryfallCardData.foil
        $this.nonfoil = $ScryfallCardData.nonfoil
        $this.oversized = $ScryfallCardData.oversized
        $this.promo = $ScryfallCardData.promo
        $this.reprint = $ScryfallCardData.reprint
        $this.set = $ScryfallCardData.set
        $this.set_name = $ScryfallCardData.set_name
        $this.set_uri = $ScryfallCardData.set_uri
        $this.set_search_uri = $ScryfallCardData.set_search_uri
        $this.scryfall_set_uri = $ScryfallCardData.scryfall_set_uri
        $this.rulings_uri = $ScryfallCardData.rulings_uri
        $this.prints_search_uri = $ScryfallCardData.prints_search_uri
        $this.collector_number = $ScryfallCardData.collector_number
        $this.digital = $ScryfallCardData.digital
        $this.rarity = $ScryfallCardData.rarity
        $this.flavor_text = $ScryfallCardData.flavor_text
        $this.illustration_id = $ScryfallCardData.illustration_id
        $this.artist = $ScryfallCardData.artist
        $this.border_color = $ScryfallCardData.border_color
        $this.frame = $ScryfallCardData.frame
        $this.frame_effect = $ScryfallCardData.frame_effect
        $this.full_art = $ScryfallCardData.full_art
        $this.story_spotlight = $ScryfallCardData.story_spotlight
        $this.edhrec_rank = $ScryfallCardData.edhrec_rank

        #Calculated properties
        $this.SuperType = ($this.type_line -split "-")[0].Trim()
        If( $this.type_line.Contains("-") )
        {
            $this.SubType = ($this.type_line -split "-")[1].Trim()
        }
        If($this.SuperType -like "Legendary *")
        {
            $this.Legendary = $True
        }
        $this.SplitNames = ($this.name -split " // ")

        $this.ManaProduction = Get-MTGAStatsManaProductionFromOracleText -OracleText $ScryfallCardData.oracle_text
        $this.mana_cost = Get-MTGAStatsManaSymbolSplit -ManaString $ScryfallCardData.mana_cost
        $this.colors = $ScryfallCardData.colors
        $this.color_identity = $ScryfallCardData.color_identity
    }
}

class Deck
{
    [String]$name
    [String]$Format
    [Card[]]$MainDeck
    [Card[]]$Sideboard

    # Constructor
    Deck ([Object]$MTGADeckJson)
   {
        $this.name = $MTGADeckJson.name
        $this.Format = $MTGADeckJson.Format
        $MTGADeckJson.mainDeck | ForEach-Object -Process {
            for ($i = 0; $i -lt $_.Quantity; $i++) {
                $This.MainDeck += [Card]::New($_.id)
            }
        }
        $MTGADeckJson.sideboard | ForEach-Object -Process {
            for ($i = 0; $i -lt $_.Quantity; $i++) {
                $This.Sideboard += [Card]::New($_.id)
            }
        }
   }
}

class Zone
{
    [String]$Name
    [System.Collections.ArrayList]$Cards = @()

    [int]Count()
    {
        Return $this.Cards.count 
    }

    [int]GetNewId()
    {
        Return ($this.Cards | Measure-Object -Property ZoneId -Maximum).Maximum + 1
    }

    RemoveCard([Card]$Card)
    {
        [int]$Index = [Array]::IndexOf( ($this.Cards).ZoneId , $Card.ZoneId ) 
        $this.Cards.RemoveAt($Index)
    }

    AddCard([Card]$Card)
    {
        [Card]$Copy = [Card]::new($Card.arena_id)
        $Copy.ZoneId = $this.GetNewId()
        $Copy.Zone = $this
        $this.Cards += $Copy

        If( $Card.Zone )
        {
            $Card.Zone.RemoveCard($Card)
        }
    }

    Shuffle()
    {
        $this.Cards = ( $this.Cards | Sort-Object -Property { Get-Random } )
    }

    [Card]GetCardByName([String]$Name)
    {
        [Int]$Index = [Array]::IndexOf( ($this.Cards).Name,  $Name)
        
        If($Index -ne -1)
        {
            $Return = $this.Cards[$Index]
        }
        Else
        {
            $Return = $null
        }

        Return $Return
    }

    [Object[]]GetManaPermutations()
    {
        $CharacterSets = @()
        $CharacterSets += $this.Cards | Where-Object -FilterScript { $_.ManaProduction } | ForEach-Object -Process {
            ,@(($_.ManaProduction).symbol)
        }

        If($CharacterSets.Count -eq 0)
        {
            Return $null
        }

        [String[]]$StringCombinations = @()
        $StringCombinations += Get-Combinations -Object $CharacterSets

        $SymbolCombinations = @()
        $StringCombinations | ForEach-Object -Process {
            [Symbol[]]$Combination = @()
            Get-MTGAStatsManaSymbolSplit -ManaString $_ | ForEach-Object -Process {
                $Combination += [symbol]::new($_)
            }
            $SymbolCombinations += ,$Combination
        }

        Return $SymbolCombinations
    }

    [Boolean]IsCastable([Card]$Card)
    {
        $Permutations = $this.GetManaPermutations()

        [Boolean]$Castable = $false
        
        Foreach($Permutation in $Permutations)
        {
            [Boolean]$CMCCheck = (($Permutation).cmc | Measure-Object -Sum).Sum -ge $Card.cmc
            [Boolean]$ColorCheck = $False
            If($CMCCheck)
            {
                If( $NeededColors = $Card.mana_cost | Where-Object -FilterScript { $_.Colors } )
                {
                    $CompareSplat = @{
                        ReferenceObject = $NeededColors
                        DifferenceObject = $Permutation
                        Property = "Symbol"
                    }
                    If (!(Compare-Object @CompareSplat | Where-Object -Property SideIndicator -EQ -Value "<="))
                    {
                        $ColorCheck = $true
                    }
                }
                else
                {
                    $ColorCheck = $true    
                }
            }

            If($CMCCheck -and $ColorCheck)
            {
                $Castable = $true
                Break
            }
        }

        Return $Castable
    }

    # Constructor
    Zone([String]$Name)
    {
        $this.Name = $Name
    }
}

class Game
{
    [Zone]$Library = [Zone]::new("Library")
    [Zone]$Hand = [Zone]::new("Hand")
    [Zone]$BattleField = [Zone]::new("BattleField")
    [Zone]$EffectZone = [Zone]::new("EffectZone")
    [Zone]$Graveyard = [Zone]::new("Graveyard")

    [Boolean]$LandPlayed = $false
    [Deck]$Deck
    [int]$StartingHandSize = 7
    [int]$Turn = 0
    [Boolean]$OnPlay = $True

    LoadDeck([Deck]$Deck)
    {
        #This is really slow and likely means AddCard is slow from cloning objects.
        $this.Library.Cards.Clear()
        $Deck.MainDeck | ForEach-Object -Process {
            $this.Library.AddCard($_)
        }

        $this.Library.Shuffle()
    }

    DrawCard()
    {
        $this.Hand.AddCard($this.Library.Cards[0])
    }

    DrawOpeningHand()
    {
        While($this.Hand.Count() -lt $this.StartingHandSize)
        {
            $this.DrawCard()
        }
    }

    Mulligan()
    {
        $this.Hand.Cards.Clear()
        $this.StartingHandSize = ($this.Hand.Count - 1)
        $this.LoadDeck($this.Deck)
        $this.DrawOpeningHand()
    }

    Tutor([String]$CardName)
    {
        $this.Hand.AddCard( $this.Library.GetCardByName($CardName) )
        $this.Library.Shuffle()
    }

    StartTurn()
    {
        $this.Turn++

        If( !($this.turn -eq 1 -and $this.OnPlay) )
        {
            $this.DrawCard()
        }

        $this.LandPlayed = $false
    }

    EndTurn()
    {
        #Just a place holder in case we need it later.
    }

    [int]GetLandCount()
    {
        Return ($this.Battlefield.Cards | Where-Object -Property SuperType -like -Value "*Land" | Measure-Object).Count
    }

    # Constructor
    Game([Deck]$Deck)
    {
        $this.Deck = $Deck
        $this.LoadDeck($Deck)
    }
}