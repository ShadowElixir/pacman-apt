# Ensure the script can run with elevated privileges (code from Christ Titus' powershell profile)
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
}

# Makes profile if it doesn't exist
if (-not (Test-Path -Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force
}

# Choco install (code from Christ Titus' powershell profile)
try {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}
catch {
    Write-Error "Failed to install Chocolatey. Error: $_"
}

# Scoop install
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Scoop is not installed. Installing Scoop..."
    iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
} else {
    Write-Host "Scoop is already installed."
}

# Make Scoop downloads faster
scoop install aria2
scoop config aria2-warning-enabled false

# Add extras bucket to scoop
scoop install git
scoop bucket add extras

# Make sure Module folders exist
New-Item -ItemType Directory -Force -Path "$env:userprofile\Documents\Powershell\Modules\pacman-apt" -erroraction 'silentlycontinue'
New-Item -ItemType Directory -Force -Path "$env:userprofile\Documents\WindowsPowerShell\Modules\pacman-apt" -erroraction 'silentlycontinue'

# Install the module
irm https://raw.githubusercontent.com/ShadowElixir/pacman-apt/main/pacman-apt.psm1 -outFile "$env:userprofile\Documents\Powershell\Modules\pacman-apt\pacman-apt.psm1" -erroraction 'silentlycontinue'
irm https://raw.githubusercontent.com/ShadowElixir/pacman-apt/main/pacman-apt.psm1 -outFile "$env:userprofile\Documents\WindowsPowerShell\Modules\pacman-apt\pacman-apt.psm1" -erroraction 'silentlycontinue'

# gsudo compatibility
scoop install gsudo

# Add to Profile
$commands = @(
    'Import-Module "pacman-apt"',
    'Import-Module "gsudoModule"',
    'function sudo { gsudo "Import-Module pacman-apt; $args" }'
)

$profileContent = Get-Content $PROFILE -Raw

foreach ($command in $commands) {
    if ($profileContent -notmatch [regex]::Escape($command)) {
        Write-Output $command | Add-Content $PROFILE
    }
}
