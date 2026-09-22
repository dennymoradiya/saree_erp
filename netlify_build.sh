#!/usr/bin/env bash
set -e

echo "=========================================="
echo " Starting Netlify Flutter Web Build"
echo "=========================================="

FLUTTER_BRANCH="${FLUTTER_BRANCH:-stable}"
FLUTTER_DIR="$HOME/flutter"

# Check if Flutter exists in PATH or $HOME/flutter
if ! command -v flutter &> /dev/null; then
  if [ ! -d "$FLUTTER_DIR/bin" ]; then
    echo "Cloning Flutter ($FLUTTER_BRANCH channel)..."
    git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_BRANCH" "$FLUTTER_DIR"
  else
    echo "Using cached Flutter installation in $FLUTTER_DIR"
  fi
  export PATH="$FLUTTER_DIR/bin:$PATH"
fi

echo "Flutter version:"
flutter --version

echo "Configuring Flutter for Web..."
flutter config --enable-web --no-analytics

echo "Resolving dependencies..."
flutter pub get

echo "Building Flutter Web Release..."
flutter build web --release --base-href "/"

echo "=========================================="
echo " Build successful! Output in build/web"
echo "=========================================="
