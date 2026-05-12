#!/bin/bash
set -euo pipefail

APP_NAME="${APP_NAME:-PurePaste}"
VERSION="${VERSION:-1.0.0}"
MIN_MACOS="${MIN_MACOS:-13.0}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/build/macos"
DIST_DIR="$ROOT_DIR/dist/macos"
APP_BUNDLE="$BUILD_DIR/${APP_NAME}.app"
EXECUTABLE="$APP_BUNDLE/Contents/MacOS/${APP_NAME}"
DMG_PATH="$ROOT_DIR/dist/${APP_NAME}.dmg"

rm -rf "$BUILD_DIR" "$DIST_DIR"
mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources" "$DIST_DIR"

swiftc "$ROOT_DIR/macos/PurePasteMac.swift" -o "$EXECUTABLE"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>${APP_NAME}</string>
  <key>CFBundleExecutable</key>
  <string>${APP_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>local.panjc.purepaste</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>${APP_NAME}</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${VERSION}</string>
  <key>CFBundleVersion</key>
  <string>${VERSION}</string>
  <key>LSMinimumSystemVersion</key>
  <string>${MIN_MACOS}</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

codesign --force --deep -s - "$APP_BUNDLE"

cp -R "$APP_BUNDLE" "$DIST_DIR/${APP_NAME}.app"
ln -s /Applications "$DIST_DIR/Applications"

rm -f "$DMG_PATH"
hdiutil create -volname "$APP_NAME" -srcfolder "$DIST_DIR" -ov -format UDZO "$DMG_PATH"

echo "Created $DMG_PATH"
