# NextStepLearning - Technical Knowledge Base

## 1. Project Overview

| Field | Value |
|-------|-------|
| **Package Name** | next_step_learning |
| **App Name** | NextStepLearning |
| **Description** | AI-powered tutoring platform connecting students with tutors |
| **Flutter SDK** | ^3.9.2 |
| **Version** | 1.0.0+1 |
| **Initial Route** | Splash Screen (auth check) |
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
│   │   ├── providers/
│   │   │   └── auth_provider.dart    # Auth state (ChangeNotifier)
│   │   ├── services/
│   │   │   ├── auth_service.dart     # HTTP client for auth endpoints
│   │   │   ├── user_service.dart     # User profile CRUD
│   │   │   ├── session_service.dart  # Session management
│   │   │   ├── notification_service.dart # Notifications
│   │   │   ├── payment_service.dart  # Payments
│   │   │   ├── chat_service.dart     # Messaging
│   │   │   └── call_service.dart     # Jitsi call integration
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
│   │   │   │   ├── payment_screen.dart        # Payment method selection
│   │   │   │   └── stripe_checkout_screen.dart # WebView Stripe checkout
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

- **AuthProvider** (`lib/data/providers/auth_provider.dart`)
  - Manages JWT auth state (accessToken, refreshToken, userId, role, email, fullName)
  - Persists tokens in `shared_preferences`
  - Auto-refreshes expired tokens on app start
  - Methods: `login()`, `register()`, `logout()`, `init()`, `tryRefreshToken()`
  - Access: `context.read<AuthProvider>()` or `context.watch<AuthProvider>()`

- **ThemeProvider** (`lib/core/theme/theme_manager.dart`)
  - Manages light/dark theme mode
  - Persists preference via `shared_preferences`
  - Access: `context.watch<ThemeProvider>()`

- **Screen-Level State:** StatefulWidget with TextEditingControllers
- **Data:** All screens wired to backend API via service classes

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
App Launch → Splash Screen → Check stored token
  ├─ Token exists → POST /auth/refresh
  │   ├─ Valid → Navigate to navbar (based on stored role)
  │   └─ Invalid → Clear tokens → Onboarding
  └─ No token → Onboarding → Login screen

Login Screen → POST /auth/login
  ├─ Success → Store tokens (SharedPreferences) → Navigate to navbar
  └─ Failure → Show error SnackBar

Register link → Register Screen → POST /auth/register
  ├─ Success → Store tokens → Profile Setup → PUT /api/users/me → Navbar
  └─ Failure → Show error message
```

**Token Storage Keys:**
- `auth_access_token`, `auth_refresh_token`, `auth_user_id`, `auth_role`, `auth_email`, `auth_full_name`, `auth_base_url`

**Status:** Fully implemented with JWT backend.

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

## 16. Mock Stripe Payment Gateway

### Architecture
The mock Stripe gateway simulates a real Stripe Checkout Session flow without requiring a Stripe account.

### Flow
```
1. Flutter calls POST /api/stripe/create-checkout-session
2. Backend creates a stripe_session + payment record (status: pending)
3. Returns { sessionId: "cs_mock_xxx", checkoutUrl: "..." }
4. Flutter opens checkoutUrl in WebView (StripeCheckoutScreen)
5. User sees mock card form (dark theme, Stripe-like UI)
6. User clicks "Pay" → form POSTs to /api/stripe/confirm/:sessionId
7. Backend marks session + payment as "completed"
8. Flutter polls GET /api/stripe/session/:sessionId → detects "completed"
9. Returns to app with success dialog
```

### Backend Endpoints
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/stripe/create-checkout-session` | Create checkout session |
| GET | `/api/stripe/checkout/:sessionId` | Serve mock HTML checkout page |
| POST | `/api/stripe/confirm/:sessionId` | Confirm payment (always succeeds) |
| GET | `/api/stripe/session/:sessionId` | Poll session status |

### Collections
- `stripe_sessions` — tracks checkout session lifecycle
- `payments` — existing collection, now supports `method: "stripe"` with `stripeSessionId` field

### Flutter Components
- `PaymentScreen` — method selection (stripe, easypaisa, jazzcash, bank_transfer)
- `StripeCheckoutScreen` — WebView wrapper that loads checkout URL and polls for completion

### Dependencies Added
- `webview_flutter: ^4.10.0` — renders the mock checkout page
- `url_launcher: ^6.2.5` — utility for URL handling

---

## 17. Real-Time Messaging & Video/Voice Calls

### Architecture

