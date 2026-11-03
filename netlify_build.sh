#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo " Starting Netlify Flutter Web Build"
echo "=========================================="

FLUTTER_BRANCH="${FLUTTER_BRANCH:-stable}"
FLUTTER_DIR="$HOME/flutter"

# Check if Flutter exists in PATH or $HOME/flutter
if ! command -v flutter &> /dev/null; then
  if [ ! -x "$FLUTTER_DIR/bin/flutter" ] || [ ! -f "$FLUTTER_DIR/netlify-release.json" ]; then
    echo "Downloading official Flutter SDK ($FLUTTER_BRANCH channel)..."
    SDK_TEMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$SDK_TEMP_DIR"' EXIT
    curl --fail --silent --show-error --location --retry 3 \
      https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json \
      --output "$SDK_TEMP_DIR/releases.json"
    # Resolve the requested channel to its official Linux SDK and checksum.
    python3 - "$SDK_TEMP_DIR/releases.json" "$FLUTTER_BRANCH" "$SDK_TEMP_DIR/netlify-release.json" > "$SDK_TEMP_DIR/release" <<'PY'
import json
import platform
import sys

with open(sys.argv[1]) as manifest_file:
    manifest = json.load(manifest_file)
channel = sys.argv[2]
release_hash = manifest['current_release'].get(channel)
if release_hash is None:
    raise SystemExit(f'Unsupported Flutter channel: {channel}')
machine = platform.machine()
architectures = {'x86_64': 'x64', 'aarch64': 'arm64'}
if machine not in architectures:
    raise SystemExit(f'Unsupported Linux architecture: {machine}')
release = next(
    item for item in manifest['releases']
    if item['hash'] == release_hash
    and item.get('dart_sdk_arch', 'x64') == architectures[machine]
)
print(manifest['base_url'] + '/' + release['archive'])
print(release['sha256'])
with open(sys.argv[3], 'w') as release_file:
    json.dump(release, release_file)
PY
    mapfile -t SDK_RELEASE < "$SDK_TEMP_DIR/release"
    curl --fail --silent --show-error --location --retry 3 \
      "${SDK_RELEASE[0]}" --output "$SDK_TEMP_DIR/flutter.tar.xz"
    printf '%s  %s\n' "${SDK_RELEASE[1]}" "$SDK_TEMP_DIR/flutter.tar.xz" | sha256sum --check --status
    tar -xJf "$SDK_TEMP_DIR/flutter.tar.xz" -C "$SDK_TEMP_DIR"
    mkdir -p "$FLUTTER_DIR"
    cp -a "$SDK_TEMP_DIR/flutter/." "$FLUTTER_DIR/"
    cp "$SDK_TEMP_DIR/netlify-release.json" "$FLUTTER_DIR/netlify-release.json"
  else
    echo "Using cached Flutter installation in $FLUTTER_DIR"
  fi
  export PATH="$FLUTTER_DIR/bin:$PATH"
fi

# The first launch can rebuild flutter_tools and replace its version cache when
# Git metadata is unavailable. Restore the installed release's official metadata
# after that bootstrap, while retaining the tool's engine and Dart information.
if [ -f "$FLUTTER_DIR/netlify-release.json" ] && [ "$(command -v flutter)" = "$FLUTTER_DIR/bin/flutter" ]; then
  echo "Initializing Flutter tools..."
  flutter --version > /dev/null
  python3 - "$FLUTTER_DIR" <<'PY'
import json
from pathlib import Path
import sys

sdk_root = Path(sys.argv[1])
with (sdk_root / 'netlify-release.json').open() as source:
    release = json.load(source)
version_file = sdk_root / 'bin/cache/flutter.version.json'
with version_file.open() as source:
    version = json.load(source)
version.update({
    'frameworkVersion': release['version'],
    'flutterVersion': release['version'],
    'channel': release['channel'],
    'repositoryUrl': 'https://github.com/flutter/flutter.git',
    'frameworkRevision': release['hash'],
    'frameworkCommitDate': release['release_date'],
})
with version_file.open('w') as destination:
    json.dump(version, destination, indent=2)
PY
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
