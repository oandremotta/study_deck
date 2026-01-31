#!/bin/bash
# Deploy script for Study Deck
# Usage: ./deploy.sh

echo "=== Study Deck - Deploy ==="
echo ""

# Build Flutter web
echo "[1/2] Building Flutter web..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Build completed!"
echo ""

# Deploy to Firebase
echo "[2/2] Deploying to Firebase..."
firebase deploy --only hosting

if [ $? -ne 0 ]; then
    echo "Deploy failed!"
    exit 1
fi

echo ""
echo "=== Deploy completed! ==="
echo "URL: https://studydeck-78bde.web.app"
