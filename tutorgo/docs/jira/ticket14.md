# TICKET-14: Quizzes & assignments, student-detail wiring, taskbar name

## Type
Feature

## Priority
High

## Status
Done

## Summary
1. **Quizzes (MCQ, auto-graded)**: a tutor creates an MCQ quiz for one of their students;
   the student takes it; the score is computed automatically and shown to both.
2. **Assignments (file upload, tutor-graded)**: a tutor creates an assignment for a student;
   the student uploads a file; the tutor views it and enters marks + feedback.
3. **Tutor student-detail fixes**: the **Message** quick action opens the chat with that
   student; **Session History** shows the real sessions (was hardcoded).
4. **Taskbar name**: the Windows taskbar/exe metadata says "tutorgo" — change the display
   metadata to NextStepLearning (binary name stays `tutorgo.exe`).

## Design
- Backend collections (one doc per task, submission embedded):
  - `quizzes`: `{tutorId, studentId, title, subject, questions:[{text, options[], correctIndex}],
    createdAt, submission:{answers[], score, total, submittedAt}|null}`
  - `assignments`: `{tutorId, studentId, title, description, createdAt,
    submission:{fileBase64, fileName, submittedAt}|null, marks|null, feedback|null, gradedAt}`
- Routes (protected):
  - Quizzes: `POST /api/quizzes`, `GET /api/quizzes` (role-scoped), `POST /api/quizzes/{id}/submit`
  - Assignments: `POST /api/assignments`, `GET /api/assignments`,
    `POST /api/assignments/{id}/submit`, `PUT /api/assignments/{id}/grade`
- Frontend: `QuizService`, `AssignmentService`; tutor create-quiz / create-assignment /
  grade screens; student "My Tasks" (list) + take-quiz + upload; wire tutor student-detail
  (studentId passed through, Message→chat, real session history, create + grade actions).
- Update OpenAPI spec.

## Acceptance Criteria
- [ ] Tutor creates an MCQ quiz for a student; student takes it; auto score visible to both.
- [ ] Tutor creates an assignment; student uploads a file; tutor grades (marks + feedback).
- [ ] Student can see assigned quizzes/assignments and their results.
- [ ] Message quick action opens the chat; session history is real.
- [ ] Taskbar/exe metadata reads NextStepLearning.
- [ ] `flutter analyze` + backend `dart analyze` pass; spec updated.
