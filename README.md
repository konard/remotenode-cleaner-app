# Cleaner Pro

A production-ready Cleaner App for Android and iOS built with Flutter 3.x+. Clean cache, junk files, boost RAM, and find duplicates with a beautiful Material 3 UI.

## Features

### Core Functionality
- **One-Tap Clean**: Quick cleaning of cache and temporary files with a single tap
- **Storage Analyzer**: Visual breakdown of storage usage by category (apps, cache, media, documents, etc.)
- **Junk Files Scanner**: Detect and clean temporary files, thumbnails, logs, and residual files
- **App Cache Cleaner**: Clear cache from installed applications
- **RAM Booster**: Free up memory by clearing background processes (Android only)
- **Duplicate Finder**: Find and remove duplicate photos/videos using hash comparison
- **Battery Saver**: Suggestions to optimize battery life
- **Clean History**: Track freed space and cleaning statistics

### UI/UX
- Material 3 Design with beautiful animations
- Dark/Light theme support
- Progress animations for scan operations
- Haptic feedback for interactions
- Clean architecture (features: home, scan, results, settings)

### Localization
- English (en)
- Russian (ru)
- Spanish (es)

## Project Structure

```
lib/
├── core/
│   ├── theme/          # App theming (Material 3)
│   ├── utils/          # Utility functions
│   └── services/       # Core services (permissions)
├── features/
│   ├── home/           # Home screen with one-tap clean
│   ├── scan/           # Scanning and results
│   ├── results/        # Storage analysis and stats
│   └── settings/       # App settings
├── l10n/               # Localization files (.arb)
├── models/             # Data models
├── providers/          # State management
└── main.dart           # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for platform-specific builds

### Installation

1. Clone the repository:
```bash
git clone https://github.com/remotenode/cleaner-app.git
cd cleaner-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate localization files:
```bash
flutter gen-l10n
```

4. Run the app:
```bash
flutter run
```

### Build for Release

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Configuration

### App Icons
Add your icon assets to `assets/icons/`:
- `app_icon.png` (1024x1024) - Main app icon
- `app_icon_foreground.png` - For Android adaptive icons

Then run:
```bash
flutter pub run flutter_launcher_icons
```

### Splash Screen
Add your splash logo to `assets/splash/splash_logo.png`, then run:
```bash
flutter pub run flutter_native_splash:create
```

## Permissions

### Android
- `READ_EXTERNAL_STORAGE` - Scan files
- `WRITE_EXTERNAL_STORAGE` - Delete junk files
- `MANAGE_EXTERNAL_STORAGE` - Android 11+ full storage access
- `VIBRATE` - Haptic feedback

### iOS
- Photo Library access - For duplicate photo detection

## Dependencies

- `flutter_localizations` - Internationalization
- `intl` - Date/number formatting
- `path_provider` - File system access
- `permission_handler` - Permission management
- `hive` & `hive_flutter` - Local storage
- `shared_preferences` - Settings storage
- `crypto` - File hash comparison
- `device_info_plus` - Device information
- `vibration` - Haptic feedback
- `percent_indicator` - Progress indicators
- `flutter_staggered_animations` - List animations
- `google_fonts` - Typography
- `animations` - Material motion
- `provider` - State management

## Architecture

The app follows clean architecture principles with feature-based organization:

- **Presentation Layer**: Screens and widgets
- **Domain Layer**: Business logic
- **Data Layer**: Models and repositories

State management is handled by Provider for simplicity and performance.

## Safe Cleaning

The app only targets safe-to-delete files:
- Application cache
- Temporary files
- Thumbnail cache
- Log files
- Residual data from uninstalled apps

**Important**: The app never deletes important system files or user data.

## License

This project is proprietary software.

## Contributing

Please read CONTRIBUTING.md for details on our code of conduct and the process for submitting pull requests.
