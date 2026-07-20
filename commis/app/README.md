# Commis Catering Assistant - Flutter Application

This directory contains the Flutter frontend mobile/tablet client application.

## Features
- **GenUI Integration**: Instantly renders stateful widgets from AI-generated A2UI JSON payloads.
- **AI Culinary Assistant Workspace**: Interactive chat interface for planning menus, managing shopping checklists, and requesting ingredient estimations.
- **Catering Job Pipeline**: Interactive dashboards tracking the statuses of upcoming jobs, with inline warning cards and quick action triggers.

---

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [FlutterFire CLI](https://firebase.google.com/docs/flutter/setup)

### Firebase Config Setup
Before running the application, you must link it to your own Firebase project.
1. Run the FlutterFire CLI from this directory to generate your platform configuration files:
   ```bash
   flutterfire configure
   ```
   This generates a local [firebase_options.dart](file:///Users/redbrogdon/source/commis/app/lib/firebase_options.dart) file, as well as the platform-specific configuration files (`google-services.json` and `GoogleService-Info.plist`) which are gitignored.

### Running the App
- **Local Emulator Mode (Default)**: In debug mode, the app automatically routing requests to `localhost:8080` (Firestore) and `localhost:5001` (Functions). Simply start your Firebase Emulator Suite in the root directory and run:
  ```bash
  flutter run
  ```
- **Production Mode**: To override emulator routing and connect directly to your live production Firebase services, run:
  ```bash
  flutter run --dart-define=USE_EMULATORS=false
  ```

---

## Generating the Catalog Prompt

The application uses a test script to compile the widget catalog specifications into a system prompt format for Gemini. Because this imports Flutter UI dependencies, it must be run within the Flutter test runner environment.

To regenerate the `catalog_prompt.txt` file, run:
```bash
flutter test test/generate_prompt_test.dart
```
This parses the catalog defined in [catalog.dart](file:///Users/redbrogdon/source/commis/app/lib/ui/catalog/catalog.dart) and saves the output to `catalog_prompt.txt`.

---

## Verification & Testing
To run the project's test suite, execute:
```bash
flutter test
```
