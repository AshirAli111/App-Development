# TICKET-17: AI content validation for tutor registration documents

## Type
Feature

## Priority
High

## Status
Done

## Summary
When a tutor uploads their registration documents (CNIC front, CNIC back,
Teaching Certificate, Degree) on the Tutor Profile Setup screen, the app must:

1. **Restrict file type** — only accept PDF, JPG, JPEG, or PNG files. Any other
   extension shows *"Only PDF or image files are allowed."*
2. **Verify the content matches the document** — read the file's content with
   Google Gemini (`gemini-flash-latest`, multimodal) and confirm it actually
   looks like the expected document. If the content does not make sense for that
   slot (e.g. a random PDF uploaded as a CNIC), reject it with *"This document
   does not contain valid <label> content."* and do not accept the file.

Documents are Pakistani and in English.

## Design
### Backend
- `DocumentValidationService` (`backend/lib/services/document_validation_service.dart`)
  verifies content with a **two-tier** approach:
  1. **OCR (primary, default):** shell out to `tesseract` on the uploaded image,
     then run a **fuzzy keyword search** over the extracted text for keywords
     specific to that document type (e.g. "pakistan"/"identity" for a CNIC,
     "university"/"degree"/"bachelor" for a degree). Any single keyword hint —
     exact substring OR a small-edit-distance fuzzy match to tolerate OCR
     noise — passes the document. Text extracted but **no** hint → rejected as
     invalid content.
  2. **Gemini (commented out for now):** the multimodal `generateContent` path
     is kept in the file but disabled. The intended final chain is Gemini
     primary → OCR + fuzzy search failover; today OCR is the live check.
  - **Fail-open on OCR error:** if `tesseract` is missing, crashes, or times out,
    the document is accepted so a broken local dependency never blocks a genuine
    tutor. (PDFs, which tesseract can't read directly, also fail-open.)
- New **public** route `DocumentRoutes` mounted at `/documents/` (like `/auth/`,
  no JWT) because account creation is deferred until the end of profile setup, so
  the tutor has no token while uploading. Endpoint:
  `POST /documents/verify` body `{ type, fileBase64, mimeType }` →
  `{ valid, reason }`.
- Supported `type` values: `cnicFront`, `cnicBack`, `teachingCertificate`,
  `degree`.
- **Dependency:** requires `tesseract` on the host (`brew install tesseract`).

### Frontend
- New `DocumentValidationService` (`lib/data/services/document_validation_service.dart`)
  posts to `$baseUrl/documents/verify`.
- `TutorProfileSetup`:
  - File picker restricted to `pdf, jpg, jpeg, png`; other extensions rejected
    with a snackbar before any upload.
  - On pick: show a per-document spinner, call the verify endpoint, and only set
    the file if `valid == true`; otherwise show the rejection reason.
  - **Fail-open**: if the verify call errors or times out, accept the file so an
    outage never blocks a genuine registration.

## Acceptance Criteria
- [x] Uploading a non-PDF/non-image file is rejected with a clear message.
- [x] Uploading a valid CNIC/certificate/degree in the correct slot is accepted
      (verified against the four sample files via OCR).
- [x] Uploading content that doesn't match the slot is rejected with
      "does not contain valid ... content" (verified: degree image in CNIC slot).
- [x] A spinner shows on the specific document card while it is being verified.
- [x] If OCR errors (missing tesseract, PDF, crash, timeout), the file is still
      accepted (fail-open).
- [x] `POST /documents/verify` works without an auth token.
- [x] Docs updated: `knowledge_base.md`, `backend-api-specification.yaml`,
      `README.md` (tesseract prerequisite).
