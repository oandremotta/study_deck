# Deploy script for Study Deck
# Usage: .\deploy.ps1

Write-Host "=== Study Deck - Deploy ===" -ForegroundColor Cyan
Write-Host ""

# Build Flutter web
Write-Host "[1/2] Building Flutter web..." -ForegroundColor Yellow
flutter build web --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "Build completed!" -ForegroundColor Green
Write-Host ""

# Deploy to Firebase
Write-Host "[2/2] Deploying to Firebase..." -ForegroundColor Yellow
firebase deploy --only hosting

if ($LASTEXITCODE -ne 0) {
    Write-Host "Deploy failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== Deploy completed! ===" -ForegroundColor Green
Write-Host "URL: https://studydeck-78bde.web.app" -ForegroundColor Cyan
