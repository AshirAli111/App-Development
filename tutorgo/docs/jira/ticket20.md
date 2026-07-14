# TICKET-20: Replace onboarding animation with real student/tutor photos

## Type
Chore

## Priority
Medium

## Status
Done

## Summary
The onboarding screen currently shows a remote Giphy animation (a cartoon sheep
with glasses) at the top. Replace it with an auto-scrolling carousel of five
real student/tutor photos bundled as local assets, giving the welcome screen a
more authentic, on-brand feel and removing the dependency on a remote GIF.

## Details
- Remove the `Image.network(...)` Giphy animation from
  `onboarding_screen.dart`.
- Add five provided photos as local assets:
  `assets/images/onboarding_1.png` … `onboarding_5.png`.
- Display them in an auto-advancing `PageView` carousel with rounded corners and
  page indicator dots, preserving the existing FadeIn entrance animation.

## Acceptance Criteria
- [x] Giphy remote animation removed from the onboarding screen.
- [x] Five provided images copied into `assets/images/`.
- [x] Onboarding shows the photos in a carousel that auto-scrolls.
- [x] App builds and runs on Windows.
- [x] `docs/knowledge_base.md` updated.
