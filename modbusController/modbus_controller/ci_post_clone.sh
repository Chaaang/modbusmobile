#!/bin/sh

# Fail if any command fails
set -e

# Show each command
set -x

# Clone Flutter SDK (stable channel)
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Get dependencies
flutter pub get

# Build iOS (creates Generated.xcconfig)
flutter build ios --release
