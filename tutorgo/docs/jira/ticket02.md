# TICKET-02: Mock Stripe Payment Gateway

## Type
Feature

## Priority
High

## Status
Done

## Summary
Add a mock Stripe payment gateway to the existing payments flow. The backend will expose fake Stripe-like endpoints that simulate a real Stripe checkout session lifecycle (create session → redirect to mock checkout page → webhook callback → payment confirmed). No actual Stripe account or SDK is used — the entire flow is mocked server-side to behave realistically for demo purposes.

## Background
The app already has a `payments` collection supporting `easypaisa`, `jazzcash`, and `bank_transfer` methods. This ticket adds `stripe` as a fourth payment method option, reusing the same collection but adding Stripe-specific fields (session ID, checkout URL, webhook status).

## Architecture

### Backend (Dart/Shelf)
1. **New route group**: `/api/stripe/` with endpoints:
   - `POST /api/stripe/create-checkout-session` — Creates a mock Stripe checkout session, returns a session ID and a redirect URL pointing to the mock checkout page
   - `GET /api/stripe/checkout/:sessionId` — Serves a mock Stripe checkout HTML page (card form UI)
   - `POST /api/stripe/confirm/:sessionId` — Called when user submits the mock checkout form; marks payment as succeeded and redirects back to app
   - `GET /api/stripe/session/:sessionId` — Returns session status (for polling from Flutter after redirect)
   - `POST /api/stripe/webhook` — Mock webhook endpoint (auto-triggered internally after confirm)

2. **Mock Stripe session document** (stored in `stripe_sessions` collection):
   ```json
   {
     "_id": ObjectId,
     "sessionId": "cs_mock_xxxxx",
     "paymentId": ObjectId (ref to payments collection),
     "studentId": ObjectId,
     "tutorId": ObjectId,
     "amountPKR": 1500,
     "status": "pending" | "completed",
     "createdAt": DateTime,
     "completedAt": DateTime | null
   }
   ```

3. **Payment document update**: When Stripe method is used, the payment record in `payments` collection gets:
   - `method: "stripe"`
   - `stripeSessionId: "cs_mock_xxxxx"`
   - `status` transitions: `pending` → `completed` (always succeeds)

### Flutter (Frontend)
1. Add "Pay with Card (Stripe)" option in payment method selection
2. On selection: call `POST /api/stripe/create-checkout-session`
3. Open the returned checkout URL in an in-app WebView (mock Stripe page)
4. Mock page shows a card form (pre-filled or user-fillable, doesn't validate)
5. On submit: page calls confirm endpoint → redirects back to app via deep link or polling
6. Flutter polls `GET /api/stripe/session/:sessionId` until status is `completed`
7. Show success screen

### Flow Diagram
```
Student taps "Pay with Stripe"
    → Flutter calls POST /api/stripe/create-checkout-session
    → Backend creates stripe_session + payment record (status: pending)
    → Returns { sessionId, checkoutUrl }
    → Flutter opens checkoutUrl in WebView
    → User sees mock card form, clicks "Pay"
    → Browser POSTs to /api/stripe/confirm/:sessionId
    → Backend sets payment + session status to "completed"
    → Returns redirect/success HTML
    → Flutter polls session status → sees "completed"
    → Shows payment success screen
```

## Acceptance Criteria

- [ ] `stripe` is a valid payment method in the existing payments flow
- [ ] `POST /api/stripe/create-checkout-session` creates a session and returns `sessionId` + `checkoutUrl`
- [ ] `GET /api/stripe/checkout/:sessionId` serves an HTML page with a mock card form (card number, expiry, CVC fields)
- [ ] `POST /api/stripe/confirm/:sessionId` marks session and payment as completed, returns success HTML
- [ ] `GET /api/stripe/session/:sessionId` returns current session status for polling
- [ ] Payment always succeeds (no failure simulation)
- [ ] All amounts are in PKR
- [ ] `stripe_sessions` collection is created with proper indexes
- [ ] Integration tests cover the full Stripe mock flow
- [ ] Flutter UI has "Pay with Card (Stripe)" option that opens WebView to mock checkout
- [ ] After payment completes, Flutter shows success screen and payment appears in history
- [ ] `docs/knowledge_base.md` updated with Stripe mock architecture
- [ ] `docs/backend-api-specification.yaml` updated with new endpoints
- [ ] All existing payment tests still pass

## Technical Notes
- The mock checkout HTML page should look reasonably like a payment form (dark theme, card fields, "Pay" button) but does not need to match Stripe's exact branding
- No actual card validation is performed — any input succeeds
- The `sessionId` format is `cs_mock_` + random hex string (mimics Stripe's `cs_` prefix)
- WebView in Flutter can use `webview_flutter` package or `url_launcher` for simplicity
- Polling interval: 1 second, timeout after 60 seconds (though payment always succeeds immediately)
