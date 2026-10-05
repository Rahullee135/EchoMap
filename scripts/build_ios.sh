#!/usr/bin/env bash
# iOS build (macOS + Xcode + CocoaPods; flutter runs `pod install` itself). Usage: scripts/build_ios.sh [ipa|app|debug]
#   ipa   -> signed release IPA (needs a signing team set in Xcode)
#   app   -> unsigned release Runner.app (--no-codesign), good for CI checks
#   debug -> unsigned debug build for the simulator
set -euo pipefail
cd "$(dirname "$0")/.."

target="${1:-app}"
flutter pub get

case "$target" in
  ipa)   flutter build ipa --release ;;
  app)   flutter build ios --release --no-codesign ;;
  debug) flutter build ios --debug --simulator --no-codesign ;;
  *) echo "Unknown target '$target' (use ipa|app|debug)"; exit 1 ;;
esac
