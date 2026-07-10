# TICKET-08: Course selection for students & tutors + course-based tutor discovery

## Type
Feature

## Priority
High

## Status
Done

## Summary
Sessions/schedule show "General" because tutors have no courses set and bookings default
to "General". Introduce a real course model:

- **Students** pick courses from a **fixed list** (chips), editable in Edit Profile.
- **Tutors** pick courses from the **fixed list + can add custom courses**; custom courses
  are visible to students. Editable in Edit Profile.
- **Courses page (tutor discovery)**: by default shows only tutors teaching the student's
  selected courses; a **"All Courses"** chip shows every tutor; each course chip filters to
  that course.
- **Booking**: the student picks the course from the tutor's taught courses (default = the
  tapped one), so the booked session carries a real course (no more "General").

## Design decisions
- Canonical list lives in `lib/core/constants/courses.dart` (`kCourses`).
- Student courses → `studentProfile.selectedCourses` (existing field).
- Tutor courses → `tutorProfile.subjects` (existing field); tutors may add values outside
  `kCourses` (custom).
- Discovery filter chips: **"My Courses"** (default when the student has courses; union of
  their selected courses) · **"All Courses"** (everyone) · one chip per selected course.
- Tutor map passed to the popup gains `courses` (full subjects list) so the booking sheet can
  offer a course dropdown.

## Acceptance Criteria
- [x] Shared `kCourses` constant; student setup + both edit screens use it.
- [x] Student Edit Profile: multi-select course chips (fixed list), load + save.
- [x] Tutor Edit Profile: multi-select chips + "add custom course", load + save.
- [x] Courses page filters by the student's selected courses, with "All Courses" override.
- [x] Booking course = dropdown of the tutor's courses (default = tapped course).
- [x] `flutter analyze` passes for changed files.

## Follow-up refinements (same ticket)
- Student Edit Profile course chips now also include every course tutors currently
  teach (custom ones), so students can pick + book custom courses. Fixed a bug where
  student setup saved courses under `interests` instead of `selectedCourses`.
- Courses page filter chips include all tutor-taught courses (custom included), so a
  custom course is filterable and shows under "All Courses" like any fixed course.
- Tutor Home → My Students lists one tile per (student, course) with the course name;
  the "Students" stat still counts distinct students.
- Tutor Schedule: each session card has **Reschedule** (day/time sheet →
  `updateSession`) and **Cancel** (Yes/No confirm → `cancelSession`).
- Note: sessions booked before this ticket keep `subject: "General"`; new bookings
  carry the chosen course.
