# TICKET-04: Remove Mock Flows & Wire All Screens to Backend API

## Type
Feature / Tech Debt

## Priority
Critical

## Status
Done

## Summary
The app currently functions as a UI prototype — login has no real authentication, most screens display hardcoded dummy data, and navigation guards are absent. This ticket removes all mock flows and connects every screen to the existing backend API so the app functions as a real, demo-ready application on physical devices.

**Note:** Stripe payment integration is already functional and should remain as-is.

## Background
- Backend is 95% production-ready: full JWT auth, user management, sessions, notifications, payments, AI conversations
- Frontend is ~30% connected: only chat screens (TICKET-03) and Stripe checkout use real API calls
- No authentication is enforced — any user can tap through to any screen
- All profile, dashboard, schedule, tutor discovery, and settings screens use hardcoded data
- The navbar instantiates screens without passing auth credentials
- Profile setup collects data but discards it (no backend submission)

## Current State vs Target State

| Area | Current (Mock) | Target (Real) |
|------|---------------|---------------|
| Login | Accepts anything, navigates forward | Calls POST /auth/login, stores JWT |
| Registration | No flow exists | Calls POST /auth/register with role |
| Session persistence | None — fresh start every launch | Token stored, auto-login on restart |
| Auth guards | None — all routes accessible | Redirect to login if no valid token |
| Student dashboard | Hardcoded "Hi, Student", mock stats | Real user name, real session/tutor counts |
| Tutor dashboard | Hardcoded "Hello Ali", mock stats | Real earnings, student count, schedule |
| Tutor discovery | 9 hardcoded tutors | GET /api/users/tutors with filtering |
| Schedule | Hardcoded weekly map | GET /api/sessions + instances |
| Student list (tutor) | 3 hardcoded students | GET /api/sessions → extract unique students |
| Profile screens | "Student Name" / "Ali Khan" | GET /api/users/me |
| Edit profile | Save button does nothing | PUT /api/users/me |
| Profile setup | Data discarded on continue | POST registration + PUT /api/users/me |
| Notifications | Hardcoded toggles | GET /api/notifications |
| Learning history | 3 hardcoded items | GET /api/sessions (completed) |
| Logout | Button does nothing | Clear tokens, navigate to login |
| Delete account | Button does nothing | DELETE /api/users/me (new endpoint) |
| AI chat | Direct Gemini calls | Use backend /api/ai/conversations |
| Payment history | Not shown | GET /api/payments + /api/payments/summary |

## Architecture

### Part A: Auth Infrastructure (Foundation)

#### 1. Create `AuthService` (Flutter HTTP client)
**File:** `lib/data/services/auth_service.dart`

```dart
class AuthService {
  final String baseUrl;

  Future<AuthResponse> register(String email, String password, String fullName, String role, {String? phone});
  Future<AuthResponse> login(String email, String password);
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<void> logout(); // Clear local tokens
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String role;
  final String email;
}
```

#### 2. Create `AuthProvider` (State Management)
**File:** `lib/data/providers/auth_provider.dart`

- Extends `ChangeNotifier`
- Stores: `accessToken`, `refreshToken`, `userId`, `role`, `email`, `fullName`
- Persists tokens in `shared_preferences` (keys: `auth_access_token`, `auth_refresh_token`, `auth_user_id`, `auth_role`)
- Methods: `login()`, `register()`, `logout()`, `tryAutoLogin()`, `isAuthenticated` getter
- Auto-refreshes token when expired (401 response triggers refresh)
- Injected at app root via `ChangeNotifierProvider`

#### 3. Update `main.dart`
- Wrap app in `ChangeNotifierProvider<AuthProvider>`
- Change initial route logic:
  - If `authProvider.tryAutoLogin()` succeeds → navigate to appropriate navbar
  - Otherwise → navigate to onboarding/login

#### 4. Add Auth Guard
- In `AppPages.onGenerateRoute`, check `AuthProvider.isAuthenticated`
- If not authenticated and route is protected → redirect to login
- Protected routes = everything except `/onboarding`, `/login`, `/role-selection`

### Part B: Login & Registration Flow

#### 1. Rewrite `LoginScreen`
- Email + password fields with validation
- "Login" button calls `authProvider.login(email, password)`
- On success: navigate to appropriate navbar based on `authProvider.role`
- On failure: show error snackbar (wrong credentials, network error)
- Add "Don't have an account? Register" link → navigate to registration
- Remove social login buttons (or keep as disabled with "Coming soon")

