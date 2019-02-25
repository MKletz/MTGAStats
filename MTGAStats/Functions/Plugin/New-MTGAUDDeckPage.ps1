function New-MTGAUDDeckPage
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory=$true)]    
        [Deck]$Deck
    )
    
    begin
    {
    }
    
    process
    {        
        [UniversalDashboard.Models.Basics.Element[]]$UDRows = @()
        
        Get-MTGAStatsPlugin -Enabled | ForEach-Object -Process {
            If ($_.IsRelevantToDeck($Deck))
            {
                $UDRows += $_.GetUDElement($Deck)
            }
        }
        
        New-UDPage -Name $Deck.Name -Icon home -Content { $UDRows }
    }
    
    end 
    {
    }
}