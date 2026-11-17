#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo " Starting Netlify Flutter Web Build"
echo "=========================================="

FLUTTER_VERSION="${FLUTTER_VERSION:-3.47.5}"

if ! command -v flutter >/dev/null 2>&1; then
  # A shallow release checkout keeps Git version metadata and bootstraps its
  # own Dart SDK without downloading the full Flutter distribution archive.
  SDK_TEMP_DIR="$(mktemp -d)"
  trap 'rm -rf -- "$SDK_TEMP_DIR"' EXIT
  FLUTTER_DIR="$SDK_TEMP_DIR/flutter"

  echo "Cloning Flutter $FLUTTER_VERSION..."
  git clone --depth 1 --branch "$FLUTTER_VERSION" \
    https://github.com/flutter/flutter.git "$FLUTTER_DIR"
  export PATH="$FLUTTER_DIR/bin:$PATH"
fi

echo "Flutter version:"
flutter --version

echo "Configuring Flutter for Web..."
flutter config --enable-web --no-analytics

echo "Downloading Flutter web artifacts..."
flutter precache --web

echo "Resolving dependencies..."
flutter pub get

echo "Building Flutter Web Release..."
flutter build web --release --no-pub --base-href "/"

echo "=========================================="
echo " Build successful! Output in build/web"
echo "=========================================="
