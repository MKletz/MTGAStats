<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MTGAStatsScryFallCardData
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String]$ArenaId
    )

    Begin
    {
    }
    Process
    {
        $Script:CardData.Where({$_.arena_id -eq $ArenaId})
    }
    End
    {
    }
}