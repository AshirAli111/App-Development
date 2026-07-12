# TICKET-15: Proper payment (student → admin) & tutor payout details

## Type
Feature

## Priority
High

## Status
Done

## Summary
- **Student payment**: a proper form to send money to the platform (admin) account. The
  student enters an **amount**, picks a **gateway** (Easypaisa / JazzCash / Bank Transfer /
  Card), sees the **admin destination account** for that method, enters their own sending
  account details, and submits. The deposit is recorded and confirmed.
- **Tutor payout**: the tutor enters their **bank/wallet details** (method + account holder +
  account number/IBAN) to receive payouts; saved to their profile and re-loaded.

Note: no real payment-gateway credentials exist, so money movement is simulated — but the
details are collected, validated, and recorded like a real flow.

## Design
- Backend: `POST /api/payments/deposit` `{amountPKR, method, senderName, senderAccount}` →
  records to a `deposits` collection for the current student (status `paid`).
- Frontend:
  - `PaymentService.createDeposit(...)`.
  - `SendPaymentScreen` (student): amount + method + admin destination + sender fields +
    validation → deposit → success. Reached from the student Payment Methods list.
  - Rewrite `PayoutSettingsScreen` (tutor) into a real form saving `tutorProfile.payoutAccount`
    via `updateProfile`.
- Update the OpenAPI spec.

## Acceptance Criteria
- [ ] Student can enter amount + method + their account, see the admin destination, and pay.
- [ ] Validation (amount > 0, required account fields per method).
- [ ] Tutor can save & re-load their payout bank details.
- [ ] `flutter analyze` + backend `dart analyze` pass; spec updated.
