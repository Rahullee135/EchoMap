# 🎙️ EchoMap

**Pin 30-second voice memories to real places. Walk past one — yours or a friend's — and it plays through your earbuds.**

A Flutter app for **iOS and Android** built from a single codebase. Use it for a local's neighbourhood tips, a family-history walk, or a "what happened here" tour of your hometown.

---

## ✨ Features

- 🗺️ **Live map** with your position and a pulsing trigger-radius circle
- 🎤 **Drop Echo** — record up to 30 s, pick a category, add a title, pin it to where you stand
- 🔊 **Auto-play** — echoes start on their own when you walk inside the trigger radius (with a haptic nudge)
- 📍 **Background-capable** — Android foreground location service, iOS `location` + `audio` background modes
- 🗂️ **Echoes library** — filter by category, play, delete, jump to the pin on the map
- 🎨 **Highly customisable UI** — light / dark / auto theme, 6 gradient accents, 4 map styles, trigger radius 25–200 m
- 🔒 **Private by default** — recordings and settings live only on your device

## 🧱 Tech stack

| Concern | Package |
|---|---|
| State management | `flutter_riverpod` |
| Map (no API key) | `flutter_map` + OpenStreetMap tiles |
| Location / geofencing | `geolocator` |
| Recording | `record` |
| Playback | `just_audio` |
| Storage | JSON files via `path_provider` |

## 📁 Project structure

```
lib/
├── main.dart                 # bootstrap: opens storage, preloads state, runs app
├── app.dart                  # MaterialApp, theme driven by user settings
├── core/
│   ├── constants/            # app-wide constants
│   ├── theme/                # accent palettes + ThemeData builder
│   ├── storage/              # tiny JSON-file persistence layer
│   ├── utils/                # formatters (distance, duration, "time ago")
│   └── widgets/              # glass card, gradient button, pulse ring, waveform
├── services/                 # platform wrappers: location, audio recorder
└── features/
    ├── echoes/
    │   ├── domain/           # Echo model, categories
    │   ├── data/             # repository (persistence)
    │   ├── application/      # Riverpod providers: echoes, player, discovery, recorder
    │   └── presentation/     # map & echoes screens, record / detail sheets, markers
    ├── settings/             # domain · data · application · presentation
    └── shell/                # bottom nav + floating "Drop Echo" button
scripts/
├── build_android.sh          # separate Android build
└── build_ios.sh              # separate iOS build
test/                         # unit tests
```

---

## 🚀 Setup guide (from zero)

### 0. What you need

| Tool | Needed for | Check |
|---|---|---|
| **Git** | cloning | `git --version` |
| **Flutter SDK 3.47+** (Dart 3.13+) | everything | `flutter --version` |
| **Xcode 15+** + **CocoaPods** | iOS (macOS only) | `xcodebuild -version`, `pod --version` |
| **Android Studio** (SDK 36 + cmdline-tools) + **JDK 17+** | Android | `flutter doctor` |

> iOS builds require a Mac. Android builds work on macOS, Windows and Linux.

### 1. Install Flutter

**macOS (Homebrew):**
```bash
brew install --cask flutter
```
**Other OS / manual:** follow <https://docs.flutter.dev/get-started/install>.

### 2. Install platform tooling

**iOS (macOS only)**
```bash
# Install Xcode from the App Store, then:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
brew install cocoapods
```
> If `pod install` crashes with an *"Unicode Normalization … ASCII-8BIT"* error, run
> `export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8` first (add it to your `~/.zshrc`).

