# TICKET-12: Profile-setup improvements + deferred account creation

## Type
Feature

## Priority
High

## Status
Done

## Summary
Improve the signup / profile-setup step for both roles:

- **Register** now only collects credentials (name, email, password, role); it does **not**
  create the account. The account is created **only when the profile is completed**.
- **Tutor setup**: Experience is a dropdown (1..10, "10+"); Highest Qualification is a
  dropdown (Bachelors / Masters / PhD). All required documents (CNIC front, CNIC back,
  Teaching Certificate, Degree) must be uploaded before the profile can be completed.
- **Student setup**: Grade/Class is a dropdown (Matriculation / College / Bachelors / Masters).
- Both setup screens get a **back button** (AppBar) to return to Register and change the
  role or details.

## Design
- Register `_submit` validates locally, then `pushNamed(setupRoute, arguments:{name,email,
  password,role})` instead of calling `auth.register`.
- `app_pages` passes route arguments to the setup screens.
- Setup screens accept `{name,email,password,role}`; on Complete they call
  `auth.register(...)` (creates account + logs in) then `updateProfile(...)`, then go to the
  navbar. Tutor Complete is blocked until all 4 documents are attached.
- AppBar back arrow (`Navigator.pop`) returns to Register.

## Acceptance Criteria
- [ ] Register does not create an account; completing the profile does.
- [ ] Tutor: experience & qualification dropdowns; cannot finish without all documents.
- [ ] Student: grade dropdown.
- [ ] Both setups have a working back button to Register.
- [ ] `flutter analyze` passes.
