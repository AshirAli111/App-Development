# TICKET-12: Phone-number standardisation, tutor payout accounts & student payment channels

## Type
Feature

## Priority
High

## Status
Done

## Summary
Three related changes requested together:

1. **Standardised phone input** — everywhere the app collects a phone number it
   now uses a country dial-code dropdown (all countries) + a national number
   that is **always exactly 10 digits**.
2. **Tutor payout accounts** — the Payout Settings screen shows only the payout
   account the tutor actually added (no fake "Not Connected" rows). Adding one
   uses a dropdown of **Pakistani banks** (Meezan, HBL, etc.) plus the
   **EasyPaisa / JazzCash** wallets, and persists to the tutor's profile.
3. **Student payment channels** — the student Payment Methods screen lets the
   student pick a channel (Card/Stripe, EasyPaisa, JazzCash, Bank Transfer),
   shows **NextStepLearning's receiving account** for that channel, and collects
   the account the student is paying from.

## Design

### Shared building blocks
- `lib/core/constants/country_codes.dart` — `CountryCode` list (dial code + flag).
- `lib/core/constants/banks.dart` — `PayoutOption` list (wallets + Pakistani
  banks) and `PaymentChannel` list (NextStepLearning's receiving accounts).
- `lib/presentation/widgets/phone_number_field.dart` — `PhoneNumberField`:
  dial-code dropdown + 10-digit-capped national field, emits the composed value
  and validates the 10-digit rule inside a `Form`. Applied to tutor/student
  profile setup, student edit-profile, payout add-account, and student payment.

### Backend
- `UserModel.payoutAccount` (nullable `Map`) added so the tutor's payout account
  round-trips through `GET/PUT /api/users/me` (persisted via the existing
  dot-notation update in `UserService.updateUser`).

### Payout / payment screens
- `payout_settings_screen.dart` → stateful; loads profile, shows the saved
  `payoutAccount` (or an empty state), add/change via a bottom-sheet form.
- `student_payment_methods_screen.dart` → tapping a channel opens a sheet with
  NextStepLearning's account (copyable) + the student's paying-account field;
  the card channel routes to the existing Stripe checkout.

## Acceptance Criteria
- [x] All phone fields use the country-code dropdown and reject anything but 10 digits.
- [x] Payout Settings shows only the tutor's chosen account; empty state otherwise.
- [x] Add-payout dropdown lists Pakistani banks + EasyPaisa + JazzCash.
- [x] Payout account persists (survives reload) via the backend.
- [x] Student can select a channel, see the NextStepLearning destination account, and enter their own account.
- [x] `flutter analyze` clean; OpenAPI spec + knowledge base updated; committed.
