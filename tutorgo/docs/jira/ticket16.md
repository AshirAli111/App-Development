# TICKET-16: Bank dropdown, phone country-code field, payout view/edit split

## Type
Feature

## Priority
Medium

## Status
Done

## Summary
- **Tutor Payment Methods** = view-only display of the saved payout account (method/bank +
  masked account + holder). **Payout Settings** = the editable form.
- **Payout Settings**: when *Bank Transfer* is selected, a **dropdown of Pakistani banks**
  (Meezan, Allied, HBL, UBL, MCB, NBP, …); for *Easypaisa / JazzCash*, just account holder +
  a phone field.
- **Phone inputs app-wide**: a reusable `PhoneField` with a **country-code dropdown**
  (default +92, world list) and a number field limited to **digits only, max 10**. Applied to
  student & tutor setup, student edit profile, forgot password, send-payment wallet, and payout
  wallet. Stored as the full number, e.g. `+923001234567`.

## Files
- `core/constants/banks.dart`, `core/constants/country_codes.dart`,
  `presentation/components/inputs/phone_field.dart`.
- Updated payout settings, tutor payment methods, and the phone entry points above.

## Backend read-strip fix (rolled in)
- `getUserById` rebuilt the user through the fixed-shape `UserModel`, dropping extra sub-fields
  added via `updateProfile` (`tutorProfile.payoutAccount`, `studentProfile.selectedCourses`).
  Now returns the raw document (minus password), so the saved payout account (and editable
  email — `updateUser` also stopped stripping `email`) persist and read back correctly.

## Acceptance Criteria
- [x] Payment Methods shows saved payout; Payout Settings edits it.
- [x] Bank dropdown for Bank Transfer; phone for wallets.
- [x] Phone fields: +92 default + world codes, digits-only, max 10.
- [x] Saved payout / edited email read back correctly.
- [x] `flutter analyze` + backend `dart analyze` pass.
