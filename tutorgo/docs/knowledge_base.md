# TutorGo - Technical Knowledge Base

## 1. Project Overview

| Field | Value |
|-------|-------|
| **Package Name** | next_step_learning |
| **App Name** | TutorGo |
| **Description** | AI-powered tutoring platform connecting students with tutors |
| **Flutter SDK** | ^3.9.2 |
| **Version** | 1.0.0+1 |
| **Initial Route** | Onboarding Screen |
| **Target Platforms** | iOS, Android, Web |

---

## 2. Project Structure

```
tutorgo/
├── lib/
│   ├── core/                          # Core utilities & theme
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # Light & dark theme definitions
│   │   │   ├── colors.dart           # Color palette constants
│   │   │   ├── spacing.dart          # Spacing constants
│   │   │   ├── typography.dart       # Text styles (Google Fonts - Inter)
│   │   │   └── theme_manager.dart    # Theme provider (shared_preferences)
│   │   └── utils/
│   │       ├── size_config.dart      # Responsive design utilities
│   │       └── helpers.dart          # Utility helper functions
│   │
│   ├── data/                          # Data layer
│   │   └── dummy/
│   │       ├── dummy_messages.dart   # Placeholder message data
│   │       ├── dummy_tutors.dart     # Placeholder tutor data
│   │       └── services/
│   │           └── ai_service.dart   # Google Gemini AI integration
│   │
│   ├── presentation/                  # UI layer
│   │   ├── components/
│   │   │   ├── animations/
│   │   │   │   ├── fade_in.dart
│   │   │   │   └── onboarding_animation.dart
│   │   │   ├── buttons/
│   │   │   │   └── app_primary_button.dart
│   │   │   ├── cards/
│   │   │   │   └── tutor_card.dart
│   │   │   ├── inputs/
│   │   │   │   └── app_text_field.dart
│   │   │   └── misc/
│   │   │       ├── avatar.dart
│   │   │       ├── course_chip.dart
│   │   │       └── rating_stars.dart
│   │   │
│   │   ├── screens/
│   │   │   ├── aichat/
│   │   │   │   └── ai_chat_screen.dart
│   │   │   ├── call/
│   │   │   │   └── call_screen.dart
│   │   │   ├── login/
│   │   │   │   └── login_screen.dart
│   │   │   ├── onboarding/
│   │   │   │   └── onboarding_screen.dart
│   │   │   ├── payment/
│   │   │   │   └── payment_screen.dart
│   │   │   ├── rating/
│   │   │   │   └── rating_screen.dart
│   │   │   ├── roles/
│   │   │   │   └── role_selection_screen.dart
│   │   │   ├── student/              # 19+ student screens
│   │   │   │   ├── student_dashboard.dart
│   │   │   │   ├── student_messages_screen.dart
│   │   │   │   ├── student_profile_screen.dart
│   │   │   │   ├── student_profile_setup.dart
│   │   │   │   ├── student_edit_profile_screen.dart
│   │   │   │   ├── student_notifications_screen.dart
│   │   │   │   ├── student_privacy_screen.dart
│   │   │   │   ├── student_language_screen.dart
│   │   │   │   ├── student_tutors_screen.dart
│   │   │   │   ├── student_learning_history_screen.dart
│   │   │   │   ├── student_payment_methods_screen.dart
│   │   │   │   ├── student_help_center_screen.dart
│   │   │   │   ├── student_support_screen.dart
│   │   │   │   ├── student_delete_account_screen.dart
│   │   │   │   ├── student_chats_conversation_screen.dart
│   │   │   │   ├── tutor_discovery_screen.dart
│   │   │   │   ├── tutor_profile_popup.dart
│   │   │   │   ├── view_all_tutors_screen.dart
│   │   │   │   └── request_bottomsheet.dart
│   │   │   └── tutor/               # 21+ tutor screens
│   │   │       ├── tutor_home_screen.dart
│   │   │       ├── tutor_dashboard.dart
│   │   │       ├── tutor_chats_screen.dart
│   │   │       ├── tutor_chat_conversation_screen.dart
│   │   │       ├── tutor_profile_screen.dart
│   │   │       ├── tutor_profile_setup.dart
│   │   │       ├── tutor_edit_profile_screen.dart
│   │   │       ├── tutor_schedule_screen.dart
│   │   │       ├── tutor_schedule_details_screen.dart
│   │   │       ├── tutor_students_screen.dart
│   │   │       ├── tutor_student_detail_screen.dart
│   │   │       ├── tutor_video_call_screen.dart
│   │   │       ├── tutor_voice_call_screen.dart
│   │   │       ├── payment_methods_screen.dart
│   │   │       ├── payout_settings_screen.dart
│   │   │       ├── notifications_settings_screen.dart
│   │   │       ├── privacy_settings_screen.dart
│   │   │       ├── language_selection_screen.dart
│   │   │       ├── help_screen.dart
│   │   │       └── tutor_contact_support_screen.dart
│   │   │
│   │   └── widgets/
│   │       ├── app_bar_custom.dart
│   │       ├── student_navbar.dart
│   │       └── tutor_navbar.dart
│   │
│   ├── routes/
│   │   ├── app_routes.dart           # Route constant definitions
│   │   └── app_pages.dart            # Route generation logic
│   │
│   └── main.dart                     # App entry point
│
├── assets/
│   └── images/
│       ├── logo.png
│       ├── student.png
│       └── teacher.png
│
├── docs/                              # Documentation
│   └── knowledge_base.md
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## 3. Dependencies

### UI & Design
| Package | Version | Purpose |
|---------|---------|---------|
| google_fonts | ^6.2.1 | Custom typography (Inter font) |
| lucide_flutter | ^1.16.0 | Modern icon pack |
| cupertino_icons | ^1.0.8 | iOS-style icons |
| flutter_svg | ^2.0.10+1 | SVG rendering |
| rive | ^0.13.4 | Animation library |

### State Management & Routing
| Package | Version | Purpose |
|---------|---------|---------|
| provider | ^6.1.5+1 | State management (theme) |
| get | ^4.6.6 | GetX framework (imported) |
| shared_preferences | ^2.5.4 | Local persistent storage |

### Animations
| Package | Version | Purpose |
|---------|---------|---------|
| lottie | ^3.1.2 | Lottie animation support |
| flutter_animate | ^4.5.0 | Widget animation framework |

### Responsiveness
| Package | Version | Purpose |
|---------|---------|---------|
| flutter_screenutil | ^5.9.0 | Responsive UI utilities |

### Media & Files
| Package | Version | Purpose |
|---------|---------|---------|
| cached_network_image | ^3.3.1 | Image caching |
| image_picker | ^1.1.2 | Gallery/camera image selection |
| camera | ^0.11.0+2 | Camera access |
| file_picker | ^10.3.7 | File selection |
| permission_handler | ^11.3.1 | Permission management |

### API & Utilities
| Package | Version | Purpose |
|---------|---------|---------|
| http | ^1.6.0 | HTTP client (Gemini API) |
| intl | ^0.19.0 | Internationalization & date formatting |

---

## 4. Architecture & Patterns

### State Management

**Primary:** Provider + ChangeNotifier

- **ThemeProvider** (`lib/core/theme/theme_manager.dart`)
  - Manages light/dark theme mode
  - Persists preference via `shared_preferences`
  - Access: `context.watch<ThemeProvider>()`

- **Screen-Level State:** StatefulWidget with TextEditingControllers
- **Data:** Currently dummy/hardcoded, ready for API integration

### Navigation & Routing

**Mechanism:** Named routes with `onGenerateRoute`

**Route Flow:**
```
Onboarding → Login → Role Selection → Profile Setup → Dashboard (Navbar)
```

**Key Routes:**
```dart
// Onboarding Flow
/onboarding
/login
/role-selection
/student-setup
/tutor-setup

