# TICKET-09: Rebrand display name to NextStepLearning + onboarding polish

## Type
Chore

## Priority
Low

## Status
Done

## Summary
Rename the app's **display name** from "TutorGo" to **NextStepLearning** across the UI,
README, and documentation only — no backend, database, or package-identifier changes.
Also polish the onboarding screen.

## Changes
- **UI display strings**: MaterialApp title, Windows window title (`windows/runner/main.cpp`),
  onboarding / role-selection / register copy.
- **README.md** and **docs** (`knowledge_base.md`, `ticket01.md`,
  `backend-api-specification.yaml` info text) updated to NextStepLearning.
- **Onboarding**: removed "AI-verified learning"; subtitle now "…get best quality education
  anytime, anywhere." "Get Started" button made smaller and the content is wrapped in a
  centered `ConstrainedBox(maxWidth: 460)` so everything is centered on wide/desktop windows.

## Explicitly unchanged (backend/build unaffected)
- Mongo DB name `tutorgo_db`, backend package `tutorgo_backend`, Flutter package
  `next_step_learning`, the `tutorgo.exe` binary name, and all backend code / API field names.
- The Dart widget class `TutorGo` in `main.dart` (code identifier, not user-visible).

## Acceptance Criteria
- [x] No "TutorGo" in user-facing UI, README, or docs.
- [x] Backend / DB / package identifiers preserved.
- [x] Onboarding subtitle updated; Get Started button smaller and centered.
- [x] `flutter analyze` passes.
