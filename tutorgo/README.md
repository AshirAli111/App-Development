# TutorGo

AI-powered tutoring platform connecting students with tutors. Built with Flutter.

---

## Prerequisites

| Tool | Version | Check | Required On |
|------|---------|-------|-------------|
| Flutter SDK | 3.9.2+ | `flutter --version` | All |
| Dart SDK | 3.9.2+ (bundled with Flutter) | `dart --version` | All |
| Android Studio | Latest | For Android emulator & SDK | All |
| Xcode | 15+ | For iOS simulator | macOS only |
| CocoaPods | Latest | `pod --version` | macOS only |
| Visual Studio | 2022+ with C++ Desktop workload | For Windows desktop | Windows only |
| Git | Any | `git --version` | All |

---

## Setup Instructions

### 1. Install Flutter SDK

<details>
<summary><strong>macOS</strong></summary>

```bash
# Homebrew (recommended)
brew install flutter

# Or download manually
# https://docs.flutter.dev/get-started/install/macos
```

Add to your shell profile (`~/.zshrc` or `~/.bashrc`):
```bash
export PATH="$HOME/flutter/bin:$PATH"
```

</details>

<details>
<summary><strong>Windows</strong></summary>

**Option A - Using Chocolatey:**
```powershell
choco install flutter
```

**Option B - Manual install:**
1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter` (avoid paths with spaces or special characters)
3. Add Flutter to PATH:
   - Open Start > Search "Environment Variables"
   - Under User variables, edit `Path`
   - Add `C:\flutter\bin`
4. Restart your terminal

**Option C - Using Git:**
```powershell
cd C:\
git clone https://github.com/flutter/flutter.git -b stable
```
Then add `C:\flutter\bin` to your PATH.

</details>

<details>
<summary><strong>Linux</strong></summary>

```bash
# Using snap
sudo snap install flutter --classic

# Or manual download from https://docs.flutter.dev/get-started/install/linux
```

</details>

After installation, run:

```bash
flutter doctor
```

Fix any issues reported by `flutter doctor` before proceeding.

---

### 2. Clone & Navigate

```bash
cd tutorgo
```

---

### 3. Install Dependencies

```bash
flutter pub get
```

---

### 4. Platform-Specific Setup

#### Android (macOS & Windows)

1. Open Android Studio > SDK Manager
2. Install Android SDK 34+ (compileSdk uses Flutter's default)
3. Create an emulator via AVD Manager (Pixel 7 recommended, API 34)
4. Or connect a physical device with USB debugging enabled

**Windows additional step:** Accept Android licenses:
```powershell
flutter doctor --android-licenses
```

#### iOS (macOS only)

```bash
cd ios
pod install
cd ..
```

Open Xcode at least once to accept the license:
```bash
sudo xcodebuild -license accept
```

#### Windows Desktop

1. Install Visual Studio 2022 (Community edition is free)
2. During install, select **"Desktop development with C++"** workload
3. Verify: `flutter doctor` should show Windows development as ready

#### Web (Chrome) - All Platforms

No additional setup required. Chrome must be installed.

---

## Running the App

### Check Available Devices

```bash
flutter devices
```

### Run on Android Emulator

<details>
<summary><strong>macOS</strong></summary>

```bash
# Start emulator
flutter emulators --launch <emulator_id>

# Run
flutter run
```

</details>

<details>
<summary><strong>Windows</strong></summary>

```powershell
# List available emulators
flutter emulators

# Start emulator
flutter emulators --launch <emulator_id>

# Run
flutter run
```

Or start the emulator from Android Studio AVD Manager, then:
```powershell
flutter run
```

</details>

### Run on iOS Simulator (macOS only)

```bash
# Open simulator
open -a Simulator

# Run
flutter run
```

### Run on Chrome (Web) - All Platforms

```bash
flutter run -d chrome
```

### Run on macOS Desktop

```bash
flutter run -d macos
```

### Run on Windows Desktop

```powershell
flutter run -d windows
```

### Run with Specific Device

```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

