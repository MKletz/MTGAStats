function Invoke-MTGAStatsSimulation
{
    [CmdletBinding()]
    param
    (
        [String]$Path,
        [int]$Iterations = 1000,
        [Hashtable]$SimulationParameters
    )
    
    begin
    {
    }
    
    process
    {               
        #Text preceeded by '[[-' and followed by ']'. Example 'TurnPlayable.Simulation.ps1 [[-Deck] <Object>] [[-OnPlay] <bool>] [[-CardName] <string>]' Matches "Deck","OnPlay","CardName"
        [regex]$ParseParameters = "(?<=\[\[-)[A-Za-z0-9]*(?=\])"
        [String]$HelpString = (get-help -Name $Path)
        [String[]]$ParameterNames = ($ParseParameters.Matches( $HelpString ) | Where-Object -Property Value).Value

        $ArgumentList = @()
        $ParameterNames | Foreach-Object -Process {
            $ArgumentList += $SimulationParameters["$($_)"]
        }

        $Jobs = 1..$Iterations | Start-RSJob -FilePath $Path -ArgumentList $SimulationParameters -Throttle 50 -ArgumentList $ArgumentList
        $Jobs | Wait-RSJob
        ,($Jobs | Receive-RSJob)
        $Jobs | Remove-RSJob
    }
    
    end 
    {
    }
}