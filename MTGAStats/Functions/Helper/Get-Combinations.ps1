Function Get-Combinations {
  <#
    .Synopsis
      Generates combinations from an array of multi-dimensional arrays
    .Description
      Get-Combinations is a recursive function designed to return combination sets from defined arrays. All arrays are passed as a single parameter.
    .Parameter Object
      The multi-dimensional input array. All elements within the array are cast to System.String.
    .Parameter Seperator
      Joins each element using the specified character.
    .Parameter CurIndex
      The current outer-array index, used in recursion.
    .Parameter Return
      A composite return value, used in recursion.
    .Example
      Get-Combinations @($Array1, $Array2, $Array3)
    .Example
      Get-Combinations @("site", @("web", "app"), @("01", "02"))
  #>    
  Param
  (
    [Object[]]$Object,
    [String]$Seperator,
    [UInt32]$CurIndex = 0,
    [String]$Return = [String]::Empty
  )
  Begin
  {
  }
  Process
  {
    [int]$MaxIndex = ($Object.Count - 1)

    $Object[$CurIndex] | ForEach-Object -Process {
      
      [Array]$NewReturn = "$($Return)$($Seperator)$($_)".Trim($Seperator)
      
      If ($CurIndex -lt $MaxIndex) {
        $NewReturn = Get-Combinations $Object -CurIndex ($CurIndex + 1) -Return $NewReturn
      }

      $NewReturn
    }
  }
  End
  {
  }
  }