// Navigation Shells
/student-navbar    // 4 tabs: Home, Messages, Courses, Profile
/tutor-navbar      // 5 tabs: Home, Messages, Schedule, Students, Profile

// Student Routes
/student-dashboard
/student/chat
/studentProfile
/student_edit_profile
/student_notifications
/student_privacy
/student_language
/student_tutors
/student_history
/student_help_center
/student_support
/student_payment_methods
/student_subscription
/student_delete_account
/student_view_all_tutors

// Tutor Routes
/tutor-chats
/tutor-chat-conversation
/tutor-video-call
/tutor-voice-call
/tutor-schedule-details
/tutor-students
/tutor-student-details
/edit-profile
/payment-methods
/payout-settings
/notifications
/privacy-settings
/language-settings
/help-center
/contact-support

// AI
/ai-chat-screen    // Supports both student & tutor roles
```

---

## 5. Design System

### Color Palette

```dart
Primary:       #3B82F6 (Blue)
Primary Dark:  #1E3A8A
Text Dark:     #111827
Text Medium:   #374151
Text Light:    #6B7280
Border:        #E5E7EB
Background:    #F9FAFB
Success:       #10B981
Warning:       #F59E0B
Error:         #EF4444
Accent:        #A3E635 (Lime)
```

### Typography (Google Fonts - Inter)

| Style | Size | Weight |
|-------|------|--------|
| h1 | 28px | w700 |
| h2 | 22px | w600 |
| h3 | 18px | w600 |
| body16 | 16px | w400 |
| body14 | 14px | w400 |
| body12 | 12px | w400 |

### Spacing Scale

```dart
s4, s8, s12, s16, s20, s24, s28, s32, s40
```

### Theme Modes

- **Light:** Material 3, white backgrounds, colored accents
- **Dark:** Deep navy backgrounds (#020617, #0F172A)
- System-based detection default with user override persistence

### Design Tokens

- Border radius: 14-20px (rounded design)
- Shadows: 0.04-0.25 opacity, 10-20px blur
- Input borders: Outline style with dynamic focus color

---

## 6. API & Backend Integration

### Google Gemini AI Service

**Location:** `lib/data/dummy/services/ai_service.dart`

**Configuration:**
- API Key: Hardcoded (should migrate to env variables)
- Models: gemini-2.0-flash, gemini-2.5-flash, gemini-2.5-pro (fallback chain)
- Temperature: 0.7
- TopP: 0.8
- Max Output Tokens: 1024

**Methods:**
```dart
static Future<String> sendMessage({
  required String message,
  required bool isStudent,
})

