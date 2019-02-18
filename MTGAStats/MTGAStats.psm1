[String]$FunctionRoot = Join-Path -Path $PSScriptRoot -ChildPath "Functions" -Resolve
[String]$Script:DataRoot = Join-Path -Path $PSScriptRoot -ChildPath "Data" -Resolve
[String]$Script:ScryfallDataPath = "$($Script:DataRoot)\scryfall-default-cards.xml"
[String]$Script:DashboardScriptsPath = Join-Path -Path $PSScriptRoot -ChildPath "Dashboard Elements" -Resolve

Get-ChildItem -Path $FunctionRoot -Filter "*.ps1" -Recurse | ForEach-Object -Process {
    Write-Verbose -Message "Importing function $($_.FullName)."
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

[System.Collections.ArrayList]$Script:CardData = @()
$Script:CardData += Import-Clixml -Path $Script:ScryfallDataPath

class Card
{
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
    [String]$mana_cost
    [Decimal]$cmc
    [String]$type_line
    [String]$oracle_text
    [String]$power
    [String]$toughness
    [String[]]$colors
    [String[]]$color_identity
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

    [String[]]GetManaProduction()
    {
        If($this.type_line -like "*Land*" -and $this.color_identity)
        {
            Return ($this.color_identity).ToCharArray()
        }
        else {
            Return $null
        }
    }

    [String[]]GetManaColorRequirements()
    {
        Return ($this.mana_cost -replace '[^WURBG]').ToCharArray()
    }
   # Constructors
   Card ([Object]$ScryfallCardData)
   {
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
    $this.mana_cost = $ScryfallCardData.mana_cost
    $this.cmc = $ScryfallCardData.cmc
    $this.type_line = $ScryfallCardData.type_line.Replace('â','-')
    $this.oracle_text = $ScryfallCardData.oracle_text
    $this.power = $ScryfallCardData.power
    $this.toughness = $ScryfallCardData.toughness
    $this.colors = $ScryfallCardData.colors
    $this.color_identity = $ScryfallCardData.color_identity
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
   }
}

class Deck
{
    [String]$name
    [String]$Format
    [Card[]]$MainDeck
    [Card[]]$Sideboard

    [String[]]GetManaProduction()
    {
        [String[]]$ManaProduction = @()
        $this.mainDeck | ForEach-Object -Process {
            $ManaProduction += $_.GetManaProduction()
        }
        Return ($ManaProduction | Where-Object -Filter {$_})
    }

    [String[]]GetManaColorRequirements()
    {
        [String[]]$ManaColorRequirements = @()
        $this.MainDeck | ForEach-Object -Process {
            $ManaColorRequirements += $_.GetManaColorRequirements()
        }
        Return ($ManaColorRequirements | Where-Object -Filter {$_})
    }

    # Constructor
    Deck ([Object]$MTGADeckJson)
   {
        $this.name = $MTGADeckJson.name
        $this.Format = $MTGADeckJson.Format
        $MTGADeckJson.mainDeck | ForEach-Object -Process {
            for ($i = 0; $i -lt $_.Quantity; $i++) {
                $This.MainDeck += [Card]::New( (Get-MTGAStatsScryFallCardData -ArenaId $_.id) )
            }
        }
        $MTGADeckJson.sideboard | ForEach-Object -Process {
            for ($i = 0; $i -lt $_.Quantity; $i++) {
                $This.Sideboard += [Card]::New( (Get-MTGAStatsScryFallCardData -ArenaId $_.id) )
            }
        }
   }
}

class Game
{
    [System.Collections.ArrayList]$Library = @()
    [System.Collections.ArrayList]$Hand = @()
    [System.Collections.ArrayList]$BattleField = @()
    [System.Collections.ArrayList]$EffectZone = @()
    [System.Collections.ArrayList]$Graveyard = @()
    [Boolean]$LandPlayed = $false
    [Deck]$Deck
    [int]$StartingHandSize = 7
    [int]$Turn = 1
    [Boolean]$OnPlay = $True

    # Constructor
    Game([Deck]$Deck)
    {
        $this.Library = $Deck.MainDeck
        $this.Deck = $Deck
        $this.ShuffleLibrary()
    }

    [int]SearchZoneForCard([String]$Zone, [String]$CardProperty, [Object]$CardValue)
    {
        [int]$FoundAt = -1
        for ($Index = 0; $Index -lt $this.$Zone.count; $Index++)
        {
            If($this.$Zone[$Index].$CardProperty -like $CardValue)
            {
                $FoundAt = $Index
                Break
            } 
        }

        Return $FoundAt
    }

    ChangeCardZoneByName([String]$CardName, [String]$From, [string]$Destination)
    {
        [int]$Index = $this.SearchZoneForCard($From, "Name", $CardName)
        $this.ChangeCardZoneByIndex($Index, $From, $Destination)
    }

    ChangeCardZoneByIndex([int]$Index, [String]$From, [string]$Destination)
    {
        If($Index -gt -1)
        {
            $this.$Destination += $this.$From[$Index]
            $this.$From.RemoveAt($Index)
        }
    }

    DrawCard()
    {
        $this.ChangeCardZoneByIndex(0, "Library", "Hand")
    }

    Tutor([String]$CardName)
    {
        $this.ChangeCardZoneByName($CardName, "Library", "Hand")
    }

    DrawOpeningHand()
    {
        While($this.Hand.Count -lt $this.StartingHandSize)
        {
            $this.DrawCard()
        }
    }

    Mulligan()
    {
        $this.StartingHandSize = ($this.Hand.Count - 1)
        $this.Library = $this.Deck
        $this.Hand.Clear()
    }

    PlayCard([Card]$Card)
    {
        If($Card.type_line -like "*Land*")
        {
            $this.LandPlayed = $true
        }

        If($Card.type_line -notlike "*Instant*" -and $Card.type_line -notlike "*sorcery*")
        {
            $this.ChangeCardZoneByName($Card.name, "Hand", "BattleField")
        }
    }

    EndTurn()
    {
        #Just a place holder in case we need it later.
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

    ShuffleLibrary()
    {
        $this.Library = ( $this.Library | Sort-Object -Property { Get-Random } )
    }

    TopCardsToEffectZone([int]$CardCount)
    {
        0..($CardCount - 1) | ForEach-Object -Process {
            $this.ChangeCardZoneByIndex(0, "Library", "EffectZone")
        }
    }

    EmptyEffectZone([String]$Destination)
    {
        $this.$Destination += ( $this.EffectZone | Sort-Object -Property { Get-Random } )
        $this.EffectZone.Clear()
    }

    [Boolean]IsCastable([Card]$Card)
    {
        [String[]]$ManaProduction = @()
        [int]$ManaProducers = 0
        $this.BattleField | ForEach-Object -Process {
            If($Mana = $_.GetManaProduction())
            {
                $ManaProduction += $Mana
                $ManaProducers++
            }
        }

        [System.Collections.ArrayList]$MissingColors = @()
        If($Card.GetManaColorRequirements())
        {
            $MissingColors += Compare-Object -ReferenceObject $ManaProduction -DifferenceObject $Card.GetManaColorRequirements() | Where-Object -Property "SideIndicator" -EQ "=>"
        }
        
        [Boolean]$Castable = $false
        If( ($ManaProducers -ge $Card.cmc) -and ($MissingColors.count -eq 0))
        {
            $Castable = $true
        }

        Return $Castable
    }

    [Boolean]WouldLegendRule([Card]$Card)
    {
        [Boolean]$WouldLegendRule = $false
        [Boolean]$InPlay = $false
        If(SearchZoneForCard("Battlefield", "Name" ,$Card.name) -ne -1)
        {
            $InPlay = $true
        }

        If( $Card.Legendary -and $InPlay)
        {
            $WouldLegendRule = $true
        }

        Return $WouldLegendRule
    }

    [int]GetLandCount()
    {
        Return ($this.Battlefield | Where-Object -Property SuperType -like -Value "*Land" | Measure-Object).Count
    }
}