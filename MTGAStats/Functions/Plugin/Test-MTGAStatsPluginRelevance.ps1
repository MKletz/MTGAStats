<#
.Synopsis
   Runs 
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Test-MTGAStatsPluginRelevance
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Name,

        [Parameter(Mandatory=$true,Position=1)]
        [Deck]$Deck
    )

    Begin
    {
    }
    Process
    {
        [String]$Path = "$($Script:PluginsPath)\$($Name)"
        
        Get-ChildItem -Path $Path -Filter "*.Test.ps1" | ForEach-Object -Process {
            Write-Verbose -Message "Running test: $($_.FullName)"
            & $_.FullName -Deck $Deck
        }
    }
    End
    {
    }
}