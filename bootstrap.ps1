$ascii = @"
 _       ___             ____              __       __                 
| |     / (_)___        / __ )____  ____  / /______/ /__________ _____ 
| | /| / / / __ \______/ __  / __ \/ __ \/ __/ ___/ __/ ___/ __ `/ __ \
| |/ |/ / / / / /_____/ /_/ / /_/ / /_/ / /_(__  ) /_/ /  / /_/ / /_/ /
|__/|__/_/_/ /_/     /_____/\____/\____/\__/____/\__/_/   \__,_/ .___/ 
                                                              /_/      
"@

Write-Host $ascii -ForegroundColor Cyan

# Check for Administrator privileges
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$windowsPrincipal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-Not $windowsPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script must be run as Administrator." -ForegroundColor Red
    # Pause to allow the user to read the message
    if ($Host.Name -eq 'ConsoleHost') {
        Write-Host "Press any key to exit..."
        $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
    }
    exit 1
}

# Define apps to install
$appsToInstall = @(
    "cursoride",
    "git",
    "miktex",
    "obsidian",
    "powertoys",
    "protonvpn",
    "protondrive",
    "python",
    "signal",
    "strawberryperl",
    "ungoogled-chromium",
    "uv"
)

function Install-ChocolateyAndApps {
    # Check if Chocolatey is already installed
    if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Chocolatey is not installed. Installing now..." -ForegroundColor Yellow
        # Install Chocolatey
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Chocolatey installation failed. Please check the output above." -ForegroundColor Red
            exit 1 # Exit if Chocolatey installation failed
        } else {
            Write-Host "Chocolatey installed successfully." -ForegroundColor Green
        }
    } else {
        Write-Host "Chocolatey is already installed." -ForegroundColor Green
    }

    $totalApps = $appsToInstall.Count
    $successCount = 0
    $failureCount = 0

    Write-Host "`nStarting app installations..." -ForegroundColor Cyan

    # Install apps
    for ($i = 0; $i -lt $totalApps; $i++) {
        $appName = $appsToInstall[$i]
        $appNumber = $i + 1
        Write-Host "(`"$appNumber`"/`"$totalApps`") Installing '$appName'..." -ForegroundColor Yellow -NoNewline
        
        # Attempt installation and capture output
        $installOutput = choco install $appName -y --force --limit-output --no-progress *>&1

        if ($LASTEXITCODE -eq 0) {
            Write-Host " -> Success!" -ForegroundColor Green
            $successCount++
        } else {
            $installExitCode = $LASTEXITCODE
            # Install failed, print the output
            Write-Host " -> Install failed (`$LASTEXITCODE` = $installExitCode). Output below:" -ForegroundColor Red
            Write-Host "$($installOutput | Out-String)"
            
            # Optionally attempt upgrade if install failed
            Write-Host "Attempting upgrade..." -ForegroundColor Yellow -NoNewline
            $upgradeOutput = choco upgrade $appName -y --force --limit-output --no-progress *>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " -> Upgrade Success!" -ForegroundColor Green
                $successCount++ # Count upgrade as success
            } else {
                 $upgradeExitCode = $LASTEXITCODE
                 Write-Host " -> Upgrade Failed! (`$LASTEXITCODE` = $upgradeExitCode). Output below:" -ForegroundColor Red
                 Write-Host "$($upgradeOutput | Out-String)"
                 # Log the failed app name or add to a list for later review if needed
                 $failureCount++
            }
        }
    }

    # Summary
    Write-Host "`n--------------------" -ForegroundColor Cyan
    Write-Host "Installation Summary:" -ForegroundColor Cyan
    Write-Host "- Total Apps Attempted: $totalApps"
    Write-Host "- Successful: $successCount" -ForegroundColor Green
    Write-Host "- Failed: $failureCount" -ForegroundColor Red
    Write-Host "--------------------" -ForegroundColor Cyan

    if ($failureCount -gt 0) {
        Write-Host "Some installations failed. Please review the output above or check the Chocolatey logs (`$($env:ChocolateyInstall)\logs\chocolatey.log`)." -ForegroundColor Yellow
    } else {
        Write-Host "All apps installed successfully!" -ForegroundColor Green
    }
}

