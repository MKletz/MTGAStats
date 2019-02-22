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
        for ($i = 0; $i -lt $Iterations; $i++)
        {
            Write-Verbose -Message "Running simulation $($i)/$($Iterations)" 
            & $Path @SimulationParameters
        }
    }
    
    end 
    {
    }
}