# TICKET-19: Abuse & phone-number masking in AI assistant chat and student–tutor chat

## Type
Feature

## Priority
High

## Status
Done

## Summary

Apply content moderation to both chat surfaces:

1. **Phone numbers must not be shared** — any phone number typed in a chat
   message (AI assistant chat or student↔tutor chat) is masked ("blurred")
   with `*` before it is stored, displayed, or sent to the AI model.
2. **No foul language** — abusive words in **English** and in
   **Roman Urdu / Hindi** (e.g. *beghairat, kutta, pagal, kamina, harami,
   bewakoof, chutiya, gandu, haramzada…*) are masked, keeping only the first
   letter (e.g. `kutta` → `k****`) so readers can tell something was censored.
3. **The AI model is instructed** (system prompt guardrail) to never use
   abusive language in any language including Roman Urdu/Hindi, and never to
   request, repeat, or share phone numbers.

## Design decisions

- **All moderation runs server-side** in a new
  `ContentModerationService.sanitize()` so the word list lives in one place
  and clients cannot bypass it. Applied at every message write/reply point:
  - `POST /api/chats/<id>/messages` — student↔tutor messages (types `text`
    and `session_request`; `call_invite` carries a Jitsi room name, untouched)
  - `POST /api/ai/chat` — the user's message and history are sanitized
    *before* being sent to Gemini; the model's reply is sanitized before
    being returned
  - `POST /api/ai/conversations` and `POST /api/ai/conversations/<id>/message`
    — persisted AI-chat transcripts
- **`/api/ai/chat` also returns `sanitizedMessage`** so the app can replace
  the sender's local echo bubble with the masked version (the AI chat screen
  renders the typed text locally; the student/tutor chat screens already
  re-fetch messages from the server after sending, so they get masking for
  free).
- **Phone detection:** digit runs of 10–15 digits allowing `+ - ( ) .` and
  spaces as separators (covers `03001234567`, `+92 300 1234567`,
  `0300-1234567`, …). The whole match is replaced with `*`. Shorter numbers
  (prices, ages) are untouched.
- **Word matching:** case-insensitive, word-boundary, with common spelling
  variants in the lexicon (e.g. `bewakoof`/`bewaqoof`, `kamina`/`kameena`).

## Acceptance Criteria

- [x] Phone numbers in student↔tutor chat messages are stored & displayed
      masked.
- [x] Abusive words (English + Roman Urdu/Hindi) in student↔tutor chat are
      stored & displayed masked.
- [x] Same masking for AI assistant chat: the user's bubble, the stored
      transcript, and the AI's replies.
- [x] The AI never receives the raw phone number / abuse (sanitized before
      the Gemini call) and its system prompt forbids abusive language and
      phone-number sharing.
- [x] Clean text passes through unchanged.
- [x] Unit tests for the moderation service; `dart analyze` and
      `flutter analyze` clean.
- [x] OpenAPI spec and knowledge base updated.
