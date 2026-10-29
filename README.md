# smart_ai_university_student_assistant

A new Flutter project.

## Local configuration

The app reads its settings from compile-time defines. Keep local values in
a `.env` file, which is git-ignored:

```bash
cp .env.example .env
flutter run --dart-define-from-file=.env
```

The VS Code launch configs and `scripts/run_physical.sh` pass `.env`
automatically. See `.env.example` for the available keys.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
