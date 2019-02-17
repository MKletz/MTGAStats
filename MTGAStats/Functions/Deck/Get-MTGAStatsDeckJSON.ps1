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
function Get-MTGAStatsDeckJSON
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [String]$OutputLogPath = "$($env:USERPROFILE)\AppData\LocalLow\Wizards Of The Coast\MTGA\output_log.txt"
    )

    Begin
    {
    }
    Process
    {
        $FileStream = New-Object -TypeName "System.IO.FileStream" -ArgumentList ($OutputLogPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
        $StreamReader = New-Object -TypeName "System.IO.StreamReader" -ArgumentList $FileStream
        [Void]$StreamReader.ReadToEnd()
        Write-Verbose -Message "Waiting for deck events to populate in $($OutputLogPath)"

        [String]$DecksRaw = [string]::Empty
        while ($DecksRaw -eq [string]::Empty)
        {
            [String]$CurrentLine = $StreamReader.ReadLine()
            If($CurrentLine -like "<== Deck.GetDeckLists(*)")
            {
                Write-Verbose -Message "Deck events received."
                While($CurrentLine -ne "]")
                {
                    $CurrentLine = $StreamReader.ReadLine()
                    $DecksRaw += $CurrentLine
                }
            }
        }
        $StreamReader.close()

        $DecksRaw | ConvertFrom-Json | ForEach-Object -Process {
            $_
        }
    }
    End
    {
    }
}