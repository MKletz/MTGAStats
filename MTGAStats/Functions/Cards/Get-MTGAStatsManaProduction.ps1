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
function Get-MTGAStatsManaProduction
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
        ($Card.color_identity * $Card.Quantity)
    }
    End
    {
    }
}