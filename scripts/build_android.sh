#!/usr/bin/env bash
# Android build. Usage: scripts/build_android.sh [apk|aab|debug]
#   apk   -> release APK        (build/app/outputs/flutter-apk/)
#   aab   -> release app bundle (build/app/outputs/bundle/release/, for Play Store)
#   debug -> debug APK
set -euo pipefail
cd "$(dirname "$0")/.."

target="${1:-apk}"
flutter pub get

case "$target" in
  apk)   flutter build apk --release --split-per-abi ;;
  aab)   flutter build appbundle --release ;;
  debug) flutter build apk --debug ;;
  *) echo "Unknown target '$target' (use apk|aab|debug)"; exit 1 ;;
esac
