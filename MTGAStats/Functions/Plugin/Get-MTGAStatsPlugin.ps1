<#
.Synopsis
   Returns a list of installed plugins.
.DESCRIPTION
   Returns a list of installed plugins.
.PARAMETER Name
    Optional name filter
.EXAMPLE
   Get-MTGAStatsPlugin
.EXAMPLE
   Get-MTGAStatsPlugin -Name "BasicDeckInfo"
#>
function Get-MTGAStatsPlugin
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Position=0)]
        [String]$Name = "*",
        [Switch]$Enabled
    )

    Begin
    {
    }
    Process
    {
        $Global:Plugins | Where-Object -FilterScript { $_.Name -like $Name -and ( $_.Enabled -or !($Enabled))}
    }
    End
    {
    }
}