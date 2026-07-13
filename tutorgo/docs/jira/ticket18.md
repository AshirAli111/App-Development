# TICKET-18: Store tutor document OCR results on the user record for admin verification

## Type
Feature

## Priority
High

## Status
Done

## Summary

When a tutor submits their registration documents (CNIC front, CNIC back,
teaching certificate, degree), the backend already runs OCR on each file during
`POST /documents/verify` — but the extracted text is discarded after the
valid/invalid verdict. An admin who wants to verify a tutor today has to open
the base64 document images by hand.

Store the OCR output in MongoDB **on the same `users` document**, under a new
`ocrResults` field, so an admin inspecting the database can read the extracted
content directly and cross-check it against the tutor's registered profile.

`ocrResults` shape:

```json
{
  "extractedName":       "<name parsed from the CNIC front, or null>",
  "extractedCnicNumber": "<CNIC number (#####-#######-#) parsed from CNIC front/back, or null>",
  "documents": {
    "cnicFront":           { "status": "extracted | unreadable | unsupported | ocr_unavailable", "text": "<raw OCR text>" },
    "cnicBack":            { "...": "..." },
    "teachingCertificate": { "...": "..." },
    "degree":              { "...": "..." }
  },
  "extractedAt": "<ISO date>"
}
```

## Design decisions

- **Where OCR runs:** server-side, inside the existing document ingestion point
  `PUT /api/users/me` (tutor profile setup sends `tutorProfile.documents` as
  base64 there). The client is not changed and cannot tamper with the stored
  text.
- **Async, fire-and-forget:** OCR of up to 4 documents can take tens of
  seconds worst-case. The profile update responds immediately; the
  `ocrResults` field is written by a background task moments later, so
  registration UX is unaffected. Failures are logged to the server console.
- **DB-only field:** `ocrResults` is written directly to the `users`
  collection and is **not** exposed through `toPublicMap()` / any API response
  — it contains CNIC numbers and must not leak to students browsing tutors.
  Admins read it straight from the database (Atlas/Compass), which is the
  stated use case.
- **Mime sniffing:** stored documents are bare base64 with no mime type, so
  the file type is sniffed from magic bytes (PNG/JPEG/WebP images are OCR'd;
  PDFs and unknown formats are recorded as `unsupported`).

## Acceptance Criteria

- [x] `PUT /api/users/me` with `tutorProfile.documents` triggers OCR of every
      supplied document and stores the results under `ocrResults` on the same
      user document.
- [x] `ocrResults` contains per-document raw OCR text plus a parsed
      `extractedName` and `extractedCnicNumber` for admin cross-checking.
- [x] Re-uploading documents overwrites the previous `ocrResults`.
- [x] `ocrResults` is never returned by any public API response.
- [x] Profile update latency is unchanged (OCR runs after the response).
- [x] OpenAPI spec and knowledge base updated.
- [x] `dart analyze` clean on the backend; `flutter analyze` clean on the app.

## Follow-up fixes (same ticket)

Verified end-to-end against the live Atlas database and found the field never
appeared — two pre-existing problems were blocking it:

1. **Tutor documents were never stored at all.** Registration writes
   `tutorProfile.documents: null`; the profile-setup update then `$set`s
   dot-paths like `tutorProfile.documents.cnicFront`, and MongoDB rejects
   dot-paths through a null parent — so the whole profile update (subjects,
   experience, documents) failed **silently** for every tutor to date.
   Fixed in `UserService.updateUser`: `tutorProfile.documents` is now written
   atomically as one map (profile setup always sends the full set), and write
   errors now throw instead of returning the unchanged user.
2. **Tesseract was not installed on the backend host**, so even the verify
   endpoint had been fail-open accepting documents unread. Installed
   (`winget install UB-Mannheim.TesseractOCR`, v5.4.0) and added to PATH.

Also added `bin/backfill_ocr_results.dart` (one-off script: OCRs the stored
documents of existing tutors and writes their `ocrResults`; `--force` redoes
all) — note existing tutors have no stored documents due to bug #1, so only
tutors registering after this fix get real OCR data. Verified end-to-end with
the sample documents: registered a test tutor ("OCR Test Tutor"), submitted
all four sample files, and confirmed `ocrResults` in Atlas with full OCR text
and a parsed CNIC number.
