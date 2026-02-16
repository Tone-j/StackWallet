# StackWallet

A production-ready digital loyalty card wallet built with Flutter. Designed for South African retailers (Clicks, Pick n Pay, Woolworths, Checkers, Dis-Chem, etc.), StackWallet lets you ditch the physical cards and scan barcodes straight from your phone.

Fully offline. No backend. No account required.

---

## Features

- **Add loyalty cards** — store name, card number, barcode/QR generation, custom logo, brand colour
- **Wallet-style card stack** — Apple Wallet-inspired stacking UI with press animations
- **Barcode/QR display** — full-screen scannable barcode at checkout (Code 128, EAN-13, QR, and more)
- **Search and filter** — find cards instantly
- **Favourites** — long-press to star frequently used cards
- **Dark mode** — system-aware with manual toggle
- **SA retailer presets** — 21 pre-configured South African stores with brand colours
- **Edit / delete / copy** — full card management with clipboard support
- **Offline-first** — all data stored locally via Hive

---

## Tech Stack

| Layer              | Choice                | Why                                                       |
| ------------------ | --------------------- | --------------------------------------------------------- |
| Framework          | Flutter 3.29 / Dart 3.7 | Cross-platform, single codebase                          |
| State Management   | Riverpod 2.x          | Compile-safe, no context needed, auto-dispose, testable  |
| Local Storage      | Hive                  | Pure Dart, zero native deps, fast key-value + object store |
| Navigation         | GoRouter              | Declarative, deep-link ready, officially recommended      |
| Barcode Generation | barcode_widget        | Supports Code128, EAN-13, QR, PDF417, and more           |
| Architecture       | Clean Architecture    | Feature-based folders, separated UI / state / data layers |
| Design System      | Material 3            | Modern, adaptive, built-in dark mode support              |

---

## Project Structure

```
lib/
├── main.dart                          # Entry point
├── bootstrap.dart                     # Hive init, error handling
├── app/
│   ├── app.dart                       # MaterialApp + theme mode provider
│   ├── router.dart                    # GoRouter route definitions
│   └── theme/
│       ├── app_theme.dart             # Light & dark ThemeData
│       └── app_colors.dart            # Brand colour palette
├── core/
│   ├── constants/
│   │   ├── app_constants.dart         # App-wide string constants
│   │   └── sa_retailers.dart          # 21 SA retailer presets
│   └── utils/
│       └── barcode_utils.dart         # Barcode format helpers
└── features/
    └── wallet/
        ├── data/
        │   ├── models/
        │   │   └── loyalty_card.dart  # Immutable model + JSON serialisation
        │   └── repositories/
        │       └── card_repository.dart # Hive CRUD operations
        ├── providers/
        │   └── wallet_providers.dart  # Riverpod state (cards, search, filters)
        └── presentation/
            ├── screens/
            │   ├── wallet_screen.dart         # Home — card stack + search
            │   ├── card_detail_screen.dart     # Full barcode + card info
            │   └── add_edit_card_screen.dart   # Add/edit form with live preview
            └── widgets/
                ├── wallet_card.dart     # Single card widget (brand colour, barcode preview)
                ├── card_stack.dart      # Stacked card layout with press animation
                ├── barcode_display.dart  # Full-size barcode/QR renderer
                └── empty_wallet.dart    # Empty state CTA
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.29+ ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio or VS Code with Flutter extension
- Android emulator (API 21+) or physical device
- Chrome (for web testing)

### Install and Run

```bash
# Clone the repo
git clone <your-repo-url>
cd StackWallet

# Get dependencies
flutter pub get

# Run on Android emulator
flutter run

# Run on Chrome (web)
flutter run -d chrome

# Run on specific device
flutter devices          # list available devices
flutter run -d <device>
```

### Run Tests

```bash
flutter test
```

### Static Analysis

```bash
flutter analyze
```

---

## Full DevOps Lifecycle Guide

This project is structured to teach you the complete cycle from local development to Play Store release.

### Phase 1 — Local Development

```bash
# Hot reload during development
flutter run

# Run with verbose logging
flutter run --verbose

# Run in release mode locally (performance testing)
flutter run --release
```

### Phase 2 — Code Quality

```bash
# Static analysis (catches errors, enforces lint rules)
flutter analyze

# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# View coverage report (requires lcov)
# On Ubuntu/WSL: sudo apt install lcov
genhtml coverage/lcov.info -o coverage/html
# Open coverage/html/index.html in browser
```

### Phase 3 — Build Artifacts

```bash
# Debug APK (for emulator testing)
flutter build apk --debug

