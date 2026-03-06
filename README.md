# OTUS Food App

Flutter application for managing recipes, favorites, fridge inventory, and cooking history with local offline persistence.

## Features

- Registration and login flow
- Recipe catalog with detailed recipe view
- Create and edit recipes with image picking/cropping
- Favorites tab
- Fridge inventory management with availability checks
- Cooking history tracking
- Persistent local storage using Hive and SharedPreferences

## Tech Stack

- Flutter / Dart
- Hive (`hive`, `hive_flutter`)
- SharedPreferences
- Image Picker + image cropping (`image_picker`, `image_cropper`, `crop_your_image`)

## Project Structure

```text
lib/
  main.dart
  splash_screen.dart
  registration_screen.dart
  login_screen.dart
  main_screen.dart
  recipe_list_screen_universal.dart
  recipe_detail_screen.dart
  create_screen.dart
  fridge_screen.dart
  favorites_screen.dart
  history_screen.dart
  profile_screen.dart
  models/
  services/
  repositories/
  widgets/
```

## Getting Started

### 1. Prerequisites

- Flutter SDK (stable)
- Dart SDK (included with Flutter)
- Android Studio or VS Code
- Emulator or physical device

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Generate Hive adapters (if needed)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Run app

```bash
flutter run
```

## Useful Commands

```bash
flutter analyze
flutter test
dart format lib test
```

## Build

```bash
flutter build apk --release
```

## Screenshots

Place screenshots in `docs/screenshots/` and reference them here.

Example:

```md
![Home](docs/screenshots/01-home.png)
```

## Notes

- This is an app repository, so keeping `pubspec.lock` in Git is expected.
- Local IDE files and generated artifacts are ignored via `.gitignore`.
