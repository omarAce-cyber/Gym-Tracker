# Gym Tracker | متتبع الصالة

Gym Tracker is an offline Flutter app for tracking workouts, meals, progress, and basic profile data with a local SQLite database.

متتبع الصالة هو تطبيق Flutter يعمل بدون إنترنت لتسجيل التمارين والوجبات والتقدم والبيانات الأساسية للمستخدم باستخدام قاعدة بيانات SQLite محلية.

## App Description | وصف التطبيق

### English
- A simple mobile gym companion focused on offline usage.
- Helps users review workout sessions, browse exercises, track meals, and follow progress over time.
- Built with an Arabic-first, RTL interface and local persistence through `sqflite`.

### العربية
- تطبيق جوال بسيط لمتابعة التمارين الرياضية مع التركيز على العمل بدون إنترنت.
- يساعد المستخدم على مراجعة جلسات التمرين، تصفح التمارين، تسجيل الوجبات، ومتابعة التقدم مع الوقت.
- الواجهة عربية بالكامل وتدعم الاتجاه من اليمين إلى اليسار مع حفظ البيانات محليًا عبر `sqflite`.

## Features | المميزات

- Offline-first local storage with SQLite (`sqflite`)
- Arabic-only RTL app experience
- Bottom navigation for dashboard, workouts, nutrition, progress, and profile
- Weekly dashboard summary with workout volume chart
- Workout sessions list with session details
- Exercise catalog linked to target muscles
- Personal-record detection inside session details
- Progress page with line chart and best-record summary
- Nutrition meals list with macros and calories
- Meal log history with quantity and date
- Profile summary with goal, weight, height, total sessions, and nutrition logs
- Seeded starter data for muscles and exercises
- Riverpod-based state management

## Tech Stack | التقنيات المستخدمة

- Flutter
- Dart
- Riverpod (`flutter_riverpod`)
- SQLite via `sqflite`
- `fl_chart` for charts
- `intl` for dates/localization formatting
- `image_picker`, `path_provider`, `uuid`, `path`
- Tajawal font assets

## Project Structure | نظرة على هيكل المشروع

```text
lib/
├── app.dart
├── main.dart
├── core/
│   ├── constants/
│   ├── database/
│   └── utils/
├── features/
│   ├── dashboard/
│   ├── nutrition/
│   ├── profile/
│   └── workout/
└── shared/
    ├── providers/
    └── widgets/

assets/
├── fonts/
└── images/

test/
└── unit/
```

### Structure Summary
- `core/`: shared constants, database setup, and utility helpers
- `features/`: app modules grouped by feature
- `shared/providers/`: Riverpod providers and computed app state
- `shared/widgets/`: reusable UI widgets
- `assets/`: fonts and images
- `test/unit/`: unit tests for models and utilities

## Run Locally | التشغيل محليًا

### Prerequisites | المتطلبات
- Flutter SDK installed
- Dart SDK included with Flutter
- Android Studio or Android SDK + platform tools
- An Android phone with USB debugging enabled, or an Android emulator

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

## Build APK | إنشاء ملف APK

Run:

```bash
flutter build apk --release
```

Generated APK path:

```text
build/app/outputs/flutter-apk/app-release.apk
```

> Note: If your local copy does not yet contain generated platform folders such as `android/`, run `flutter create .` once before building.

## Install on Android | التثبيت على أندرويد

1. Build or copy the APK file to your Android device.
2. Open the APK on the device.
3. If Android blocks the install, enable **Install unknown apps / Unknown sources** for the browser, file manager, or app you used to open the APK.
4. Return to the APK file and continue installation.
5. Open the app after install completes.

## Run on Zapp.run | التشغيل على Zapp.run

1. Open [https://zapp.run](https://zapp.run).
2. Sign in if required.
3. Import the project using one of these options:
   - Upload a ZIP file
   - Drag and drop the project
   - Import from Git
4. Wait for Zapp.run to load the project and resolve packages.
5. Make sure `lib/main.dart` is the entry point.
6. Click **Run**.
7. Choose the target preview platform if prompted.
8. Wait for the build and preview emulator to open.
9. If a plugin-related issue appears, check the logs because some native Flutter plugins may have limited browser-cloud support.

## Run on Flutlab.io | التشغيل على Flutlab.io

1. Open [https://flutlab.io](https://flutlab.io).
2. Create an account or sign in.
3. Go to **Projects**.
4. Choose **Import Project**.
5. Import the app by:
   - Uploading a ZIP file, or
   - Importing from a Git repository
6. Open the imported project in the editor.
7. Wait for dependencies to finish loading.
8. Click **Run** / **Preview**.
9. Select Android or Web preview if Flutlab asks for a target.
10. Wait for the emulator/preview pane and build logs to finish loading.

## DartPad Limitation | ملاحظة مهمة حول DartPad

This project cannot run correctly on DartPad because DartPad does not support Flutter mobile plugins such as `sqflite`, and this app depends on local SQLite storage.

لا يمكن تشغيل هذا المشروع بشكل صحيح على DartPad لأن DartPad لا يدعم إضافات Flutter الخاصة بالموبايل مثل `sqflite`، بينما يعتمد التطبيق على قاعدة بيانات SQLite محلية.

## Notes | ملاحظات

- The current app UI is Arabic-first and RTL.
- The database is local, so app data stays on the device unless the app is removed.
- Cloud playgrounds may not fully support all native plugins used by Flutter mobile apps.