# Release APK (for sideloading / internal testing)
flutter build apk --release

# Android App Bundle (required for Play Store)
flutter build appbundle --release

# Web build
flutter build web --release

# iOS build (macOS only)
flutter build ios --release
```

Build outputs:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`
- Web: `build/web/`

### Phase 4 — Android Signing (Play Store requirement)

```bash
# 1. Generate an upload keystore (once, keep it safe forever)
keytool -genkey -v \
  -keystore android/keystore/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# 2. Create key.properties in android/ directory
#    (NEVER commit this file — it's in .gitignore)
cat > android/key.properties << 'EOF'
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=../keystore/upload-keystore.jks
EOF

# 3. Build signed bundle
flutter build appbundle --release
```

The `build.gradle.kts` is already configured to load `key.properties` when present and fall back to debug signing otherwise.

### Phase 5 — Play Store Deployment

1. **Create a Google Play Developer account** ($25 one-time fee) at [play.google.com/console](https://play.google.com/console)

2. **Create your app** in the Play Console:
   - App name: StackWallet
   - Default language: English (South Africa)
   - App type: App
   - Free

3. **Store listing** — prepare these assets:
   - App icon: 512x512 PNG
   - Feature graphic: 1024x500 PNG
   - Screenshots: minimum 2 phone screenshots (1080x1920)
   - Short description (80 chars): "Your loyalty cards, always in your pocket. Made for SA."
   - Full description (4000 chars): describe features

4. **Content rating** — complete the IARC questionnaire (this app has no objectionable content)

5. **Upload your AAB**:
   - Go to Release > Production > Create new release
   - Upload `build/app/outputs/bundle/release/app-release.aab`
   - Add release notes

6. **Review and roll out** — Google typically reviews within 1-3 days for new apps

### Phase 6 — CI/CD (GitHub Actions)

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  analyze-and-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.3'
          channel: 'stable'

      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage

      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage
          path: coverage/lcov.info

  build-android:
    runs-on: ubuntu-latest
    needs: analyze-and-test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.3'
          channel: 'stable'
      - uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'

      - run: flutter pub get
      - run: flutter build apk --release

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-web:
    runs-on: ubuntu-latest
    needs: analyze-and-test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.29.3'
          channel: 'stable'

      - run: flutter pub get
      - run: flutter build web --release

      - name: Upload web build
        uses: actions/upload-artifact@v4
        with:
          name: web-build
          path: build/web
```

### Phase 7 — Versioning and Releases

```bash
# Version format in pubspec.yaml: version: MAJOR.MINOR.PATCH+BUILD
# Example: 1.0.0+1 → 1.1.0+2 → 1.1.1+3

# The +N build number MUST increment with every Play Store upload.
# Bump it before each release:
#   version: 1.0.1+2

# Tag releases in git
git tag -a v1.0.0 -m "Initial release"
git push origin v1.0.0
```

### Phase 8 — Monitoring and Iteration

After release, consider adding:

- **Firebase Crashlytics** — crash reporting in production
- **Firebase Analytics** — usage patterns
- **In-app review** — prompt happy users to rate the app
- **Fastlane** — automate Play Store uploads from CI

---

## Environment Configuration

The app is structured for easy environment extension:

| File                          | Purpose                              |
| ----------------------------- | ------------------------------------ |
| `pubspec.yaml`                | Dependencies and version             |
| `android/app/build.gradle.kts`| Android build config, signing, minSdk |
| `android/key.properties`      | Release signing credentials (git-ignored) |
| `android/app/proguard-rules.pro` | R8/ProGuard keep rules            |
| `analysis_options.yaml`       | Strict lint rules                    |
| `lib/core/constants/`         | App-wide constants and retailer data |

---

## Architecture Decisions

**Why Hive over Isar?**
Hive is pure Dart with zero native dependencies, making it simpler to build, test, and deploy across platforms. For a card wallet storing dozens of objects (not thousands), Hive's key-value model is ideal. Isar offers better query support but adds native build complexity and was discontinued by its maintainer.

**Why Riverpod over Bloc?**
Riverpod eliminates boilerplate (no event/state classes), is compile-safe (no runtime Provider errors), and doesn't require BuildContext to access state. For a focused app like this, Riverpod's simplicity-to-power ratio is better than Bloc's ceremony.

**Why GoRouter?**
It's Flutter's officially recommended navigation package, supports declarative routing, deep links, and works seamlessly with both mobile and web targets.

---

## Licence

MIT
