# TICKET-16: Apple HIG design system + Gemini-powered AI assistant

## Type
Feature

## Priority
High

## Status
Done

## Summary
1. **Consistent look across the whole app** — adopt an Apple *Human Interface
   Guidelines*–inspired design system (system colours, HIG type scale, inset
   grouped surfaces, hairline separators, filled rounded controls) driven from
   the central theme so every screen shares the same style.
2. **AI assistant runs on Gemini** — switch the assistant backend from
   OpenRouter/Llama to Google's Gemini (`generateContent`) so it works when the
   backend is deployed, not only locally. All assistant features stay the same
   (role-aware prompt, user context, chat persistence, Enter-to-send, Clear).

## Design
### AI assistant (backend)
- `AiAssistantService.reply(...)` keeps the same signature and system prompt but
  now POSTs to `https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent`.
  - System prompt goes in `system_instruction`; history maps `assistant → model`,
    `user → user`; `generationConfig` sets `temperature: 0.3`, `maxOutputTokens: 500`.
  - Auth via `x-goog-api-key` header. Response text read from
    `candidates[0].content.parts[*].text`.
- `Env` gains `geminiApiKey` / `geminiModel` (default `gemini-2.0-flash`).
  `.env` / `.env.example` updated; the real key stays only in the gitignored
  `.env`.

### Design system (frontend)
- `AppColors` retuned to the Apple system palette (systemBlue `#007AFF`,
  grouped backgrounds, label greys, hairline separators) with light + dark values.
- `AppTypography` mapped to the HIG type scale (largeTitle → caption).
- `AppTheme` builds full light & dark `ThemeData`: a complete `TextTheme`, plus
  `appBarTheme`, `cardTheme`, `inputDecorationTheme`, `elevatedButton`/`filledButton`/
  `textButton`/`outlinedButton` themes, `listTileTheme`, `dividerTheme`,
  `switchTheme`, `chipTheme`, `dialogTheme`, `bottomSheetTheme`, `snackBarTheme`.
- Screens already read `Theme.of(context)` / `AppColors` / `AppTypography`, so the
  new tokens propagate app-wide without per-screen rewrites.

## Acceptance Criteria
- [x] AI assistant answers via Gemini with the same behaviour and features.
- [x] Gemini key/model configured through env; no secret committed.
- [x] Central theme provides one HIG-consistent style (colours, type, controls)
      in light and dark.
- [x] `flutter analyze` / `dart analyze` clean; Windows app builds and runs.
- [x] `knowledge_base.md` and the OpenAPI spec updated.
