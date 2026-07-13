# TICKET-14: Profile-setup validation + dropdowns (experience / qualification / education)

## Type
Feature

## Priority
Medium

## Status
Done

## Summary
Enforce required fields on both profile-setup screens (no profile is saved with empty
fields) and replace free-text fields with dropdowns.

## Changes
### Tutor setup (`tutor_profile_setup.dart`)
- **Experience (years)** → dropdown: `1..10` and `10+` (sent as `experienceYears`; `10+` → 10).
- **Highest Qualification** → dropdown: `Bachelor's Degree`, `Master's Degree`, `PhD`.
- **Validation** blocks "Continue" (snackbar) unless: full name, valid 10-digit phone,
  experience, qualification, ≥1 subject, and CNIC front + CNIC back + teaching certificate
  are all provided. (Degree upload stays optional.)

### Student setup (`student_profile_setup.dart`)
- **Grade / Class** → **Education** dropdown: `Matriculation`, `Intermediate (College)`,
  `Bachelor's Degree` (sent as `studentProfile.grade`).
- **Validation** blocks "Continue" unless: full name, valid 10-digit phone, valid age,
  education, and ≥1 course. Address stays optional (it is labelled "Optional").

### Navigation
- Both setup screens now have a **back button** (transparent AppBar → `Navigator.maybePop`)
  so the user can return to role selection.

## Acceptance Criteria
- [x] Tutor cannot continue with any required field empty.
- [x] Student cannot continue with any required field empty.
- [x] Experience is a 1–10 / 10+ dropdown; qualification is a proper-named dropdown.
- [x] Student education is a proper-named dropdown.
- [x] `flutter analyze` clean; app runs.
