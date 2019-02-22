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
        $Plugins = @()
        $Plugins += Get-MTGAStatsPlugin
        Write-Verbose -Message "Loading plugins for $($Deck.name)"

        Foreach($Plugin in $Plugins)
        {
            #Nested IFs are used to avoid running the test if the plugin is disabled.
            $Settings = Get-MTGAStatsPluginSettings -Name $Plugin.Name
            [Boolean]$Enabled = $Settings.Enabled
            Write-Verbose -Message "Plugin: $($Plugin.Name) Enabled - $($Enabled)"

            If($Enabled)
            {
                [Boolean]$RelevantToDeck = Test-MTGAStatsPluginRelevance -Name $Plugin.Name -Deck $Deck -Verbose
                Write-Verbose -Message "Plugin: $($Plugin.Name) Relevant - $($RelevantToDeck)"
                If ($RelevantToDeck)
                {
                    Get-ChildItem -Path $Plugin.FullName -Recurse -Filter "*.Element.ps1" | ForEach-Object -Process {
                        Write-Verbose -Message "Importing dashboard row $($_.FullName)."
                        $UDRows += & $_.FullName -Deck $Deck -Settings $Settings
                    }
                }
            }
        }
        
        New-UDPage -Name $Deck.Name -Icon home -Content { $UDRows }
    }
    
    end 
    {
    }
}