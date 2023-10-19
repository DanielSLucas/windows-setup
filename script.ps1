# Windows Setup Script
# Run this script in PowerShell

# -----------------------------------------------------------------------------
# Self elevate administrative permissions in this script
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Check-Command($cmdname) {
  return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# -----------------------------------------------------------------------------
# Remove a few pre-installed UWP applications
# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
Write-Host "Removing UWP Rubbish..." -ForegroundColor Green

$uwpRubbishApps = @(
  "Disney.37853FC22B2CE",
  "Microsoft.BingNews",
  "Microsoft.GetHelp",
  "Microsoft.Getstarted",
  "Microsoft.MicrosoftSolitaireCollection",
  "Microsoft.MicrosoftOfficeHub",
  "Microsoft.WindowsFeedbackHub",
  "TeamViewer.TeamViewer.Host"
)

foreach ($uwp in $uwpRubbishApps) {
  Get-AppxPackage -Name $uwp | Remove-AppxPackage
}

# -----------------------------------------------------------------------------
# Install WSL
Write-Host ""
Write-Host "Installing WSL..." -ForegroundColor Green
wsl --install

# -----------------------------------------------------------------------------
# Install Winget apps
if (Check-Command -cmdname 'winget') {
  Write-Host "Winget is already installed, skip installation."
}
else {
  Write-Host ""
  Write-Host "Installing Winget for Windows..." -ForegroundColor Green
  $hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
  if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
    Start-Process ms-appinstaller:?source=https://aka.ms/getwinget
    Read-Host -Prompt "Press enter to continue..."
  }
}

Write-Host ""
Write-Host "Installing Windows apps..." -ForegroundColor Green

if (Check-Command -cmdname 'git') {
  Write-Host "Git is already installed, checking new version..."
  winget upgrade --id Git.Git
}
else {
  Write-Host ""
  Write-Host "Installing Git for Windows..." -ForegroundColor Green
  winget install --id Git.Git --override '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /NOCANCEL /SP- /LOG /COMPONENTS="assoc,ext,gitlfs,windowsterminal" /o:PathOption=Cmd'
}

$Apps= @(
  "Discord.Discord",
  "Opera.OperaGX",
  "Valve.Steam",
  "Mojang.MinecraftLauncher",
  "VideoLAN.VLC",
  "RARLab.WinRAR",
  "Nvidia.GeForceExperience",
  "Microsoft.VisualStudioCode",
  "Docker.DockerDesktop"
  "marha.VcXsrv",
  "Microsoft.PowerToys",
  "QL-Win.QuickLook",
  "Microsoft.MouseWithoutBorders"
)

foreach ($app in $Apps) {
  Write-Host "Instalando $app..."
  winget install --id=$app -e --silent
}

# -----------------------------------------------------------------------------
# Enable PUA Protection in Windows Defender
Write-Host "Enabling PUA Protection in Windows Defender" -ForegroundColor Green
Write-Host "------------------------------------" -ForegroundColor Green
Set-MpPreference -PUAProtection 1

# -----------------------------------------------------------------------------
# Install Fira Code Font
Write-Host ""
Write-Host "Installing Fira Code font..." -ForegroundColor Green
./fontInstall.ps1

# -----------------------------------------------------------------------------
# Restart Windows
Write-Host ""
Read-Host -Prompt "Setup is done. Restart is needed, press [ENTER] to restart computer"
Restart-Computer