function Invoke-WinUtil {
    Write-Host "Downloading and running WinUtil by ChrisTitus..." -ForegroundColor Yellow
    Invoke-RestMethod https://christitus.com/win | Invoke-Expression
}

function Invoke-MAS {
    Write-Host "Downloading and running Microsoft Activation Scripts..." -ForegroundColor Yellow
    Invoke-RestMethod https://get.activated.win | Invoke-Expression
}

function Show-Header {
    Clear-Host
    Write-Host $ascii -ForegroundColor Cyan
}

function Show-MainMenu {
    Show-Header
    Write-Host "`nPress a number key to run:" -ForegroundColor Cyan
    Write-Host "1. WinUtil (by ChrisTitus)" -ForegroundColor Green
    Write-Host "2. Microsoft Activation Scripts (MAS)" -ForegroundColor Green
    Write-Host "3. Chocolatey & Apps install" -ForegroundColor Green
    Write-Host "0. Exit" -ForegroundColor Yellow
}

function Show-AppConfirmation {
    Show-Header
    Write-Host "`nApps to be installed:" -ForegroundColor Cyan
    Write-Host "===================" -ForegroundColor Cyan
    
    foreach ($app in $appsToInstall) {
        Write-Host "- $app" -ForegroundColor White
    }
    
    Write-Host "`nTotal apps to install: $($appsToInstall.Count)" -ForegroundColor Yellow
    Write-Host "`nPress:" -ForegroundColor Cyan
    Write-Host "Y - Start installation" -ForegroundColor Green
    Write-Host "N - Return to main menu" -ForegroundColor Red
    Write-Host "L - Show detailed app descriptions" -ForegroundColor Yellow
    
    $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $key = $keyInfo.Character.ToString().ToUpper()
    
    switch ($key) {
        "Y" { 
            Write-Host "`nStarting installation..." -ForegroundColor Green
            return $true 
        }
        "L" {
            Show-AppDescriptions
            return Show-AppConfirmation
        }
        "N" { 
            return $false 
        }
        default { 
            return Show-AppConfirmation
        }
    }
}

function Show-AppDescriptions {
    Show-Header
    Write-Host "`nDetailed App Descriptions:" -ForegroundColor Cyan
    Write-Host "=======================" -ForegroundColor Cyan
    
    $descriptions = @{
        "cursoride" = "Modern, native IDE with AI capabilities"
        "git" = "Distributed version control system"
        "miktex" = "TeX/LaTeX document preparation system"
        "obsidian" = "Knowledge base and note-taking application"
        "powertoys" = "Windows system utilities enhancement suite"
        "protonvpn" = "Secure VPN service from Proton"
        "protondrive" = "Secure cloud storage from Proton"
        "python" = "Programming language interpreter"
        "signal" = "Secure messaging application"
        "strawberryperl" = "Perl programming language distribution"
        "ungoogled-chromium" = "Chromium browser without Google integration"
        "uv" = "Python packaging tool and resolver"
    }
    
    foreach ($app in $appsToInstall) {
        $description = $descriptions[$app]
        if ($description) {
            Write-Host "`n- $app" -ForegroundColor Green
            Write-Host "  $description" -ForegroundColor White
        } else {
            Write-Host "`n- $app" -ForegroundColor Green
        }
    }
    
    Write-Host "`nPress any key to return to confirmation..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Display menu and handle selection
do {
    Show-MainMenu
    $keyInfo = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $choice = $keyInfo.Character
    
    # Convert character to string for switch comparison
    switch ($choice.ToString()) {
        "1" { 
            Write-Host "`nSelected: WinUtil"
            Invoke-WinUtil 
        }
        "2" { 
            Write-Host "`nSelected: MAS"
            Invoke-MAS 
        }
        "3" { 
            Write-Host "`nSelected: Chocolatey & Apps"
            if (Show-AppConfirmation) {
                Install-ChocolateyAndApps 
            }
        }
        "0" { 
            Write-Host "`nExiting..." -ForegroundColor Yellow
            exit 0 
        }
    }
} while ($true)
