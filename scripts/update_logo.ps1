# Update App Logo Script

$sourceIcon = "icon.png"
$targetIcon = "assets\icon.png"

# Check if source icon exists
if (-not (Test-Path $sourceIcon)) {
    Write-Host "Error: '$sourceIcon' not found in the current directory." -ForegroundColor Red
    Write-Host "Please place the new icon file named 'icon.png' in the project root." -ForegroundColor Yellow
    exit 1
}

# Ensure assets directory exists
if (-not (Test-Path "assets")) {
    New-Item -ItemType Directory -Path "assets" | Out-Null
}

# Copy icon
Write-Host "Copying $sourceIcon to $targetIcon..." -ForegroundColor Cyan
Copy-Item -Path $sourceIcon -Destination $targetIcon -Force

# Run flutter_launcher_icons
Write-Host "Generating launcher icons..." -ForegroundColor Cyan
flutter pub run flutter_launcher_icons

Write-Host "Done! App logo updated successfully." -ForegroundColor Green