**Android**
1. Install [Android Studio](https://developer.android.com/studio).
2. *Settings → Languages & Frameworks → Android SDK*: install an SDK Platform (API 34+), **Android SDK Command-line Tools**, and Platform-Tools.
3. Accept the licences:
   ```bash
   flutter doctor --android-licenses
   ```

### 3. Verify the toolchain
```bash
flutter doctor
```
Every section you plan to use (iOS and/or Android) should show a ✓.

### 4. Clone and install dependencies
```bash
git clone https://github.com/Rahullee135/EchoMap.git
cd EchoMap
flutter pub get
```

### 5. Run on a device or emulator

```bash
flutter devices            # list available targets
flutter run -d <device-id> # run on one of them
# or
make run-ios
make run-android
```

#### iOS Simulator
```bash
open -a Simulator
flutter run -d ios
```
Set a fake GPS position: *Simulator → Features → Location → Custom Location…*
(or `xcrun simctl location booted set 12.9716,77.5946`).
The simulator has no microphone input, so test recording on a real iPhone.

#### iOS real device
1. Open `ios/Runner.xcworkspace` in Xcode.
2. *Runner → Signing & Capabilities*: pick your **Team** and change the bundle id from `com.echomap.echomap` to one you own.
3. Plug in the iPhone, trust the computer, then `flutter run -d <iphone-id>`.

#### Android emulator
```bash
flutter emulators --launch <emulator-id>
flutter run -d android
```
Set a GPS position from the emulator's *Extended controls (⋯) → Location*.

#### Android real device
Enable *Developer options → USB debugging*, plug in the phone, accept the prompt, then `flutter run`.

### 6. First launch
1. Allow **Location** when prompted (choose *While Using the App*; on Android 10+ keep the foreground notification enabled).
2. Allow **Microphone** the first time you tap **Drop Echo**.
3. Tap **Drop Echo**, record, choose a category and **Pin echo here**.
4. Walk outside the trigger radius and back in — the echo plays automatically.

---

## 🏗️ Building (separate per platform)

| Platform | Command | Output |
|---|---|---|
| Android APK (per-ABI) | `make android-apk` | `build/app/outputs/flutter-apk/` |
| Android App Bundle (Play Store) | `make android-aab` | `build/app/outputs/bundle/release/` |
| iOS app, unsigned | `make ios-app` | `build/ios/iphoneos/Runner.app` |
| iOS IPA, signed | `make ios-ipa` | `build/ios/ipa/` |

The same builds without `make`:
```bash
scripts/build_android.sh apk      # apk | aab | debug
scripts/build_ios.sh app          # app | ipa | debug (simulator)
```

### Release signing

**Android** — create a keystore and reference it from `android/app/build.gradle.kts`
(`signingConfigs`) before uploading to Google Play:
```bash
keytool -genkey -v -keystore ~/echomap-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias echomap
```
Never commit the keystore or its passwords.

**iOS** — set your Team in Xcode (step 5), then `make ios-ipa` and upload with Xcode Organizer or `xcrun altool` / Transporter.

---

## 🧪 Development commands

```bash
make get        # flutter pub get
make analyze    # static analysis
make test       # unit tests
make clean      # flutter clean
```

## ⚙️ Configuration notes

- **Permissions** are declared in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist` (location, microphone, background modes, foreground service). Android `minSdk` is 24, iOS deployment target is 15.0.
- **Map tiles** use keyless OpenStreetMap tiles; the four styles are colour filters over the same tiles (`lib/features/settings/domain/app_settings.dart`). OSM's [tile usage policy](https://operations.osmfoundation.org/policies/tiles/) forbids heavy production traffic — switch to a commercial provider (MapTiler, Stadia, Mapbox…) before a large launch by changing `MapStyle.urlTemplate`.
- **Background triggering** needs real devices; battery-saver modes on some Android vendors can pause the location service.

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `flutter: command not found` | Add Flutter's `bin` to your `PATH`, or `brew install --cask flutter`. |
| `cmdline-tools component is missing` | Install *Android SDK Command-line Tools* in Android Studio's SDK Manager. |
| `Android license status unknown` | `flutter doctor --android-licenses` |
| `CocoaPods not installed` | `brew install cocoapods` |
| `Unicode Normalization … ASCII-8BIT` | `export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8` |
| iOS: *No Podfile found* | Run `flutter build ios` / `flutter run` once; Flutter generates it. |
| iOS signing error | Set a Team and unique bundle id in Xcode. |
| Map shows grey tiles | Check the device's internet connection. |
| Echoes don't auto-play | Check *Style → Auto-play* is on, location permission is granted, and the trigger radius covers your distance. |
| No location in simulator | Set a custom location (see step 5). |

## 🗺️ Roadmap

- Share echoes with friends (accounts + cloud sync)
- Curated public "audio tours"
- Offline map regions
- Lock-screen playback controls

## 🤝 Contributing

Issues and pull requests are welcome. Run `make analyze && make test` before opening a PR.

## 📄 Licence

MIT — see [LICENSE](LICENSE).
