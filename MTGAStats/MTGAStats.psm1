[String]$FunctionRoot = Join-Path -Path $PSScriptRoot -ChildPath "Functions" -Resolve
[String]$Script:DataRoot = Join-Path -Path $PSScriptRoot -ChildPath "Data" -Resolve
[String]$Script:ScryfallDataPath = "$($Script:DataRoot)\scryfall-default-cards.xml"

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