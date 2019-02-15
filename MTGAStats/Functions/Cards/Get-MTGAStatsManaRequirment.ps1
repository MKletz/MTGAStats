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
function Get-MTGAStatsManaRequirment
{
    [CmdletBinding()]
    Param
    (
        [parameter(ValueFromPipeline=$True,Mandatory=$True)]
        $Card
    )

    Begin
    {
    }
    Process
    {
        ( ($Card.mana_cost -replace '[^WURBG]') * $Card.Quantity).ToCharArray()
    }
    End
    {
    }
}