#### Messaging (Polling-Based)
- **Approach:** Flutter polls `GET /api/chats/:id/messages` every 2 seconds
- **No WebSocket** — acceptable latency (0-2s) for demo purposes
- **Backend:** Existing chat CRUD endpoints + new `POST /api/chats/start` endpoint
- **Frontend:** `ChatService` HTTP client connects screens to backend

#### Video/Voice Calls (Jitsi Meet)
- **SDK:** `jitsi_meet_flutter_sdk: ^12.1.3`
- **Server:** Free public `meet.jit.si` (no API keys, no account needed)
- **Room naming:** `tutorgo_<chatId>_<timestamp>` (unique per call)
- **Voice-only:** Join with `startWithVideoMuted: true`

### Messaging Flow
```
Student opens chat list → GET /api/chats/ → display chats with otherUser info
Student taps chat → GET /api/chats/:id/messages → display messages
Student types + sends → POST /api/chats/:id/messages → show sent
Timer polls every 2s → GET /api/chats/:id/messages → append new messages
Tutor's app polls → sees new message → displays it
```

### Video Call Flow
```
User taps video call icon in chat
  → Generate room: "tutorgo_<chatId>_<timestamp>"
  → POST message { type: "call_invite", text: roomName }
  → User joins Jitsi room (JitsiMeet.join)

Other user's app polls messages → sees call_invite
  → Show IncomingCallDialog
  → Accepts → joins same Jitsi room
  → Both connected with video/audio

Either hangs up → Jitsi fires conferenceTerminated
  → POST message { type: "call_ended" }
```

