# Smart Glass

Smart Glass is a Flutter Android app for Zachery's Grok-style voice assistant concept.

## What is included

- Flutter app entry point in `lib/main.dart`
- Secure API key storage using `flutter_secure_storage`
- Futuristic dark/gold UI
- Memory Bank screen placeholder
- GitHub Actions workflow to build an Android APK online

## Build the APK with GitHub Actions

1. Open this repository on GitHub.
2. Tap **Actions**.
3. Select **Build Android APK**.
4. Tap **Run workflow**.
5. Wait for the build to finish.
6. Open the finished workflow run.
7. Download the artifact named **smart-glass-debug-apk**.
8. Extract the ZIP file.
9. Install `app-debug.apk` on your Android phone.

## Build locally

```bash
flutter pub get
flutter build apk --debug
```

The APK will be created at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

## Notes

The current app stores the xAI/Grok API key locally on the phone using secure storage. The buttons for connecting glasses, sending texts, making calls, and teaching memory are UI placeholders ready for future wiring.
