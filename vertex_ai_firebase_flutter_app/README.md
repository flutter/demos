# Colorist

A Flutter application that explores LLM tooling interfaces by allowing users to describe colors in natural language. The app uses Gemini LLM to interpret descriptions and change the color of a displayed square by calling specialized color tools.

## Getting started

You will need to configure a [Firebase project with access to Gemini API](https://firebase.google.com/docs/gemini-in-firebase/set-up-gemini). For more detail please see [Get started with the Gemini API using the Vertex AI in Firebase SDKs](https://firebase.google.com/docs/vertex-ai/get-started?platform=flutter).

This project is not configured for any particular Firebase project. To configure it correctly you need to install `flutterfire`:

```console
flutter pub global activate flutterfire_cli
```

Then run the `flutterfire` command to configure this project for your Firebase project:

```console
rm lib/firebase_options.dart
flutterfire configure
```

With that you should have a working application that you can ask to generate colors for you.

## Project Overview

Colorist serves as a practical testbed for exploring how Gemini handles tool requests and interprets natural language color descriptions into technical color components. The app features:

- **Natural Language Color Input**: Describe colors using everyday language
- **Color Visualization**: A rectangle that updates to display the interpreted color
- **LLM Tool Integration**: Process natural language with color tool calls
- **Color Information Display**: Technical details (RGB values, hex code) of the generated color
- **History Feature**: Last 10 colors generated as clickable thumbnails
- **Visual Logging**: Display raw streaming text from LLM with tool calls/responses
- **Context Management**: Update LLM context when user interacts with color history
- **Streaming State Visualization**: Visual indicators for streaming vs. complete messages

## Platform Support

The application is designed to work across platforms:

- **Desktop**: macOS, Windows
- **Mobile**: iOS and Android
- **Web**: Desktop and mobile

## Technology Stack

- **Framework**: Flutter/Dart
- **LLM**: Gemini via Firebase Vertex AI (using the chat turn by turn with function calling)
- **State Management**: Riverpod with state held in various notifier providers
- **Data Modeling**: freezed for immutable data classes with pattern matching
- **Firebase Configuration**: FlutterFire CLI
- **Responsive Design**: Adaptive layouts for cross-platform support

## User Interface

The application features platform-optimized layouts:

### Desktop Layout (Split-Screen)

- **Left Side (Interaction Area)**:
  - Color display rectangle
  - RGB value and hex code labels
  - History strip of thumbnails for the last 10 colors
  - Chat interface with message streaming state indicators
  - Text input field for color descriptions
  - Submit button

- **Right Side (Log Area)**:
  - Real-time display of LLM interactions
  - Tool calls and responses visualization
  - Formatted log entries for debugging

### Mobile Layout (Tabbed)

Same as above, but laid out as two tabs instead of side by side.
Various adaptions to mobile to make things easier for finger interactions.
