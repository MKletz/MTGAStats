<#
.Synopsis
   Gets settings for a given Plugin. These are stored in a *.Settings.JSON file.
.DESCRIPTION
   Gets settings for a given Plugin. These are stored in a *.Settings.JSON file.
.PARAMETER Name
    Name of the PlugIn
.EXAMPLE
   Get-MTGAStatsPluginSettings -Name "BasicDeckInfo"
#>
function Get-MTGAStatsPluginSettings
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true,Position=0)]
        [String]$Name
    )

    Begin
    {
    }
    Process
    {
        [String]$Path = "$($Script:PluginsPath)\$($Name)"
        (Get-ChildItem -Path $Path -Filter "*.Settings.JSON")[0] | Get-Content | ConvertFrom-Json
    }
    End
    {
    }
}