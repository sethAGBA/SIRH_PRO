# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds the Flutter source code; the entry point is `lib/main.dart`.
- `test/` contains widget and unit tests (see `test/widget_test.dart`).
- Platform-specific runners live in `android/`, `ios/`, `macos/`, `linux/`, `windows/`, and `web/`.
- Configuration is in `pubspec.yaml` (dependencies, assets) and `analysis_options.yaml` (lint rules).

## Build, Test, and Development Commands
- `flutter pub get` installs dependencies.
- `flutter run` launches the app on a connected device or simulator.
- `flutter test` runs the test suite in `test/`.
- `flutter analyze` runs static analysis using `analysis_options.yaml`.
- `dart format .` formats Dart code across the repository.

## Coding Style & Naming Conventions
- Follow Flutter lints from `package:flutter_lints` (see `analysis_options.yaml`).
- Use 2-space indentation and Dart formatting defaults via `dart format .`.
- Prefer lowerCamelCase for variables/functions, UpperCamelCase for classes, and `snake_case.dart` for filenames.

## Testing Guidelines
- Tests use `flutter_test` (widget tests in `test/`).
- Name test files with `_test.dart` (example: `widget_test.dart`).
- Run `flutter test` locally before submitting changes; keep tests focused and deterministic.

## Commit & Pull Request Guidelines
- No commit message convention is defined in this repository; use short, imperative subjects (e.g., "Add login screen").
- PRs should include a concise summary, relevant screenshots for UI changes, and a note on testing performed.

## Configuration & Assets
- Add assets or fonts by declaring them under the `flutter:` section in `pubspec.yaml`.
- Avoid committing secrets; keep environment-specific values in local tooling or CI configuration.
