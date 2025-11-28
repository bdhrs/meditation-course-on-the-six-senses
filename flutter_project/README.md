# Six Senses Meditation Course App

A Flutter application for the "Meditation Course on the Six Senses". This app provides a comprehensive guide to developing calm and insight through sense experience, featuring text lessons and guided audio meditations.

## Features

-   **100% Local Content**: All text and audio assets are bundled within the app. No internet connection is required for playback.
-   **Markdown Rendering**: Lessons are rendered from Markdown files with support for custom components.
-   **Audio Player**: Integrated audio player for guided meditations.
-   **Dark Mode**: Supports both light and dark themes.

## Getting Started

### Prerequisites

-   [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
-   Android Studio or VS Code with Flutter extensions.

### Running Locally

```bash
flutter run
```

## Building for Android

```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

The generated APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

### Note on App Size

Since all audio files are bundled locally to ensure offline access, the APK size is approximately **750MB**.