#### 2. Create `RegisterScreen`
**File:** `lib/presentation/screens/login/register_screen.dart`

- Fields: Full Name, Email, Password, Confirm Password
- Role selection (student/tutor) — can reuse existing role selection UI
- Calls `authProvider.register()`
- On success: navigate to profile setup
- On failure: show error (email exists, validation errors)

#### 3. Update `RoleSelectionScreen`
- Only shown during registration flow (not login)
- Selected role passed to register API call

#### 4. Rewrite Profile Setup Screens
- **Student setup**: After registration, calls `PUT /api/users/me` with collected data
- **Tutor setup**: After registration, calls `PUT /api/users/me` with profile + uploads documents
- On success: navigate to navbar
- Data is actually persisted to backend

### Part C: Create Missing Frontend Services

#### 1. `UserService`
**File:** `lib/data/services/user_service.dart`

```dart
class UserService {
  Future<Map<String, dynamic>> getMyProfile();
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getTutors({String? subject, int page = 1, int limit = 20});
  Future<Map<String, dynamic>> getTutor(String id);
}
```

#### 2. `SessionService`
**File:** `lib/data/services/session_service.dart`

```dart
class SessionService {
  Future<Map<String, dynamic>> createSession(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getMySessions();
  Future<List<Map<String, dynamic>>> getSessionInstances(String sessionId);
  Future<Map<String, dynamic>> updateSession(String id, Map<String, dynamic> data);
  Future<void> cancelSession(String id);
}
```

#### 3. `NotificationService`
**File:** `lib/data/services/notification_service.dart`

```dart
class NotificationService {
  Future<List<Map<String, dynamic>>> getNotifications({bool unreadOnly = false, int page = 1});
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
```

#### 4. `PaymentService`
**File:** `lib/data/services/payment_service.dart`

```dart
class PaymentService {
  Future<List<Map<String, dynamic>>> getPayments({int page = 1, int limit = 20});
  Future<Map<String, dynamic>> getPaymentSummary();
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> data);
}
```

#### 5. Update `AiService`
- Replace direct Gemini calls with backend `/api/ai/conversations` endpoints
- Backend handles Gemini integration internally (if configured) or stores conversation history

### Part D: Wire Student Screens

#### 1. `StudentNavbar`
- Access `AuthProvider` via `Provider.of<AuthProvider>(context)`
- Pass `baseUrl`, `token`, `userId` to all child screens that need them
- OR: child screens read from AuthProvider directly

#### 2. `StudentDashboard`
- Fetch user profile → display real name ("Hi, {firstName}")
- Fetch sessions → show upcoming class count
- Fetch tutors list → show "My Tutors" section
- Show real stats: total sessions, study time (from completed sessions)

#### 3. `TutorDiscoveryScreen` / `ViewAllTutorsScreen`
- Call `UserService.getTutors()` instead of hardcoded list
- Implement real search/filter (backend supports subject filtering)
- "Chat with Tutor" button calls `ChatService.startChat(tutorId)`

#### 4. `StudentProfileScreen`
- Fetch `UserService.getMyProfile()` → display real name, email, stats
- Stats from: sessions completed, tutors interacted with, total study hours

#### 5. `StudentEditProfileScreen`
- Pre-fill from `UserService.getMyProfile()`
- Save button calls `UserService.updateProfile(data)`
- Show success/error feedback

#### 6. `StudentLearningHistoryScreen`
- Fetch `SessionService.getMySessions()` → filter completed
- Display real session history with dates and subjects

#### 7. `StudentNotificationsScreen`
- Fetch `NotificationService.getNotifications()`
- Display real notifications (session reminders, messages)
- Mark as read on tap

#### 8. `StudentPaymentMethodsScreen`
- Keep Stripe integration as-is
- Wire "Pay" to real session payment flow (pass real studentId, tutorId, sessionId)

#### 9. `StudentDeleteAccountScreen`
- Confirm password → call backend delete endpoint
- Clear tokens → navigate to login

### Part E: Wire Tutor Screens

#### 1. `TutorNavbar`
- Same as student: access AuthProvider, pass credentials to children

#### 2. `TutorDashboard` / `TutorHomeScreen`
- Fetch profile → real name in greeting
- Fetch sessions → real today's schedule
- Fetch payments → real earnings
- Count unique students from sessions

