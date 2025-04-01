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

# Define apps to install
$appsToInstall = @(
    "cursoride",
    "git",
    "miktex",
    "obsidian",
    "powertoys"
    "protonvpn",
    "protondrive",
    "python",
    "signal",
    "strawberryperl",
    "ungoogled-chromium",
    "uv"
)

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
