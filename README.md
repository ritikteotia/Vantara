# 🌿 Vantara (वंतरा)

[![Flutter](https://img.shields.io/badge/Flutter-3.44.7-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.2-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platforms-Android%20%7C%20iOS-brightgreen)](#-getting-started)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-success)](#)

> **Vantara** is an intelligent, compassionate cognitive rehabilitation and daily living assistant mobile application designed for seniors and individuals with cognitive impairments (such as early-stage dementia, Alzheimer's, or memory loss). It pairs interactive cognitive training games with voice-guided assistive routines, smart reminders, and a comprehensive caregiver monitoring dashboard.

---

## 📱 Target Platforms

* 🤖 **Android** (API Level 21+)
* 🍎 **iOS** (iOS 12.0+)

---

## ✨ Key Features

### 🧠 1. Adaptive Cognitive Games Suite
A curated suite of clinically-inspired cognitive exercises that dynamically adapt to the user's performance:
* **Memory Match**: Card matching memory stimulation with responsive grid scaling.
* **Sequence Recall**: Spatial and visual sequence remembering tasks.
* **What Changed?**: Visual observation and difference detection tests.
* **Object Recognition**: Real-world object identification to stimulate daily functional recall.
* **Daily Routine Recall**: Chronological ordering tasks for essential everyday routines (e.g., morning habits, meal times).

### 📈 2. Intelligent Adaptive Difficulty Engine
* Real-time tracking of reaction times (ms), accuracy percentages, mistake counts, and attempt rates.
* Automatically adjusts game difficulty levels up or down based on continuous performance metrics.

### ⏰ 3. Voice-Guided Smart Reminders & Routine Compliance
* Supports medication reminders, hydration prompts, physical activity alerts, and medical appointments.
* Integrated **Text-to-Speech (TTS)** voice prompts that speak directly to the user to reduce reading strain.
* Easy one-tap confirmation and compliance logging for caregivers.

### 📊 4. Caregiver Dashboard & Analytics
* Deep insights into cognitive stability, reaction time trends, and reminder compliance.
* Visual metrics log for tracking long-term trends and early signs of cognitive decline.

### 🌐 5. Multilingual Voice & UI Localization
* Supports multiple languages with tailored voice prompts:
  * **English** (`en-US`)
  * **Hindi** (`hi-IN`)
  * **Assamese** (`as-IN`)
  * **Manipuri** (`mni-IN`)

### ⚡ 6. Offline-First Architecture
* Complete local data persistence via `SharedPreferences`.
* Unsynced metrics and reminder logs are queued in an offline buffer and synchronized automatically when an active connection is restored.

### 👵 7. Senior-Centric Accessible UI/UX
* High-contrast color palette, readable typography, and large touch targets.
* Calming aesthetics and clear voice instructions to prevent agitation.

---

## 🛠️ Architecture & Tech Stack

```
lib/
├── games/               # Cognitive training games
│   ├── memory_match.dart
│   ├── object_recognition.dart
│   ├── routine_recall.dart
│   ├── sequence_recall.dart
│   └── what_changed.dart
├── models/              # Data models (Reminders, GameMetrics)
│   └── models.dart
├── pages/               # Main navigation views
│   ├── assistant_page.dart
│   ├── dashboard_page.dart
│   ├── games_page.dart
│   ├── home_page.dart
│   └── profile_page.dart
├── services/            # Background & platform services
│   └── tts_service.dart # Text-to-Speech Engine
├── state/               # State Management & Offline Sync
│   └── app_state.dart
└── main.dart            # Application Entry Point & Theme Configuration
```

* **Framework**: [Flutter](https://flutter.dev) (Channel Stable)
* **Language**: [Dart](https://dart.dev)
* **State Management**: `Provider`
* **Local Storage & Offline Buffer**: `shared_preferences`
* **Speech Synthesis**: `flutter_tts`

---

## 🚀 Getting Started

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.22.0 or higher recommended).
2. Set up:
   * **Android**: Android Studio with Android SDK & Command Line Tools.
   * **iOS**: macOS with Xcode 15+ and CocoaPods.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ritikteotia/Vantara.git
   cd Vantara
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Verify setup:**
   ```bash
   flutter doctor
   ```

---

## 📦 Building & Running

### 🏃 Running in Development

* **Run on connected Android device / emulator:**
  ```bash
  flutter run -d android
  ```

* **Run on iOS Simulator / iPhone:**
  ```bash
  flutter run -d ios
  ```

### 🧪 Running Tests & Analysis

* **Run all unit & widget tests:**
  ```bash
  flutter test
  ```

* **Run static code analysis:**
  ```bash
  flutter analyze
  ```

---

### 🔨 Building for Production

#### 🤖 Android

* **Build Release APK:**
  ```bash
  flutter build apk --release
  ```
  *Output:* `build/app/outputs/flutter-apk/app-release.apk`

* **Build Split-per-ABI APKs:**
  ```bash
  flutter build apk --split-per-abi --release
  ```

* **Build Android App Bundle (Google Play):**
  ```bash
  flutter build appbundle --release
  ```
  *Output:* `build/app/outputs/bundle/release/app-release.aab`

#### 🍎 iOS *(macOS & Xcode required)*

* **Build iOS Release:**
  ```bash
  flutter build ios --release
  ```

* **Build Release IPA:**
  ```bash
  flutter build ipa --release
  ```
  *Output:* `build/ios/archive/Runner.xcarchive` / `build/ios/ipa/*.ipa`

---

## 🔒 Permissions & Privacy

* **Audio / TTS**: Generates localized voice instructions locally on-device.
* **Offline Privacy**: Health and cognitive metrics are securely stored on the local device by default with explicit caregiver synchronization controls.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
