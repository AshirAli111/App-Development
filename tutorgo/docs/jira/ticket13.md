# TICKET-13: AI assistant chatbot (Llama via OpenRouter)

## Type
Feature

## Priority
High

## Status
Done

## Summary
Replace the placeholder AI chat (which called Google Gemini directly from the client with a
hardcoded key) with a real **NextStepLearning assistant** powered by **Llama 3.3 70B via
OpenRouter**. The assistant is **precise and to the point**, **role-aware** (student vs
tutor), knows the app, can escalate to human support, follows trust & safety guardrails, and
also answers **general questions** (time, country, etc.).

The LLM call is routed through the **backend** so the OpenRouter API key stays server-side
(in `backend/.env`, gitignored) and is never shipped in the Flutter app.

## Capabilities (system prompt sections)
1. **Onboarding & Navigation** — where things are, how to get started.
2. **Teacher Discovery & Matching** — find tutors by course/subject, rates (PKR), ratings.
3. **Registration & Enrollment** — sign up, choose role, complete profile.
4. **Booking & Scheduling** — book sessions, recurring classes, reminders.
5. **Account & Billing Support** — payment channels (EasyPaisa/JazzCash/Bank Transfer),
   tutor payout accounts, password reset (email + phone).
6. **Role-Aware Behavior** — answers framed for the logged-in role.
7. **Escalation to Human Support** — routes account-specific issues to Help Center / Contact
   Support instead of guessing.
8. **Trust & Safety Guardrails** — never asks for passwords/OTP/card PINs, never invents
   tutor data or prices, declines harmful/off-limits requests.

General knowledge (time/date/country/etc.) is allowed; the current date/time and the app's
country (Pakistan) are injected into the system prompt so time questions are answerable.

## Design

### Backend
- `Env`: `OPENROUTER_API_KEY`, `OPENROUTER_MODEL` (default `meta-llama/llama-3.3-70b-instruct`).
- `AiAssistantService.reply({role, message, history})` — builds the system prompt (with
  injected date/time + role), appends capped history, calls
  `POST https://openrouter.ai/api/v1/chat/completions`, returns the assistant text.
- Route `POST /api/ai/chat` (protected; role comes from the JWT) → `{message, history?}` →
  `{reply}`.

### Frontend
- `AiAssistantService` (`lib/data/services/ai_assistant_service.dart`) → calls
  `/api/ai/chat` with the auth token and recent history.
- `ai_chat_screen.dart` uses it (role + auth from `AuthProvider`); the dummy Gemini
  service is no longer used.

## Follow-up refinements
- **Knows the user**: the backend injects a compact snapshot of the user's real
  account (profile + active sessions → their students/tutors, subjects, schedule,
  payout status) into the prompt, so "who are my students?" is answered from real data.
  Kept short to suit the free-tier model.
- **Chat persists**: history is saved per-user/per-role in `shared_preferences`, so
  leaving and returning to the screen keeps the conversation. A **Clear chat** button
  (app-bar trash icon, with confirm) is the only thing that wipes it.
- **Enter to send**: pressing Enter sends; Shift+Enter inserts a newline.
- **Robustness**: `parseBody` decodes request bytes as UTF-8 with `allowMalformed`, and
  the OpenRouter response is buffered before decoding (fixes multi-byte-split crashes).

## Acceptance Criteria
- [x] Chatbot answers app questions accurately for the current role.
- [x] Answers are concise / to the point.
- [x] General questions (e.g. current time, country) are answered.
- [x] Knows the current user's real students/tutors/schedule.
- [x] Chat survives leaving the screen; only Clear wipes it; Enter sends.
- [x] Escalation + trust-&-safety behavior present in the prompt.
- [x] API key lives in `backend/.env` only (not in client, not committed).
- [x] `flutter analyze` / `dart analyze` clean; docs updated; committed.