### Backend Endpoints
| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/chats/start` | Create or get existing chat between two users |
| GET | `/api/chats/:id/active-call` | Returns active call_invite (within 60s, not ended/declined) |

### Message Types
| Type | Purpose |
|------|---------|
| `text` | Regular text message |
| `session_request` | Session booking request with details |
| `session_response` | Response to session request |
| `call_invite` | Video/voice call initiated (text = room name) |
| `call_ended` | Call terminated |
| `call_declined` | Call declined by recipient |

### Flutter Components
| File | Purpose |
|------|---------|
| `lib/data/services/chat_service.dart` | HTTP client for chat API |
| `lib/data/services/call_service.dart` | Jitsi Meet integration + call invite logic |
| `lib/presentation/screens/student/student_messages_screen.dart` | Student chat list (backend data + polling) |
| `lib/presentation/screens/student/student_chats_conversation_screen.dart` | Student conversation (real messages + calls) |
| `lib/presentation/screens/tutor/tutor_chats_screen.dart` | Tutor chat list (backend data + polling) |
| `lib/presentation/screens/tutor/tutor_chat_conversation_screen.dart` | Tutor conversation (real messages + calls) |

### Chat Response Enrichment
- `GET /api/chats/` now returns `otherUser: { _id, name, profileImage, role }` on each chat
- Used by chat list screens to display the other participant's name/avatar

### Platform Requirements
| Platform | Requirement |
|----------|-------------|
| Android | minSdkVersion 24, camera/mic permissions |
| iOS | platform 15.1, NSCameraUsageDescription, NSMicrophoneUsageDescription |
| macOS | Not supported by Jitsi (demo on mobile/emulator only) |

### Dependencies Added
- `jitsi_meet_flutter_sdk: ^12.1.3` — free video/voice calls via public Jitsi servers

---

## 18. Known Limitations & Pending Work

| Area | Status | Notes |
|------|--------|-------|
| Backend Integration | Complete | All screens wired to real backend API |
| Authentication | JWT Implemented | Login, register, auto-refresh, token persistence |
| Payment Processing | Mock Stripe Implemented | Full checkout session flow with WebView |
| Data Persistence | SharedPreferences | Auth tokens + theme pref persisted |
| API Key Security | Hardcoded | Gemini key needs env variable migration |
| Session Management | JWT Token-Based | Auto-login on app restart via refresh token |
| Database | MongoDB (backend) | Backend uses MongoDB; no local DB needed |
| Video/Voice Calls | Jitsi Integrated | Free calls via meet.jit.si public server |
| Real-time Messaging | Polling-Based | 2s interval, connected to backend API |
| Push Notifications | Not Implemented | Needs FCM setup |
| AI Chat | Direct Gemini | Could migrate to backend /api/ai/ endpoints |

---

## 19. Recommended Next Steps for Backend Integration

1. **Firebase Setup**
   - Authentication (Email/Password, Google, Facebook)
   - Firestore for real-time data (chats, profiles, sessions)
   - Firebase Storage for profile images & documents
   - Cloud Messaging for push notifications

2. **Payment Gateway** ✅ (Mock Stripe Implemented)
   - Mock Stripe checkout session flow (create session → WebView checkout → confirm → poll status)
   - Backend: `/api/stripe/` routes with `stripe_sessions` collection
   - Frontend: `StripeCheckoutScreen` with WebView + polling
   - Methods: stripe, easypaisa, jazzcash, bank_transfer, cash
   - Always succeeds (demo mode) — swap for real Stripe SDK in production

3. **Real-time Communication** ✅ (Implemented)
   - Jitsi Meet for video/voice calls (free, no keys)
   - Polling-based messaging connected to backend REST API
   - IncomingCallDialog for receiving calls

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

---

## 20. TICKET-06 — Chat, Booking, Profiles, Images, Rates

### Profile images (`lib/core/utils/image_utils.dart`)
- Profile images are stored as **base64** strings on the user document's `profileImage`
  field (picked files are `base64Encode`d, ≤2MB). They are **not** URLs.
- `profileImageProvider(dynamic raw)` returns an `ImageProvider?` and transparently handles
  a network URL, a `data:` URI, or raw base64. Use it for **every** avatar; render a
  placeholder icon when it returns `null`.
- Student & tutor **profile setup** and **edit profile** screens now actually upload the
  avatar (setup previously picked it but never sent it). Edit screens have a camera-badge
  picker and preload the existing image.

### Chat wiring
- `tutor_profile_popup.dart` "Chat with Tutor" now calls `ChatService.startChat(tutorId)` to
  get the real `chat['_id']`, then opens `StudentChatConversation` with `chatId` + auth
  (previously it opened the tutor screen with no chatId, so chats never loaded/sent).
- Backend `chat_service._enrichChat` reads `fullName` (users have no `name` field).

### Booking (`lib/presentation/screens/student/book_session_sheet.dart`)
- Tutor popup has a **Book Session** button → sheet (day + start/end time) →
  `SessionService.createSession` → `POST /api/sessions/`. Booking shows in the student's
  Learning History and the tutor's Schedule (status `active`).

### Session enrichment (backend `session_service.getSessionsByUser`)
- Each active session is enriched with `studentName`, `studentImage`, `tutorName`,
  `tutorImage` (looked up from `users`). Consumed by: student dashboard "Your Tutors",
  Learning History, **My Tutors** (booked tutors only), tutor home "My Students" grid, and
  the tutor **My Students** list.

### `recurrence` is a Map, not a String
- Session `recurrence` = `{dayOfWeek(1-7), startTime, endTime, startDate}`. Never pass it to
  `Text()` or cast `as String`. Format via helpers (see `student_dashboard._formatRecurrence`,
  `tutor_schedule_screen`).

### Tutor hourly rate
- Field: `tutorProfile.pricePerHourPKR` (int). Editable in Tutor → Edit Profile
  ("Rate (PKR / hour)"). Student UI reads `pricePerHourPKR` (not `pricePerHour`) and labels it
  **PKR** in discovery/View-All cards, the tutor popup, and the booking sheet.

### Editable email
- Both edit-profile screens allow changing the email (login identifier). Backend
  `PUT /api/users/me` returns **409 "That email is already in use"** on a unique-email conflict.

### Backend resilience (Atlas idle disconnect)
- `Database.ensureConnected()` reopens a dropped Mongo connection; `isConnected` getter added.
- The notification scheduler tick is fully guarded (try/catch + `ensureConnected`) so a
  transient DB error can never crash the process via its `Timer`.
- `server.dart` has a `_dbRecoveryMiddleware` that reconnects before each request.

### Environment / run note (supersedes older claims)
- The app **requires the backend** (`tutorgo/backend`, `http://localhost:8080`, MongoDB).
- `mongo_dart` 0.10.9 fails Atlas `mongodb+srv://` TLS handshakes; use the expanded
  non-SRV `mongodb://host1,host2,host3/db?replicaSet=...&tls=true` URI in `backend/.env`.
- Voice/video calls (Jitsi) have **no Windows-desktop** implementation
  (`MissingPluginException`); use Android/iOS/web for calls.

---

## 21. TICKET-08 — Courses (selection, discovery filter, booking)

### Course list (`lib/core/constants/courses.dart`)
- `kCourses` is the canonical fixed course list. Students pick only from it; **tutors** pick
  from it **and can add custom courses**.
- Student courses → `studentProfile.selectedCourses`. Tutor courses → `tutorProfile.subjects`
  (may contain custom values outside `kCourses`).
- **Gotcha:** student profile setup previously saved courses under `interests` — it must be
  `selectedCourses` (the field discovery/edit read).

