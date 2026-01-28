#!/bin/bash

# Build and run WhisperType

set -e

echo "Building WhisperType..."
xcodebuild -scheme WhisperType -configuration Debug build

echo ""
echo "Build successful!"
echo ""
echo "Running WhisperType..."

# Find the built app
APP_PATH="$(xcodebuild -scheme WhisperType -configuration Debug -showBuildSettings | grep -m 1 "BUILT_PRODUCTS_DIR" | sed 's/.*= //')/WhisperType.app"

# Open the app
open "$APP_PATH"

echo ""
echo "WhisperType launched!"
echo "Look for the microphone icon in your menu bar."
echo "Press Cmd+Shift+Space to start/stop recording."
