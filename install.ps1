# Ensure the script can run with elevated privileges (code from Christ Titus' powershell profile)
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as an Administrator!"
    break
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
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
} else {
    Write-Host "Scoop is already installed."
}

# Make Scoop downloads faster
scoop install aria2
scoop config aria2-warning-enabled false

# Install the module
irm https://raw.githubusercontent.com/ShadowElixir/pacman-apt/main/pacman-apt.psm1 -outFile "$env:userprofile\Documents\Powershell\Modules\pacman-apt\pacman-apt.psm1"
Write-Output "`nImport-Module `"pacman-apt`"" | Add-Content $PROFILE # Code from gsudo readme, but with "pacman-apt" instead of "gsudoModule"

# gsudo compatibility
scoop install gsudo
Write-Output 'function sudo { gsudo "Import-Module pacman-apt; $args" }' | Add-Content $PROFILE