static Future<List<String>> listAvailableModels()
static Future<bool> testConnection()
```

**Role-Based Prompting:**
- Student prompt: Educational tutor persona focused on step-by-step learning
- Tutor prompt: Teaching assistant persona for lesson planning

**Error Handling:**
- Model fallback chain on failure
- Connection testing
- Helpful error messages for API issues

---

## 7. Data Models

### User Profile (Student)
```dart
{
  "name": String,
  "email": String,
  "phone": String,
  "age": int,
  "grade": String,
  "address": String,
  "profileImage": File?,
  "selectedCourses": List<String>
}
```

### User Profile (Tutor)
```dart
{
  "name": String,
  "email": String,
  "phone": String,
  "experience": int,
  "qualification": String,
  "profileImage": File?,
  "documents": {
    "cnicFront": File,
    "cnicBack": File,
    "certificate": File,
    "degree": File
  },
  "selectedSubjects": List<String>
}
```

### Tutor Card
```dart
{
  "name": String,
  "subject": String,
  "rating": double,
  "price": int,
  "image": String (URL)
}
```

### Chat Message
```dart
{
  "text": String,
  "isMe": bool,
  "time": String,
  "status": String  // "sent", "delivered", "seen"
}
```

### Schedule Session
```dart
{
  "time": String,
  "subject": String,
  "student": String,
  "color": Color
}
```

---

## 8. Features

### Student Features
- Browse & discover tutors by subject
- Book tutoring sessions
- Real-time messaging with tutors
- AI tutor for homework help (Gemini)
- Learning history tracking
- Payment methods management
- Profile settings & customization
- Notifications, privacy, language preferences
- Account deletion

### Tutor Features
- Student roster management
- Weekly schedule view (Mon-Sun)
- Session tracking & details
- One-on-one messaging with students
- Video & voice call screens (UI ready)
- Payment method & payout settings
- Document verification setup
- Subject specialization selection

### AI Features
- Role-based chat interface (student/tutor)
- Google Gemini integration with model fallback
- Educational prompts tailored to role
- Real-time conversational interface

---

## 9. Responsive Design

### SizeConfig System

**Base Device:** iPhone 13 (390x844)

```dart
SizeConfig.w(width)   // Scale width proportionally
SizeConfig.h(height)  // Scale height proportionally
```

Uses percentage-based blocks (1% of screen dimensions).

**Approach:** Mobile-first continuous scaling, no breakpoints.

---

## 10. Animations

### Libraries Used
- **flutter_animate** - Primary animation framework
- **rive** - Complex animations
- **lottie** - JSON-based animations

### Animation Patterns
- FadeIn wrapper: fade + slide with configurable delay (500ms default)
- Button animations: fade + slide on mount
- Navigation: Animated positioned bubble for active tab
- Schedule: AnimatedContainer for day selection
- Nav labels: Animated opacity

---

## 11. Authentication Flow

```
┌─────────────┐    ┌─────────────┐    ┌──────────────┐    ┌───────────────┐    ┌──────────┐
│  Onboarding │───>│    Login     │───>│Role Selection│───>│ Profile Setup │───>│Dashboard │
│   Screen    │    │   Screen    │    │   Screen     │    │   Screen      │    │  (Navbar)│
└─────────────┘    └─────────────┘    └──────────────┘    └───────────────┘    └──────────┘
                   │                  │                   │
                   ├─ Email/Password  ├─ Student          ├─ Student: name, email,
                   ├─ Google OAuth    └─ Tutor               phone, age, grade, courses
                   └─ Facebook OAuth                      └─ Tutor: name, email, phone,
                                                             experience, qualification,
                                                             documents, subjects
