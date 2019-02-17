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
        Get-ChildItem -Path $Script:DashboardScriptsPath -Recurse | ForEach-Object -Process {
            Write-Verbose -Message "Importing dashboard row $($_.FullName)."
            $UDRows += & $_.FullName -Deck $Deck
        }
        
        New-UDPage -Name $Deck.Name -Icon home -Content { $UDRows }
    }
    
    end 
    {
    }
}