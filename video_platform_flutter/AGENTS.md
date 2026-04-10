# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

**video_platform_flutter** — A video platform client built with Flutter. Currently a fresh starter project scaffolding all 6 platforms (Android, iOS, Web, Windows, macOS, Linux). No custom app code or architecture has been built yet.

## Commands

```bash
flutter pub get         # Install dependencies
flutter run             # Run on default device
flutter run -d chrome   # Run on web
flutter run -d windows  # Run on Windows desktop
flutter test            # Run all tests
flutter test test/widget_test.dart  # Run a single test
flutter analyze         # Run linting
flutter build apk       # Build Android APK
flutter build web      # Build for web
```

## Architecture

Currently bare Flutter default — single `lib/main.dart` with the counter app. No state management, no feature folders, no dependencies beyond `flutter` and `cupertino_icons`. Decision on architecture (BLoC, Riverpod, Provider, etc.) and project structure is pending and should be made when the first real feature is added.

## Linting

Uses `flutter_lints` — see `analysis_options.yaml`. No custom lint rules configured.
