# TICKET-11: Forgot Password (account recovery) for students & tutors

## Type
Feature

## Priority
High

## Status
Done

## Summary
Let any user (student or tutor) recover their account when they forget their password.
No email server is configured, so identity is verified by **email + the phone number saved
on the account**; on a match the user sets a new password.

## Design
- **Backend** `POST /auth/reset-password` (public, no auth): body `{email, phone, newPassword}`.
  Finds the user by email, checks the stored `phone` matches, validates `newPassword` length,
  bcrypt-hashes it, and updates the user. Generic error on no-match (don't leak which field).
- **Frontend**:
  - `AuthService.resetPassword(email, phone, newPassword)` → the new endpoint.
  - `ForgotPasswordScreen`: email, phone, new password + confirm; validates and submits;
    on success returns to login with a confirmation.
  - "Forgot Password?" link on the login screen; new route `/forgot-password`.
- Update the OpenAPI spec with the new endpoint (project rule).

## Acceptance Criteria
- [ ] Login screen has a "Forgot Password?" link.
- [ ] Correct email + phone lets the user set a new password and then log in with it.
- [ ] Wrong email/phone is rejected with a generic message.
- [ ] Works for both student and tutor accounts.
- [ ] `flutter analyze` + backend `dart analyze` pass; OpenAPI spec updated.