### Edit Profile
- **Student** Edit Profile: multi-select course chips. The chip list = `kCourses` +
  every course tutors currently teach (custom included) + anything already selected, so a
  student can pick a tutor's custom course "as long as a tutor still offers it".
- **Tutor** Edit Profile: multi-select chips (fixed list + existing customs) plus an
  "Add a custom course" field. Custom courses become visible to students.

### Courses page (tutor discovery)
- Loads the student's `selectedCourses`. Filter chips: **My Courses** (default when the
  student has courses; union of their courses) · **All Courses** (everyone) · one chip per
  course, where the course chips = student courses + **all tutor-taught courses** (so custom
  courses are filterable). `_sectionVisible` decides which subject sections render.
- Each tutor card carries `courses` (the tutor's full subject list) for the booking sheet.
- Prices shown as **PKR** using `tutorProfile.pricePerHourPKR`.

### Booking
- `BookSessionSheet` shows a **course dropdown** (options = the tutor's `courses`, default =
  the tapped subject) so the session records a real course. Sessions booked before TICKET-08
  keep `subject: "General"`.

### Tutor dashboards
- Tutor Home "My Students" lists one tile per **(student, course)** with the course name; the
  "Students" stat counts distinct students.

### Tutor Schedule — reschedule & cancel
- Each session card has **Reschedule** (bottom sheet → `SessionService.updateSession` with a
  new `recurrence`) and **Cancel** (Yes/No confirm dialog → `SessionService.cancelSession`,
  which also cancels upcoming instances). Both refresh the schedule.

---

## 22. TICKET-09 — Display name = NextStepLearning

- The user-facing **display name is "NextStepLearning"** (MaterialApp title, Windows window
  title, onboarding/role/register copy, README, and docs).
- **Identifiers are intentionally unchanged** (backend/build must not break): Mongo DB
  `tutorgo_db`, backend package `tutorgo_backend`, Flutter package `next_step_learning`, the
  `tutorgo.exe` binary, and the Dart `TutorGo` widget class in `main.dart`.
- Onboarding: subtitle "…get best quality education anytime, anywhere."; the content is a
  centered `ConstrainedBox(maxWidth: 460)` with a smaller centered "Get Started" button so it
  lays out correctly on wide/desktop windows.

---

## 23. TICKET-10 — Notifications (real-time messages + class reminders)

Local notifications **while the app is running** (no Firebase). Dependency:
`flutter_local_notifications` (^18) + `shared_preferences`.

### Pieces (all under `lib/`)
- `data/services/notification_prefs.dart` — device-local toggles `messagesEnabled` /
  `remindersEnabled` (shared_preferences, default on).
- `data/services/local_notification_service.dart` — singleton wrapping the plugin;
  `showMessage(...,payload)` / `showReminder(...)`, each gated by the matching pref.
  `onChatTap` fires with the payload when an OS notification is tapped.
- `data/services/notification_poller.dart` — singleton started by the logged-in **navbars**
  (`start(baseUrl, token, userId, role)`), stopped on their dispose. Every 8s it polls
  `GET /api/notifications/` (new `session_reminder` records) and `GET /api/chats/` (new
  incoming `lastMessage`). Primes a baseline on start and de-dupes so nothing fires twice.
  `NotificationPoller.activeChatId` (set by the conversation screens) suppresses banners for
  the chat you're viewing. `openChat(chatId)` navigates to the right conversation.
- `core/utils/app_globals.dart` — `navigatorKey` (wired on `MaterialApp`) + `showInAppBanner`
  (transient top overlay, optional `onTap`), used because services have no BuildContext.

### Behaviour
- New message (not from you, not the open chat) → in-app banner (+ OS notif on mobile),
  tappable → opens that conversation.
- Class-reminder record → banner (+ OS notif on mobile).
- Toggles in both Notifications settings screens persist and gate the notifications.

### Platform limits
- **Windows/web**: no OS-toast implementation in the plugin → skipped; the **in-app banner**
  is the popup there. Real OS notifications fire on Android/iOS/macOS/Linux.
- App-fully-closed push (FCM/APNs) is out of scope.

---

## 24. TICKET-11 — Forgot Password (account recovery)

- No email server: identity is verified by **email + the phone stored on the account**, then
  the user sets a new password. Role-agnostic (students & tutors).
- Backend `POST /auth/reset-password` `{email, phone, newPassword}`: finds by email, checks
  `phone` matches, bcrypt-hashes and saves. Generic error ("No account matches that email and
  phone number") so it doesn't leak which field is wrong.
- Frontend: `AuthService.resetPassword(...)`, `ForgotPasswordScreen` (route
  `/forgot-password`), and a "Forgot Password?" link on the login screen.

## 25. TICKET-12 — Deferred account creation + setup dropdowns

- **Register no longer creates the account.** It collects name/email/password/role and
  `pushNamed`s the setup route with those as `arguments`. The account is created only when the
  profile is completed — the setup screen calls `auth.register(...)` then `updateProfile(...)`.
  `app_pages` passes the args into `StudentProfileSetup` / `TutorProfileSetup` (optional
  `name/email/password`; when null the screen assumes an already-signed-in user).
- Because registration is deferred, the **email-uniqueness check happens at "Complete"**.
- **Tutor setup**: Experience dropdown (1..10, "10+"); Qualification dropdown (Bachelors /
  Masters / PhD); **all four documents required** (CNIC front/back, teaching certificate,
  degree) before completion. **Student setup**: Grade/Class dropdown (Matriculation / College
  / Bachelors / Masters). Both setups have an AppBar **back** arrow to return to Register.

## 26. TICKET-13 — Password-confirmed delete + required student fields

- **Delete account** (both roles): `DELETE /api/users/me` now requires `{password}` in the
  body; backend `UserService.verifyPassword` checks it (bcrypt) before `deleteUser`. Wrong/
  absent password → 401/400, nothing deleted. Frontend `UserService.deleteAccount(password)`
  returns null on success or the error string. The (shared) delete screen adds a Yes/No confirm
  and, on success, logs out → onboarding. Tutor profile gained a "Delete Account" tile
  (route `/delete_account`, reuses `StudentDeleteAccountScreen`).
- **Student setup validation**: Complete is blocked (with a "Please provide: X" message) until
  Full Name, Phone, Age, Grade/Class, and ≥1 interest are provided (Address optional). Combined
  with deferred registration, an incomplete student profile creates no account.

---

## 27. TICKET-14 — Quizzes & assignments

Two backend collections (one doc per task, submission embedded): `quizzes`
`{tutorId, studentId, title, subject, questions:[{text,options[],correctIndex}], submission}`
and `assignments` `{tutorId, studentId, title, subject, description, submission:{fileBase64,
fileName}, marks, feedback, gradedAt}`. Services/routes in `backend/lib/{services,routes}`.

- **Quizzes (MCQ, auto-graded)**: `POST /api/quizzes`, `GET /api/quizzes` (role-scoped;
  correct answers stripped for students), `POST /api/quizzes/{id}/submit` (auto score).
- **Assignments (file upload)**: `POST /api/assignments`, `GET /api/assignments`,
  `POST /api/assignments/{id}/submit` (base64 file), `PUT /api/assignments/{id}/grade`.
- Frontend: `QuizService`, `AssignmentService`; tutor `CreateQuizScreen` / `CreateAssignmentScreen`
  + grade dialog inside the (now stateful) `TutorStudentDetailScreen` (Message opens the chat,
  real Session History, studentId passed through). Student sees tasks **on the Home dashboard**
  ("Quizzes & Assignments", course + tutor labelled) — Take a quiz, Upload an assignment; also
  `StudentTasksScreen`, `TakeQuizScreen`.
- Also: Windows exe metadata (Runner.rc ProductName/FileDescription) set to NextStepLearning
  (binary stays `tutorgo.exe`; an existing taskbar pin must be re-pinned to update its label).

## 28. TICKET-15 — Proper payment (student → admin) & tutor payout

- Student deposit: `POST /api/payments/deposit` `{amountPKR, method, senderName, senderAccount}`
  → `deposits` collection. `SendPaymentScreen` collects amount + gateway (easypaisa/jazzcash/
  bank_transfer/card), shows the admin destination account, validates sender details.
- Tutor payout details saved to `tutorProfile.payoutAccount` via `updateProfile`
  (`PayoutSettingsScreen`). No real gateway — flow is simulated but records the transaction.

## 29. TICKET-16 — Banks, phone field, payout view/edit

- `core/constants/banks.dart` (Pakistani banks) + `core/constants/country_codes.dart`.
- `PhoneField` (`presentation/components/inputs/phone_field.dart`): country-code dropdown
  (default +92) + digits-only, max-10 number; binds the full number (e.g. `+923001234567`) to
  the passed controller. Used across setup/edit/forgot-password/payment/payout phone inputs.
- Payout Settings: bank dropdown for Bank Transfer, phone for wallets. Payment Methods (tutor)
  is view-only.
- **Backend read-strip fix**: `getUserById` now returns the raw doc (minus password) instead of
  round-tripping through `UserModel`, so extra sub-fields (`tutorProfile.payoutAccount`,
  `studentProfile.selectedCourses`) survive; `updateUser` no longer strips `email`.
