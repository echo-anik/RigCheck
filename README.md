# RigCheck - Flutter Mobile App

A comprehensive PC building mobile application built with Flutter.

## Features

- **PC Builder** - Step-by-step guided build process with real-time compatibility checking
- **Component Browser** - Search and filter through thousands of PC components
- **Price Tracking** - Compare prices from multiple retailers
- **Community Feed** - Browse and share PC builds with the community
- **Favorites** - Save favorite components and builds
- **Build Management** - Create, edit, duplicate, and delete builds
- **Dark Mode** - Full dark/light theme support
- **Offline Support** - Browse previously loaded data offline

## Screenshots

[Add screenshots here]

## Getting Started

### Prerequisites

- Flutter SDK 3.16+
- Dart 3.2+
- Android Studio / VS Code
- Android SDK (for Android)
- Xcode (for iOS, macOS only)

### Installation

```bash
# Clone the repository
git clone https://github.com/echo-anik/RigCheck.git
cd RigCheck

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Configuration

Create a `.env` file or update `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'YOUR_API_URL';
```

## Building for Release

### Android
```bash
flutter build apk --release
# APK will be in build/app/outputs/flutter-apk/
```

### iOS
```bash
flutter build ios --release
# Open build/ios/Runner.xcworkspace in Xcode to archive
```

## Project Structure

```
lib/
├── core/               # Core utilities and constants
│   ├── constants/      # API URLs, colors, strings
│   ├── services/       # Business logic services
│   └── theme/          # App theming
├── data/              # Data layer
│   ├── models/        # Data models
│   └── repositories/  # API repositories
├── presentation/      # UI layer
│   ├── providers/     # State management (Riverpod)
│   ├── screens/       # App screens
│   └── widgets/       # Reusable widgets
└── routes/           # Navigation routing
```

## State Management

This app uses **Riverpod** for state management with the following providers:
- `authProvider` - Authentication state
- `buildProvider` - Build management
- `componentProvider` - Component browsing
- `activeBuildProvider` - Current build session

## Key Features Implemented

### PC Builder
- Guided wizard with 8 component categories
- Real-time compatibility checking
- Auto-progression after selection
- Build session management
- Component substitution

### Build Management
- Create new builds
- Edit existing builds
- Duplicate builds with all components
- Delete builds
- Share builds publicly/privately

### Component Selection
- Category-based browsing
- Search functionality
- Price filtering
- Compatibility filtering
- Detailed component specs

### Social Features
- Community feed
- Build likes and comments
- User profiles
- Follow system

### Admin Panel
- User management
- Component management
- Build moderation

## Dependencies

Key packages used:
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `dio` - HTTP client
- `cached_network_image` - Image caching
- `shared_preferences` - Local storage

See `pubspec.yaml` for complete list.

## API Integration

The app connects to a Laravel API backend. Configure the base URL in:
`lib/core/constants/api_constants.dart`

Required endpoints:
- `/api/v1/components` - Component listing
- `/api/v1/builds` - Build management
- `/api/v1/auth/*` - Authentication

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is for educational purposes.

## Support

For issues and questions, please open a GitHub issue.