---

## Build Commands

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle
```

### iOS (macOS only)

```bash
flutter build ios
```

### Web (All Platforms)

```bash
flutter build web
```

### Windows Desktop

```powershell
flutter build windows
```

### macOS Desktop

```bash
flutter build macos
```

---

## Common Issues & Fixes

### `flutter pub get` fails

```bash
flutter clean
flutter pub get
```

### Gradle build fails (Android)

<details>
<summary><strong>macOS / Linux</strong></summary>

```bash
cd android
./gradlew clean
cd ..
flutter run
```

</details>

<details>
<summary><strong>Windows</strong></summary>

```powershell
cd android
.\gradlew.bat clean
cd ..
flutter run
```

</details>

### iOS Pod install fails (macOS only)

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### Windows build fails

```powershell
# Ensure Visual Studio C++ workload is installed
flutter doctor -v

# Clean and retry
flutter clean
flutter pub get
flutter run -d windows
```

If you see "CMake not found":
- Open Visual Studio Installer
- Modify your installation
- Ensure "C++ CMake tools for Windows" is checked

### Permission issues on Android

The app uses camera, file picker, and permissions. If you get permission denials on Android emulator:

- Go to Settings > Apps > TutorGo > Permissions > Allow all
- Or test on a physical device for accurate permission flows

### SDK version mismatch

```bash
flutter upgrade
flutter pub get
```

This project requires Flutter SDK `^3.9.2`. Ensure your Flutter is up to date.

### Duplicate dependency warning

The `pubspec.yaml` lists `lucide_flutter` twice. If pub complains:

```bash
# This is a known issue in the pubspec - the duplicate is harmless
# but can be removed from line 69
flutter pub get
```

### Windows: "Long path support" error

```powershell
# Run as Administrator
git config --system core.longpaths true
```

### Windows: Flutter not recognized after install

Restart your terminal/IDE after adding Flutter to PATH. If still not working:
```powershell
# Verify PATH
echo $env:PATH

# Should contain C:\flutter\bin (or your install path)
```

---

## Project Configuration

| Config | Value |
|--------|-------|
| Package Name | `com.example.tutorgo` |
| Min Android SDK | Flutter default (21) |
| Kotlin | 2.1.0 |
| AGP | 8.9.1 |
| Java Compatibility | 11 |

---

## Testing Workflow

### 1. First Run Checklist

After `flutter run`, verify these screens load correctly:

1. **Onboarding Screen** - App launches to animated intro page
2. **Login Screen** - Tap "Get Started", see email/password form
3. **Role Selection** - After login, choose Student or Tutor
4. **Profile Setup** - Fill in profile details (use test data)
5. **Dashboard** - Arrive at main dashboard with bottom navbar

### 2. Feature Testing

#### Student Flow
- [ ] Browse tutors in Courses tab
- [ ] Open tutor profile popup
- [ ] Send a message to a tutor
- [ ] Open AI Chat (floating button on dashboard)
- [ ] Ask AI a question and get a response
- [ ] Navigate all profile settings

#### Tutor Flow
- [ ] View schedule with day tabs
- [ ] View student list
- [ ] Open chat with a student
- [ ] Navigate all profile settings

#### AI Chat
- [ ] Send messages as student role
- [ ] Send messages as tutor role
- [ ] Verify Gemini API responses arrive

### 3. Run Unit Tests

```bash
flutter test
```

### 4. Analyze Code

```bash
flutter analyze
```

---

## Development Workflow (Live Editing)

The key to fast Flutter development is **hot reload** — edit code and see changes instantly without restarting the app.

### Step 1: Run the App in Your Terminal

<details>
<summary><strong>macOS</strong></summary>

```bash
cd /path/to/tutorgo
flutter run -d macos
```

</details>

<details>
<summary><strong>Windows</strong></summary>

```powershell
cd C:\path\to\tutorgo
flutter run -d windows
```

</details>

Once built, you'll see:

```
Flutter run key commands.
r  Hot reload
R  Hot restart
h  List all available interactive commands.
d  Detach (terminate "flutter run" but leave application running).
c  Clear the screen.
q  Quit (terminate the application on the device).
```

### Step 2: Edit Code and Reload

1. Keep the terminal open with the app running
2. Open any Dart file in your IDE and make changes
3. Go back to the terminal and press `r` — changes appear in under 1 second
4. Repeat: edit → save → `r` → see result

### Step 3: Stop the App

<details>
<summary><strong>macOS</strong></summary>

| Method | Command |
|--------|---------|
| From the running terminal | Press `q` |
| Close the app window | Terminal detects it automatically |
| If terminal session is lost | `killall tutorgo` |
| Kill all Flutter processes | `flutter daemon --stop` |

</details>

<details>
<summary><strong>Windows</strong></summary>

| Method | Command |
|--------|---------|
| From the running terminal | Press `q` |
| Close the app window | Terminal detects it automatically |
| If terminal session is lost | `taskkill /IM tutorgo.exe /F` |
| Kill all Flutter processes | `flutter daemon --stop` |

</details>

### Step 4: Restart After Stopping

<details>
<summary><strong>macOS</strong></summary>

```bash
# Normal restart (fast - uses cached build)
flutter run -d macos

