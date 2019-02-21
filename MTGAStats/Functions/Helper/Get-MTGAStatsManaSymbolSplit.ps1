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
function Get-MTGAStatsManaSymbolSplit
{
   [CmdletBinding()]
   Param
   (
      [Parameter(Mandatory=$true,ValueFromPipeline=$True)]
      [AllowEmptyString()]
      [String]$ManaString
   )

   Begin
   {
   }
   Process
   {
      [Regex]$ManaCostPattern = '{[\w\d]}'
      [String[]]$Symbols = @()
      $Symbols += $ManaCostPattern.matches($ManaString) | Select-Object -ExpandProperty "Value"
      If ( $Symbols.Count -eq 0 )
      {
         [String[]]$Symbols = $ManaString.ToCharArray() | ForEach-Object -Process {
            "{$($_)}"
         }
      }

      $Symbols      
   }
   End
   {
   }
}