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

# Main execution
Uninstall-BattleNet
Remove-BattleNetCachedData

Write-Host "Battle.net and its cached data have been removed." -ForegroundColor Green