# If you get stale build errors
flutter clean && flutter pub get && flutter run -d macos
```

</details>

<details>
<summary><strong>Windows</strong></summary>

```powershell
# Normal restart (fast - uses cached build)
flutter run -d windows

# If you get stale build errors
flutter clean; flutter pub get; flutter run -d windows
```

</details>

### Hot Reload vs Hot Restart

| Key | Action | When to Use |
|-----|--------|-------------|
| `r` | **Hot Reload** — applies changes, preserves app state | UI changes, styling, widget edits |
| `R` | **Hot Restart** — full restart, resets all state | Changed `initState`, constructors, routes, global state |

### Tips

- **First build is slow** (~1-2 min) because it compiles native code. Subsequent runs are fast (~5 sec).
- **Hot reload (`r`) works ~90% of the time.** Only use `R` or full restart if `r` doesn't pick up your change.
- **Don't close and reopen the app for every change** — that defeats the purpose. Just press `r`.
- If hot reload shows errors, fix the error in code and press `r` again — it recovers gracefully.

---

## Environment Notes

- The app uses a hardcoded Google Gemini API key for AI chat. This works out of the box for testing.
- All user data is dummy/local - no backend server required.
- The app starts from onboarding every time (no session persistence yet).
- Theme preference (light/dark) is the only persisted setting.

---

## IDE Setup

### VS Code (macOS & Windows)

Install extensions:
- Flutter
- Dart

**macOS:** `Cmd+Shift+P` > "Flutter: Select Device" > Choose target > `F5` to run.

**Windows:** `Ctrl+Shift+P` > "Flutter: Select Device" > Choose target > `F5` to run.

### Android Studio / IntelliJ (macOS & Windows)

1. Open the `tutorgo/` folder as a project
2. Install Flutter & Dart plugins (File > Settings > Plugins)
3. Select device in toolbar dropdown
4. Click Run (green play button) or `Shift+F10`

---

## Quick Start Summary

### macOS

```bash
brew install flutter
flutter doctor
cd tutorgo
flutter pub get
open -a Simulator        # or start Android emulator
flutter run
```

### Windows

```powershell
choco install flutter    # or manual install + add to PATH
flutter doctor
flutter doctor --android-licenses
cd tutorgo
flutter pub get
flutter run -d chrome    # or start Android emulator first
```

---

## Folder Structure

```
lib/
├── core/           # Theme, colors, typography, utils
├── data/           # Dummy data & AI service
├── presentation/   # Screens, components, widgets
├── routes/         # Navigation routes
└── main.dart       # Entry point
```

For full architecture details, see [docs/knowledge_base.md](docs/knowledge_base.md).
