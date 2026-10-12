# Framework adoption: project-specific decisions

Kept outside the framework files so a refresh cannot clobber it. Fill every section; a reviewer
reads this file first. The source repository and framework version are in `.adopt` beside this file.

## Scale and shapes (ADAPTING.md section 1)

Scale: `<script | service | agentic product>` and one sentence on why.
Shapes present: `<scheduled artifact | request-response | conversation | agentic session>`, one line
per call site.

## Instructions files (ADAPTING.md section 2)

`<AGENTS.md | CLAUDE.md | GEMINI.md | .cursor/rules/...>`, one per tool the team uses; `adopt.sh`
runs once per file.

## Panel roster for this project (ADAPTING.md section 5)

| Seat | Roles |
|---|---|
| Domain pair | `<Role A>` ↔ `<Role B>`: `<the tension>` |
| Second domain pair (if the project has a second question, e.g. a research method) | `<Role C>` ↔ `<Role D>`: `<the tension>` or "none" |
| Veto seats, one per irreversible resource | `<Role>`: `<money, personal data, a message sent, or a legal position>`; `<Role>`: `<...>` (or "none: nothing irreversible", with the reason) |
| Data pair | ML Engineer ↔ Data Engineer |
| Security pair | Application Security ↔ Web / Content Security |
| Systems pair | Systems Security ↔ DevOps / Infrastructure |
| Engineering pair | Software Engineer ↔ Code Reviewer |
| Experience pair | UX Designer ↔ Data Visualization Specialist |
| Observer, Frame-Inversion Reviewer | always |

## Scoping table (panel-protocol.md section 2)

| Change type | Seats |
|---|---|
| Any change | Observer, Frame-Inversion Reviewer, Engineering pair |
| `<your change type>` | + `<seats>` |
| Removing a human control | + Domain pair, Veto seats |
| Pure refactor | Engineering pair, Observer, Frame-Inversion Reviewer |

## Gates (ADAPTING.md section 5.6)

- Design gate: `<where it happens>`; "the user" is `<role>`
- Spec gate: `<where it happens; where the verdict is attached>`; "the user" is `<role>`
- Results gate: `<where it happens; read date>`; "the user" is `<role>`
- Execution path: `<adapter | generic runner with .panel.env | separate chats>`
- CI check that a panel report is linked: `<job name | planned(by date)>`

## Door audit (ADAPTING.md section 3)

| Rule | Status |
|---|---|
| Only the transport touches the vendor | `<met / not met: how>` |
| Unknown call sites raise | |
| Every registered id has a contract | |
| Transport never falls back; retries bounded with idempotency keys | |
| Environment isolation | |
| Timeouts measured | |
| Model ids are pinned snapshots with retirement dates | |
| Log record minimum fields | |

## Rules added or dropped for this project

- `<rule, added or dropped, reason, date>`

## Backlog created by the adoption

- `<gap, owner, by-date>`

## Framework read date (README.md P8, applied to this adoption)

`<YYYY-MM-DD>`. Metrics: contracts whose "last reviewed" is within 90 days; panel findings adopted
versus refuted per seat; incidents with a pinned test; expired TBDs. Kill criteria per practice:
`<e.g. drop the design gate for changes under n lines if two quarters of design-gate verdicts were
approve>`.

## Review log

| Date | Artifact | Seats | Verdict | Reports |
|---|---|---|---|---|
