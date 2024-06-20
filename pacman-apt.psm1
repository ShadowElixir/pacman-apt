# choco -> apt
Set-Alias -Name "apt" choco

# scoop -> pacman
function pacman {
    [CmdletBinding(DefaultParameterSetName='Default')]
    param (
        [Parameter(Mandatory=$true, ParameterSetName='S', Position=0)]
        [Alias('S')]
        [switch]$Install,

        [Parameter(Mandatory=$true, ParameterSetName='R', Position=0)]
        [Alias('R')]
        [switch]$Remove,

        [Parameter(Mandatory=$true, ParameterSetName='Sy', Position=0)]
        [Alias('Sy')]
        [switch]$Upgrade,

        [Parameter(Mandatory=$true, ParameterSetName='Syu', Position=0)]
        [Alias('Syu')]
        [switch]$UpgradeAll,

        [Parameter(Mandatory=$false, Position=1)]
        [string]$PackageName
    )

    switch ($PSCmdlet.ParameterSetName) {
        'S' {
            if ($PackageName) {
                scoop install $PackageName
            } else {
                Write-Host "Package name is required for the '-S' command"
            }
        }
        'R' {
            if ($PackageName) {
                scoop uninstall $PackageName
            } else {
                Write-Host "Package name is required for the '-R' command"
            }
        }
        'Sy' {
            if ($PackageName) {
                scoop update $PackageName
            } else {
                Write-Host "Package name is required for the '-Sy' command"
            }
        }
        'Syu' {
            scoop update *
        }
        default {
            Write-Host "Unsupported pacman command"
        }
    }
}

Export-ModuleMember -Function pacman
Export-ModuleMember -Alias apt
