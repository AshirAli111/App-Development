# TICKET-05: Fix Tutor Registration Bugs (Document Upload, Discovery Visibility, Test Data)

## Type
Bug

## Priority
High

## Status
Done

## Summary
Three interrelated bugs prevent newly registered tutors from appearing correctly in the app:

1. **Document upload does nothing** — File picker selects files locally but they are never sent to the backend on "Continue"
2. **New tutor not visible in student discovery** — Profile setup overwrites the entire `tutorProfile` object, removing `isApproved: true`, which makes the tutor invisible to the discovery query
3. **Stale test data pollutes discovery** — "Test Tutor" entries from backend test runs appear in Find Tutors with no subjects (showing as "General")

## Root Cause Analysis

### Bug 1: Document Upload
**File:** `lib/presentation/screens/tutor/tutor_profile_setup.dart`

The `pickFile()` method works — it opens the file picker and stores the `File` in local state. The `buildUploadedCard` widget shows a confirmation. However, `_handleContinue()` (line 94) only sends `subjects`, `experience`, and `qualification` — the 4 document files are **never converted to base64 or sent to the backend**.

### Bug 2: Tutor Not in Discovery
**Files:** `tutor_profile_setup.dart` + `backend/lib/services/user_service.dart`

The profile setup sends:
```json
{
  "tutorProfile": {
    "subjects": ["Mathematics", "Physics"],
    "experience": 4,
    "qualification": "Masters in computer science"
  }
}
```

The backend `updateUser()` does `modifier.set('tutorProfile', {...})` which **replaces the entire nested object** in MongoDB. This wipes out `isApproved: true` (set during registration). The `GET /api/users/tutors` query filters by `tutorProfile.isApproved == true` — so the tutor vanishes.

Additionally, the frontend sends `'experience'` but the model field is `'experienceYears'` — wrong key name.

### Bug 3: Test Data Pollution
The backend test suite (`test/api_test.dart`) registers test users with `fullName: "Test Tutor"` and no subjects. Since `isApproved` now defaults to `true`, these persist in the DB and appear in discovery under "General" category.

## Acceptance Criteria

### Document Upload
- [ ] Tapping "Upload CNIC Front/Back/Certificate/Degree" opens file picker
- [ ] Selected files are converted to base64 on "Continue"
- [ ] Base64 documents are sent to backend via `PUT /api/users/me` under `tutorProfile.documents`
- [ ] Documents are stored in MongoDB and retrievable later
- [ ] Large files are compressed/resized before encoding (max ~500KB per document)
- [ ] Error shown if file is too large

### Tutor Discovery Visibility
- [ ] Newly registered tutor with subjects appears in Find Tutors immediately after setup
- [ ] Profile setup uses dot-notation updates (e.g., `tutorProfile.subjects`) instead of replacing entire object
- [ ] `isApproved` field is never removed by profile updates
- [ ] Field name corrected: `experienceYears` (not `experience`)
- [ ] Tutor's selected subjects appear as category headers in discovery

### Test Data Cleanup
- [ ] Backend test suite cleans up created test users after tests complete (tearDown)
- [ ] OR: Add a `/api/admin/cleanup-test-data` endpoint for dev environment
- [ ] No "Test Tutor" entries visible in production/demo database
- [ ] Add script or instructions to reset the database for demo

## Implementation Plan

### Fix 1: Document Upload (Frontend + Backend)

**Frontend** (`tutor_profile_setup.dart`):
- In `_handleContinue()`, convert each non-null document file to base64:
  ```dart
  import 'dart:convert';
  final bytes = await file.readAsBytes();
  final base64 = base64Encode(bytes);
  ```
- Add base64 strings to the profile update payload under `tutorProfile.documents.cnicFront`, etc.
- Add image compression before encoding (use `image_picker` with `imageQuality` or resize)
- Show progress indicator during upload (files can be large)

**Backend** (`user_service.dart`):
- The `updateTutorDocuments()` method already exists and uses dot-notation — reuse or call it from the update flow
- Ensure document strings are stored correctly in `tutorProfile.documents`

### Fix 2: Dot-Notation Updates (Backend)

**Option A (Recommended):** Flatten nested objects in `updateUser()`:
```dart
// If updates contains 'tutorProfile', flatten to dot-notation
if (updates.containsKey('tutorProfile')) {
  final tp = updates.remove('tutorProfile') as Map<String, dynamic>;
  tp.forEach((k, v) {
    updates['tutorProfile.$k'] = v;
  });
}
```

This way `set('tutorProfile.subjects', [...])` updates only that field without touching `isApproved`.

**Option B:** Frontend sends individual dot-notation fields instead of a nested object.

### Fix 3: Test Cleanup

**Option A (Recommended):** Add `tearDownAll` in `test/api_test.dart` that deletes the test users created during the run.

**Option B:** The test already uses timestamp-based emails (`test_student_<timestamp>@test.com`). Add a cleanup endpoint or script that deletes users matching `*@test.com`.

## Files to Modify

| File | Changes |
|------|---------|
| `backend/lib/services/user_service.dart` | Flatten nested object updates to dot-notation |
| `lib/presentation/screens/tutor/tutor_profile_setup.dart` | Convert documents to base64, fix field name to `experienceYears`, send documents in payload |
| `backend/test/api_test.dart` | Add tearDownAll to delete test users |

## Technical Notes
- Base64 encoding a 500KB image produces ~667KB of text — acceptable for MongoDB document storage in a demo
- For production, use cloud storage (S3/GCS) and store URLs instead
- The `image_picker` package already supports `imageQuality` parameter for compression
- `file_picker` returns arbitrary file types — should validate that picked files are images/PDFs
- The backend `updateTutorDocuments()` method in user_service.dart already handles dot-notation document updates — can be called directly from the frontend
