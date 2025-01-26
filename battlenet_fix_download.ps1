# Ensure the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as an administrator!"
    exit 1
}

# Function to uninstall Battle.net
function Uninstall-BattleNet {
    Write-Host "Attempting to uninstall Battle.net..." -ForegroundColor Cyan
    $battleNet = Get-WmiObject -Query "SELECT * FROM Win32_Product WHERE Name LIKE 'Battle.net%'" -ErrorAction SilentlyContinue
    
    if ($battleNet) {
        $battleNet.Uninstall() | Out-Null
        Write-Host "Battle.net has been uninstalled." -ForegroundColor Green
    } else {
        Write-Warning "Battle.net is not installed or could not be found."
    }
}

# Function to remove cached data and residual files
function Remove-BattleNetCachedData {
    Write-Host "Removing cached data and residual files..." -ForegroundColor Cyan

    # Common directories for Battle.net files
    $directories = @(
        "$env:ProgramData\Battle.net",
        "$env:ProgramFiles(x86)\Battle.net",
        "$env:LocalAppData\Battle.net",
        "$env:LocalAppData\Blizzard Entertainment",
        "$env:ProgramFiles\Battle.net"
    )
    
    foreach ($dir in $directories) {
        if (Test-Path $dir) {
            try {
                Remove-Item -Path $dir -Recurse -Force -ErrorAction Stop
                Write-Host "Removed: $dir" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to remove: $dir. $_"
            }
        } else {
            Write-Host "Directory not found: $dir" -ForegroundColor Yellow
        }
    }
}

# Function to reinstall Battle.net
function Reinstall-BattleNet {
    Write-Host "Downloading the latest Battle.net installer..." -ForegroundColor Cyan
    $installerUrl = "https://www.blizzard.com/download/confirmation?product=bnetdesk"
    $downloadPath = "$env:TEMP\BattleNet-Setup.exe"

    try {
        Invoke-WebRequest -Uri $installerUrl -OutFile $downloadPath -UseBasicParsing
        Write-Host "Battle.net installer downloaded to $downloadPath." -ForegroundColor Green
        
        Write-Host "Running the Battle.net installer..." -ForegroundColor Cyan
        Start-Process -FilePath $downloadPath -ArgumentList "/S" -Wait
        Write-Host "Battle.net has been reinstalled." -ForegroundColor Green
    } catch {
        Write-Error "Failed to download or run the installer: $_"
    }
}

# Main execution
Uninstall-BattleNet
Remove-BattleNetCachedData
Reinstall-BattleNet

Write-Host "Battle.net has been reinstalled and its cached data has been cleaned." -ForegroundColor Green
