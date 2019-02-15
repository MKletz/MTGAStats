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
function New-MTGAStatsCard
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String]$ArenaId,

        [Parameter(Mandatory=$true)]
        [Int]$Quantity
    )

    Begin
    {
    }
    Process
    {
        $Card = Get-MTGAStatsScryFallCardData -ArenaId $ArenaId
        $Card | Add-Member -MemberType NoteProperty -Name 'Quantity' -Value $Quantity -Force
        $Card
    }
    End
    {
    }
}