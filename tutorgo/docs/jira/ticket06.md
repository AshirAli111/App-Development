# TICKET-06: Fix student→tutor chat & add "Book Session" flow

## Type
Bug + Feature

## Priority
High

## Status
Done

## Summary
Two issues on the student "Find Tutors" flow (tutor profile popup):

1. **Bug — chat not working.** The "Chat with Tutor" button opened `TutorChatConversation`
   (the tutor-side screen) and passed only `name` — no `chatId`, `baseUrl`, `token`, or
   `userId`, and never called `startChat`. Result: the conversation screen loads/sends against
   an empty `chatId`, so no messages appear and nothing can be sent.

2. **Feature — no way to book a tutor.** The popup only offered "Chat with Tutor". There is a
   complete sessions backend (`POST /api/sessions/`) that was never reachable from the student
   UI. Students had no booking option.

## Changes
- `tutor_profile_popup.dart`: "Chat with Tutor" now reads `AuthProvider`, calls
  `ChatService.startChat(tutorId)` to get/create the real chat, and opens
  `StudentChatConversation` with the correct `chatId` + auth. Added a "Book Session" button.
- New `book_session_sheet.dart`: bottom sheet to pick day + start/end time and confirm a
  booking; creates a real session via `SessionService.createSession`. The booking then shows
  up in the student's Learning History and the tutor's schedule (status `active`).

## Acceptance Criteria
- [x] Tapping "Chat with Tutor" opens a working conversation; messages send and appear.
- [x] The chat also shows up in the student's Messages list and the tutor's chats.
- [x] Tapping "Book Session" lets the student pick day/time and confirm.
- [x] A confirmed booking is created in the backend and appears in Learning History.
- [x] `flutter analyze` passes for the changed files.

## Follow-up fixes rolled into this ticket
- Home/Schedule crash: `recurrence` is a Map, not a String — added formatters in
  `student_dashboard.dart` and fixed the `as String?` cast in `tutor_schedule_screen.dart`.
- Backend resilience: MongoDB idle-disconnect crashed the server via the notification
  scheduler Timer. Added `Database.ensureConnected()`, guarded the scheduler, and added a
  per-request DB-recovery middleware.
- Chat name: `_enrichChat` read `otherUser['name']` but users store `fullName` → showed
  "Unknown". Fixed.
- Profile images: images are stored base64. Added `core/utils/image_utils.dart`
  (`profileImageProvider` handles URL / data-URI / raw base64) and wired it into every avatar.
  Student/tutor profile setup + edit screens now actually upload the avatar (base64, ≤2MB);
  edit screens gained a camera-badge picker.
- Session enrichment: `getSessionsByUser` now attaches `studentName/studentImage/
  tutorName/tutorImage` so dashboards, My Students, My Tutors, and Your Tutors render names + photos.
- Editable email in both edit-profile screens (unique-email conflict returns 409).
- Tutor hourly rate: added "Rate (PKR / hour)" field saving `tutorProfile.pricePerHourPKR`;
  fixed the student side reading the wrong field (`pricePerHour`) and changed `$` → `PKR`.
- My Tutors screen: replaced hardcoded list with real booked tutors from sessions.
- UI: fixed a 4px bottom overflow on the tutor discovery card.