#### 3. `TutorScheduleScreen`
- Fetch `SessionService.getMySessions()` + `getSessionInstances()`
- Group by day of week
- Display real upcoming sessions

#### 4. `TutorStudentsScreen`
- Derive from sessions: extract unique students
- Fetch student details via user service
- Show real progress/session data

#### 5. `TutorProfileScreen`
- Fetch `UserService.getMyProfile()`
- Display real stats from sessions/payments
- Implement logout: `authProvider.logout()` → navigate to login

#### 6. `TutorEditProfileScreen`
- Pre-fill from profile API
- Save calls `UserService.updateProfile()`

#### 7. `TutorScheduleDetailsScreen`
- Wire "Reschedule" → `SessionService.updateSession()`
- Wire "Cancel" → `SessionService.cancelSession()`

### Part F: Backend Additions (Minor)

1. **`DELETE /api/users/me`** — Delete user account (soft delete or hard delete)
2. **`GET /api/users/me/stats`** — Return aggregated stats (total sessions, study hours, etc.) — optional, can compute client-side
3. **Ensure `GET /api/sessions` supports role-based filtering** (already does per code review)

### Part G: Error Handling & UX

1. All API calls wrapped in try-catch with user-facing error messages (SnackBar)
2. Loading states: show `CircularProgressIndicator` while fetching
3. Empty states: show appropriate message when no data ("No sessions yet", "No notifications")
4. Network error: show retry option
5. 401 handling: auto-refresh token, if refresh fails → logout to login screen

## Flow Diagrams

### Login Flow (New)
```
App Launch → Check stored token
  ├─ Token exists → Validate with /auth/refresh
  │   ├─ Valid → Navigate to navbar (based on stored role)
  │   └─ Invalid → Clear tokens → Login screen
  └─ No token → Onboarding → Login screen

Login Screen → POST /auth/login
  ├─ Success → Store tokens → Navigate to navbar
  └─ Failure → Show error message

Register link → Register Screen → POST /auth/register
  ├─ Success → Store tokens → Profile Setup → PUT /api/users/me → Navbar
  └─ Failure → Show error message
```

### Data Flow (New)
```
AuthProvider (root)
  ├─ accessToken, refreshToken, userId, role
  ├─ Persisted in SharedPreferences
  └─ Accessible from any screen via Provider.of

Screen loads → reads AuthProvider for credentials
  → Creates service instance (or uses injected service)
  → Calls API endpoint with Bearer token
  → Displays real data or error state
```

## Files to Modify

### New Files
| File | Purpose |
|------|---------|
| `lib/data/services/auth_service.dart` | HTTP client for auth endpoints |
| `lib/data/providers/auth_provider.dart` | Auth state management |
| `lib/data/services/user_service.dart` | User profile operations |
| `lib/data/services/session_service.dart` | Session/schedule operations |
| `lib/data/services/notification_service.dart` | Notification operations |
| `lib/data/services/payment_service.dart` | Payment operations |
| `lib/presentation/screens/login/register_screen.dart` | Registration screen |
| `backend/lib/routes/user_routes.dart` | Add DELETE /api/users/me |

