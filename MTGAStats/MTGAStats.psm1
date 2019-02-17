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
    $this.type_line = $ScryfallCardData.type_line
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