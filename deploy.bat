@echo off
REM Deploy script for Study Deck
REM Usage: deploy.bat

echo === Study Deck - Deploy ===
echo.

REM Build Flutter web
echo [1/2] Building Flutter web...
call flutter build web --release

if %ERRORLEVEL% neq 0 (
    echo Build failed!
    exit /b 1
)

echo Build completed!
echo.

REM Deploy to Firebase
echo [2/2] Deploying to Firebase...
call firebase deploy --only hosting

if %ERRORLEVEL% neq 0 (
    echo Deploy failed!
    exit /b 1
)

echo.
echo === Deploy completed! ===
echo URL: https://studydeck-78bde.web.app
