# TICKET-15: Editable email on setup + change email/password in edit profile

## Type
Feature

## Priority
Medium

## Status
Done

## Summary
1. The **email field on profile setup was disabled** — the user couldn't change it. It is now
   editable; the account is created (on Continue) with the entered email.
2. **Edit Profile (student + tutor) can now change email and password**, requiring the
   **current password**.

## Design
### Backend
- `AuthService.changeCredentials({userId, currentPassword, newEmail?, newPassword?})` — verifies
  the current bcrypt password, enforces unique email, min-6 password; updates and returns the user.
- Route `PUT /api/users/me/credentials` (protected). 401 if current password wrong, 409 on
  duplicate email.
- (`PUT /api/users/me` still ignores email/password/role — unchanged.)

### Frontend
- Setup screens: email `TextField` enabled + validated (`@`); the register call uses the
  entered email.
- `UserService.changeCredentials(...)` calls the new endpoint.
- Both edit-profile screens: a "Change Password (optional)" section (Current Password + New
  Password) plus the editable Email field. On save: update profile fields, then — only if the
  email changed or a new password was entered — call `changeCredentials` (needs current password).

## Acceptance Criteria
- [x] Email is editable on profile setup and used to create the account.
- [x] Student & tutor can change email in Edit Profile (current password required).
- [x] Student & tutor can change password in Edit Profile (current password required).
- [x] Wrong current password is rejected; duplicate email returns a clear error.
- [x] Verified end-to-end via API; `flutter analyze` / `dart analyze` clean; docs updated.
