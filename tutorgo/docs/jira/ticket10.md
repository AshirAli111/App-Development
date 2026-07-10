# TICKET-10: Working notifications (real-time messages + class reminders) for both roles

## Type
Feature

## Priority
High

## Status
Done

## Summary
Make notifications actually work for students and tutors while the app is running
(foreground or minimized), on both PC (Windows) and phone:

1. **Real-time message popups** — when a new chat message arrives and the user is not
   already viewing that conversation, show an OS notification + an in-app banner.
2. **Class reminder notifications** — surface the backend-generated `session_reminder`
   records (created ~30 min before a session) as OS notifications.
3. Both are **toggleable** (Messages / Class Reminders) from the Notifications settings
   screen; toggles are saved **on the device** (shared_preferences).

Scope: **local notifications while the app runs** via `flutter_local_notifications`
(Android/iOS/Windows/macOS/Linux), driven by polling the backend. True push when the app
is fully closed (FCM/APNs) is explicitly out of scope.

## Design
- `flutter_local_notifications` dependency + init in `main` (with Windows app id/GUID).
- `NotificationPrefs` (shared_preferences): `messagesEnabled`, `classRemindersEnabled`.
- `LocalNotificationService`: init + `showMessage()` / `showReminder()`, each gated by the
  matching pref.
- `NotificationPoller`: started by the logged-in shell; every ~8s polls
  `GET /api/notifications/` for new reminders and `GET /api/chats/` for new incoming
  messages, de-duped via last-seen ids; triggers the local notification (+ in-app banner for
  messages). Stops on logout.
- Wire student + tutor Notifications settings screens to `NotificationPrefs`.

## Acceptance Criteria
- [x] New message (while not in that chat) → in-app banner (+ OS notification on mobile), both roles.
- [x] Class reminder record → in-app banner (+ OS notification on mobile), both roles.
- [x] Messages / Class Reminders toggles persist (device-local) and gate their notifications.
- [x] No duplicate notifications for the same message/reminder.
- [x] `flutter analyze` passes for changed files.

## Follow-up
- **Tap-to-open**: tapping a message notification opens that conversation directly — the in-app
  banner has an `onTap` and the OS notification carries the `chatId` payload
  (`onDidReceiveNotificationResponse`). The poller caches each chat's name/photo and knows the
  role to pick the student vs tutor conversation screen.

## Platform note
- `flutter_local_notifications` v18 has **no Windows toast** implementation, so on Windows/web
  we skip the plugin and rely on the in-app banner. Real OS notifications fire on Android/iOS
  (and macOS/Linux). True push when the app is fully closed (FCM) remains out of scope.