```

**Status:** UI complete, backend integration pending.

---

## 12. Navigation Structure

### Student Navbar (4 Tabs)
| Tab | Icon | Screen |
|-----|------|--------|
| Home | House | StudentDashboard |
| Messages | MessageCircle | StudentMessagesScreen |
| Courses | BookOpen | TutorDiscoveryScreen |
| Profile | User | StudentProfileScreen |

### Tutor Navbar (5 Tabs)
| Tab | Icon | Screen |
|-----|------|--------|
| Home | House | TutorHomeScreen |
| Messages | MessageCircle | TutorChatsScreen |
| Schedule | Calendar | TutorScheduleScreen |
| Students | Users | TutorStudentsScreen |
| Profile | User | TutorProfileScreen |

---

## 13. Key File Locations

| Feature | File Path |
|---------|-----------|
| App Entry | `lib/main.dart` |
| Theme System | `lib/core/theme/*` |
| Routing | `lib/routes/*` |
| AI Service | `lib/data/dummy/services/ai_service.dart` |
| Student Dashboard | `lib/presentation/screens/student/student_dashboard.dart` |
| Tutor Home | `lib/presentation/screens/tutor/tutor_home_screen.dart` |
| AI Chat | `lib/presentation/screens/aichat/ai_chat_screen.dart` |
| Navigation Bars | `lib/presentation/widgets/*_navbar.dart` |
| Reusable Components | `lib/presentation/components/*` |
| Responsive Utils | `lib/core/utils/size_config.dart` |

---

## 14. Development Guidelines

### Adding a New Screen

1. Create screen file in appropriate category (`student/` or `tutor/`)
2. Add route constant to `lib/routes/app_routes.dart`
3. Add case to `AppPages.onGenerateRoute()` in `lib/routes/app_pages.dart`
4. Navigate using `Navigator.pushNamed(context, AppRoutes.newRoute)`
5. Use `Theme.of(context)` for colors
6. Use `SizeConfig.w()` / `SizeConfig.h()` for sizing

### Code Conventions

- Stateless widgets when no local state needed
- StatefulWidget for forms, animations, dynamic content
- Private methods prefixed with `_`
- Named parameters for widget constructors
- Widget composition over nested builders
- Theme-aware colors via `Theme.of(context)`

---

## 15. Project Stats

| Metric | Value |
|--------|-------|
| Total Dart Files | ~76 |
| Screens | 47+ |
| Reusable Components | 8+ |
| Lines of Code | ~8000+ |
| Dependencies | 23 |
| Target Platforms | iOS, Android, Web |

---

## 16. Known Limitations & Pending Work

| Area | Status | Notes |
|------|--------|-------|
| Backend Integration | Pending | All data currently dummy/local |
| Authentication | UI Only | Login flow has no backend |
| Payment Processing | UI Only | Payment screens are placeholders |
| Data Persistence | Minimal | Only theme pref saved locally |
| API Key Security | Hardcoded | Needs env variable migration |
| Session Management | None | App starts at onboarding each time |
| Database | None | No local DB (ready for Firebase/SQLite) |
| Video/Voice Calls | UI Only | Needs Agora/Twilio integration |
| Push Notifications | Not Implemented | Needs FCM setup |

---

## 17. Recommended Next Steps for Backend Integration

1. **Firebase Setup**
   - Authentication (Email/Password, Google, Facebook)
   - Firestore for real-time data (chats, profiles, sessions)
   - Firebase Storage for profile images & documents
   - Cloud Messaging for push notifications

2. **Payment Gateway**
   - Stripe or Razorpay integration
   - Subscription management
   - Tutor payout system

3. **Real-time Communication**
   - Agora RTC or Twilio for video/voice calls
   - WebSocket or Firestore for live messaging

4. **State Management Scale-Up**
   - Consider Riverpod or BLoC for complex state
   - Add proper repository pattern
   - Implement proper model classes with serialization

5. **Security**
   - Move API keys to environment variables
   - Add input validation
   - Implement token-based session management

6. **Localization**
   - `intl` package already imported
   - Add ARB files for multi-language support
