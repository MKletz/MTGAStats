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
        [String]$Name = "*"
    )

    Begin
    {
    }
    Process
    {
        [String]$Path = "$($Script:PluginsPath)"

        Get-ChildItem -Path $Path -Directory -Filter $Name | Select-Object -Property Name,FullName
    }
    End
    {
    }
}