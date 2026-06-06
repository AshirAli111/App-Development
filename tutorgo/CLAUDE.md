# CLAUDE.md - TutorGo Project Instructions

## Rules

1. **Always update `docs/knowledge_base.md`** whenever there is a meaningful change to the project (new screens, dependencies, architecture changes, services, routes, etc.). Keep it accurate and current.

2. **Always ensure `README.md` commands are relevant** for a developer to run and test the project on their local machine. If dependencies change, build steps change, or new setup is required, update the README immediately.

3. **Always commit changes right away.** After completing any task, stage and commit the changes immediately. Do not let work sit uncommitted.

4. **Every prompt must start with a ticket.** Before implementing any feature or task:
   - Create a `ticketXX.md` file under `docs/jira/` (e.g., `ticket01.md`, `ticket02.md`, etc.)
   - **Optimize the prompt first** — ask relevant clarifying questions to the user before writing the ticket. The goal is to make the ticket detailed enough for implementation without ambiguity.
   - Only create the ticket after questions are answered and requirements are clear.

## Ticket Workflow

All tickets follow a Jira-style workflow. Update the `## Status` field in the ticket file as work progresses:

| State | When |
|-------|------|
| **To Do** | Ticket created, work has not started |
| **In Progress** | Implementation has begun |
| **Done** | Feature fully implemented, tested, and committed |

### Ticket Template

Every ticket must include at minimum:
- **Type** (Feature / Bug / Chore)
- **Priority** (High / Medium / Low)
- **Status** (To Do / In Progress / Done)
- **Summary** — what needs to be built
- **Acceptance Criteria** — checklist of what "done" looks like

### Workflow Rules

- When you start working on a ticket, update its status to `In Progress`
- When all acceptance criteria are met and code is committed, update its status to `Done`
- Never start implementation without a ticket in place
- Reference the ticket number in commit messages (e.g., `feat(TICKET-01): implement user auth`)
