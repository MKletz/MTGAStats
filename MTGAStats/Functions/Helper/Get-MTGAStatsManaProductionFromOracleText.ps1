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
function Get-MTGAStatsManaProductionFromOracleText
{
   [CmdletBinding()]
   Param
   (
      [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
      [AllowEmptyString()]
      [String]$OracleText
   )

   Begin
   {
   }
   Process
   {
        [Regex]$ManaAbilityPattern = '{T}: Add {([^.]+)'
        [Regex]$ManaProductionPattern = '{[WURBGC]}'
        [String]$ManaAbility = $ManaAbilityPattern.Match($OracleText)
        Get-MTGAStatsManaSymbolSplit -ManaString $ManaProductionPattern.Matches($ManaAbility)
   }
   End
   {
   }
}