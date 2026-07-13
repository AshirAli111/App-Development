# TICKET-11: Forgot password via email or phone (OTP, demo delivery)

## Type
Feature

## Priority
High

## Status
Done

## Summary
Add a "Forgot password?" flow to the login screen. **No emailed/SMS code** (decided with
the user): the user proves ownership by entering **both** the email and phone number on
their account. If the two match a single account, the reset-password screen appears
immediately and the password is updated.

## Design

### Backend (`tutorgo/backend`) — 2 public routes under `/auth`
| Route | Body | Behaviour |
|-------|------|-----------|
| `POST /auth/verify-identity` | `{ email, phone }` | Finds the account by email, then compares the stored phone with the supplied one on the **last 10 digits** (ignoring spaces/dial code). On match returns `{ resetToken }` — a 15-minute JWT with `purpose: password_reset`. 404 if email not found or phone mismatch. |
| `POST /auth/reset-password` | `{ resetToken, newPassword }` | Verifies token purpose + min 6 chars, bcrypt-hashes and updates the user's password. |

### Frontend (Flutter)
- `AuthService` (`lib/data/services/auth_service.dart`): `verifyIdentity`, `resetPassword`.
- `ForgotPasswordScreen` (`lib/presentation/screens/login/forgot_password_screen.dart`):
  2 in-page steps — (1) email + `PhoneNumberField`, (2) new password + confirm.
- Route `/forgot-password` in `app_routes.dart` + `app_pages.dart`.
- "Forgot password?" link on the login screen under the password field.

## Acceptance Criteria
- [x] "Forgot password?" link on login opens the new screen.
- [x] User enters email + phone; both must match the account (no code sent).
- [x] On match the reset-password screen appears and updates the password.
- [x] Old password stops working, new one logs in.
- [x] Reset token cannot be used for normal API auth (purpose-scoped).
- [x] OpenAPI spec + knowledge base updated; changes committed.
