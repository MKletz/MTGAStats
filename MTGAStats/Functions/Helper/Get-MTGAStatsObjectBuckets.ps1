Function Get-MTGAStatsObjectBuckets
{ 
  Param
  (
    [Object[]]$Collection,
    [int]$ResultSize
  )
  Begin
  {
  }
  Process
  {
    [int]$MaxIndex = ($Collection | Measure-Object).Count - 1

    [Object[]]$Returns = @()
    [Int]$ParentIndex = 0
    [Int]$ChildIndex = ($ParentIndex + 1)
    [int]$EndIndex = ($ChildIndex + ($ResultSize - 2))

    If($ResultSize -eq 1)
    {
      $Returns += $Collection
    }
    Else
    {
      Do
      {
          Do
          {
              [Object[]]$Return = @()
              $Return += $Collection[$ParentIndex]
              
              $ChildIndex..$EndIndex | ForEach-Object -Process {
                  $Return += $Collection[$_]
              }
              $Returns += ,$Return

              $ChildIndex++
              [int]$EndIndex = ($ChildIndex + ($ResultSize - 2))
          }
          Until($EndIndex -gt $MaxIndex)

          $ParentIndex++
          $ChildIndex = ($ParentIndex + 1)
          [int]$EndIndex = ($ChildIndex + ($ResultSize - 2))
      }
      Until( $EndIndex -gt $MaxIndex)
  }
    ,$Returns
  }
  End
  {
  }
}