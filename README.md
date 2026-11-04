# Experiment 10: Firestore Authentication User Portal

**Name:** Kevin Kattakayam  
**Register number:** URK23CS7081  
**Course:** 24CS2016 - Building Applications using Flutter  
**Date of exercise:** 2026-10-12 (Monday)  
**Repository:** https://github.com/Kevin-Kattakayam/exp10

## Objective

To develop a Flutter registration and login flow that stores user profile records in Firestore and opens a dashboard after successful sign-in.

## Run locally

This repository includes the Dart sources, dependency lockfile and Flutter platform folders. Use a Flutter SDK with Dart 3.11 or later, matching pubspec.yaml. Install the device/platform toolchain first.

```bash
flutter pub get
flutter analyze
flutter run -d chrome
```

Select an emulator or another supported device with `flutter devices` and `flutter run -d <device>`. The original widget tests are retained under `test/`; they have not been run in the preparation environment.

## Firebase setup

The reference contains placeholder values in `lib/firebase_options.dart`. Configure your own Firebase project before expecting live cloud operations:

1. Install/sign in to the Firebase CLI and install the FlutterFire CLI.
2. Run `flutterfire configure` in this repository to generate your platform options.
3. Create a Cloud Firestore database and configure the access rules for your authorized lab environment.
4. Run the app and verify the resulting documents in the Firestore console. Resolve any permission or composite-index errors reported by Firebase.

Official setup: https://firebase.google.com/docs/flutter/setup

The reference code includes an in-memory fallback; this resets when the process restarts and does not verify cloud persistence. Placeholder Firebase settings can initialize before a later network request fails.

This lab demonstrates manual credential comparison using SHA-256 hashes. It does not create a Firebase Authentication session. Use demonstration passwords. SHA-256 is hashing, and displaying a role is not server-enforced authorization.

## Laboratory record

- [PDF record](record/URK23CS7081_24CS2016_Exp10_2026-10-12.pdf)
- [Editable record](record/record.md)
- [Reference output images](output/)
- [Reference and source credit](ATTRIBUTION.md)

The PDF preserves the supplied reference layout and original page count. The date and repository URL have been updated for this experiment. Screenshots are from the supplied reference record, not newly captured execution evidence.

## Validation

The source imports, package declarations and record layout were checked. Flutter/Dart compilation, widget tests, device execution and live Firebase operations have not been run in the preparation environment.