### Modified Files
| File | Changes |
|------|---------|
| `lib/main.dart` | Add AuthProvider, change initial route logic |
| `lib/routes/app_pages.dart` | Add auth guard, add register route |
| `lib/routes/app_routes.dart` | Add register route constant |
| `lib/presentation/screens/login/login_screen.dart` | Real auth API calls |
| `lib/presentation/screens/roles/role_selection_screen.dart` | Part of registration flow |
| `lib/presentation/screens/student/student_profile_setup.dart` | Submit to backend |
| `lib/presentation/screens/tutor/tutor_profile_setup.dart` | Submit to backend |
| `lib/presentation/widgets/student_navbar.dart` | Pass auth to children |
| `lib/presentation/widgets/tutor_navbar.dart` | Pass auth to children |
| `lib/presentation/screens/student/student_dashboard.dart` | Fetch real data |
| `lib/presentation/screens/student/student_profile_screen.dart` | Fetch real profile |
| `lib/presentation/screens/student/student_edit_profile_screen.dart` | Save to backend |
| `lib/presentation/screens/student/student_tutors_screen.dart` | Fetch from API |
| `lib/presentation/screens/student/tutor_discovery_screen.dart` | Fetch from API |
| `lib/presentation/screens/student/view_all_tutors_screen.dart` | Use real data |
| `lib/presentation/screens/student/student_learning_history_screen.dart` | Fetch sessions |
| `lib/presentation/screens/student/student_notifications_screen.dart` | Fetch notifications |
| `lib/presentation/screens/student/student_payment_methods_screen.dart` | Use real IDs |
| `lib/presentation/screens/student/student_delete_account_screen.dart` | Call delete API |
| `lib/presentation/screens/tutor/tutor_home_screen.dart` | Fetch real data |
| `lib/presentation/screens/tutor/tutor_dashboard.dart` | Fetch real data |
| `lib/presentation/screens/tutor/tutor_schedule_screen.dart` | Fetch sessions |
| `lib/presentation/screens/tutor/tutor_schedule_details_screen.dart` | Wire actions |
| `lib/presentation/screens/tutor/tutor_students_screen.dart` | Fetch from sessions |
| `lib/presentation/screens/tutor/tutor_profile_screen.dart` | Fetch profile, logout |
| `lib/presentation/screens/tutor/tutor_edit_profile_screen.dart` | Save to backend |
| `lib/presentation/screens/tutor/tutor_student_detail_screen.dart` | Fetch real stats |
| `lib/presentation/screens/student/tutor_profile_popup.dart` | Use real tutor data |
| `lib/presentation/screens/aichat/ai_chat_screen.dart` | Use backend AI endpoints |
| `docs/knowledge_base.md` | Document auth flow |
| `docs/backend-api-specification.yaml` | Add DELETE /users/me |

## Acceptance Criteria

### Authentication
- [ ] User can register as student or tutor with email/password
- [ ] User can login with valid credentials
- [ ] Invalid credentials show error message
- [ ] Token persists — app auto-logs in on restart
- [ ] Expired token auto-refreshes without user intervention
- [ ] Logout clears session and returns to login
- [ ] Unauthenticated users cannot access protected screens

### Student Flows
- [ ] Dashboard shows real user name and stats from backend
- [ ] Tutor discovery fetches real tutors from GET /api/users/tutors
- [ ] Tutor search/filter works against real backend data
- [ ] Profile screen shows real user info from GET /api/users/me
- [ ] Edit profile saves changes to backend via PUT /api/users/me
- [ ] Learning history shows real completed sessions
- [ ] Notifications show real notifications from backend
- [ ] Payment screen uses real student/tutor/session IDs
- [ ] "Chat with Tutor" from discovery starts real chat via POST /api/chats/start
- [ ] Delete account actually deletes the account

### Tutor Flows
- [ ] Dashboard shows real earnings, student count, today's schedule
- [ ] Schedule screen shows real sessions from backend
- [ ] Student list derived from real sessions
- [ ] Profile shows real tutor info
- [ ] Edit profile saves to backend
- [ ] Reschedule/Cancel session buttons work
- [ ] Logout works properly

### General
- [ ] No hardcoded user names ("Student Name", "Ali Khan") remain
- [ ] No hardcoded stats (32 students, $280, etc.) remain
- [ ] All screens show loading indicator while fetching
- [ ] All screens show appropriate error state on failure
- [ ] All screens show empty state when no data exists
- [ ] Works on two physical devices with same backend
- [ ] Existing chat and Stripe features still work
- [ ] All existing backend tests still pass
- [ ] `docs/knowledge_base.md` updated
- [ ] `docs/backend-api-specification.yaml` updated

## Technical Notes
- Use `Provider` package (already in pubspec) for auth state management
- Store tokens in `shared_preferences` (already a dependency) — acceptable for demo; use `flutter_secure_storage` for production
- All service classes should accept `baseUrl` and `token` in constructor
- Consider creating a base `ApiClient` class that handles: token injection, 401 refresh, error parsing
- Backend already returns proper HTTP status codes (400, 401, 404, 500) — frontend should interpret these
- Tutor approval system exists in backend (`isApproved` field) — for demo, auto-approve all tutors on registration
- The AI service can be migrated to backend endpoints later if Gemini API key management is preferred server-side
- Polling remains acceptable for demo (2-second intervals for chats/notifications)
- Profile images: for demo, store as URL strings (avatar services); file upload can be a future enhancement

## Dependencies
No new packages needed. All required packages already in `pubspec.yaml`:
- `http` — API calls
- `shared_preferences` — Token persistence
- `provider` — State management

## Estimated Scope
- ~8 new files (services + auth provider + register screen)
- ~28 modified files (screens + routes + main)
- 1 minor backend addition (DELETE /users/me)
