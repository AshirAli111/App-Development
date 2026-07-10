# TICKET-07: Sync OpenAPI spec with TICKET-06 backend changes

## Type
Chore

## Priority
Medium

## Status
Done

## Summary
`docs/backend-api-specification.yaml` drifted from the actual backend routes after
TICKET-06. Bring it back in sync.

## Changes
- `PUT /api/users/me`: email is now updatable (description previously said it wasn't);
  documented a `409` (email already in use) and `400` (update failed) response.
- `UpdateUserRequest`: added the `email` property.
- Added a reusable `Conflict` (409) response component.
- `Session` schema: added the read-only enrichment fields returned by
  `GET /api/sessions/` — `studentName`, `studentImage`, `tutorName`, `tutorImage`.

## Acceptance Criteria
- [x] Spec reflects that email can be changed via `PUT /api/users/me`.
- [x] `409` documented for duplicate email.
- [x] Session responses document the enriched name/image fields.
- [x] YAML is valid.
