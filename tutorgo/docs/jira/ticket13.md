# TICKET-13: Password-confirmed Delete Account (both roles) + required student fields

## Type
Feature

## Priority
High

## Status
Done

## Summary
1. **Delete Account** for students **and** tutors: the user enters their **password**; on a
   correct password the account is permanently deleted, then they're logged out and sent to
   the start. The tutor profile currently has no delete option — add one.
2. **Student profile completion validation**: block "Continue" if any required field is
   missing (Full Name, Phone, Age, Grade/Class, at least one interest).

## Design
- **Backend**: `DELETE /api/users/me` now requires `{password}` in the body; verifies it
  (bcrypt) against the stored hash before deleting. Wrong/absent password → 401.
- **Frontend**:
  - `UserService.deleteAccount(password)` sends the password with the delete request.
  - A shared/updated Delete Account screen: password field + confirm dialog → delete →
    `auth.logout()` → onboarding/login.
  - Add a "Delete Account" tile to the tutor profile screen.
  - Student setup `_handleContinue` validates required fields and shows what's missing.
- Update the OpenAPI spec for the delete endpoint.

## Acceptance Criteria
- [ ] Student & tutor can delete their account by entering the correct password.
- [ ] Wrong password is rejected; the account is not deleted.
- [ ] After deletion the user is logged out and returned to the start.
- [ ] Student cannot complete setup with any required field missing.
- [ ] `flutter analyze` + backend `dart analyze` pass; spec updated.
