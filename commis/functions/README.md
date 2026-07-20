# Commis Catering Assistant - Cloud Functions

This directory contains the serverless backend code for the Commis Catering Assistant, written in Dart using the experimental `firebase_functions` Dart package.

## Features
- **Firestore Document Triggers**: Listens to writes on `jobs/{jobId}` documents to run the planning pipeline.
- **AI Content Generator**: Communicates with Gemini to analyze job changes and generate responsive A2UI JSON payloads cached in Firestore.
- **Database Seeding Utility**: Pre-populates the database with default ingredients, recipes, and jobs for testing.

---

## Getting Started

### Prerequisites
- [Firebase CLI](https://firebase.google.com/docs/cli) (v15.15.0 or higher)
- [Dart SDK](https://dart.dev/get-started) (aligned with the main app project)

Before running the emulators or deploying, ensure the Dart functions experiment is enabled on your machine:
```bash
firebase experiments:enable dartfunctions
```

### Seeding the Emulator Database
When starting development with a clean Firestore emulator, you can seed the database with mock catering data using the scripts provided in `bin/`:

1. Set the Firestore emulator environment variable in your terminal:
   ```bash
   export FIRESTORE_EMULATOR_HOST=localhost:8080
   ```
2. Run the seeding commands:
   ```bash
   dart run bin/seed_ingredients.dart
   dart run bin/seed_recipes.dart
   dart run bin/seed_jobs.dart
   ```

---

## Configuration

### Gemini API Key
The functions expect a `GEMINI_API_KEY` parameter to access the Gemini API. 

- **Local Development**: Create a `.env.local` file inside the `functions/` directory:
  ```env
  GEMINI_API_KEY=YOUR_GEMINI_API_KEY
  ```
- **Production**: Configure the parameter in Firebase Secrets or Parameters config.
