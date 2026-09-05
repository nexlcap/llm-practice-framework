# Framework adoption: project-specific decisions

Kept outside the framework files so a refresh cannot clobber it. Fill every section; a reviewer
reads this file first.

## Scale

`<script | service | agentic product>` and one sentence on why.

## Panel roster for this project

| Seat | Roles |
|---|---|
| Domain pair | `<Role A>` ↔ `<Role B>`: `<the tension>` |
| Veto seat | `<Role>`: `<the irreversible resource>` (or "none: nothing irreversible", with the reason) |
| Data pair | ML Engineer ↔ Data Engineer |
| Security pair | Application Security ↔ Web / Content Security |
| Systems pair | Systems Security ↔ DevOps / Infrastructure |
| Engineering pair | Software Engineer ↔ Code Reviewer |
| Experience pair | UX Designer ↔ Data Visualization |
| Observer, Frame-Inversion | always |

## Scoping table

| Change type | Seats |
|---|---|
| Any change | Observer, Frame-Inversion, Engineering pair |
| `<your change type>` | + `<seats>` |
| Pure refactor | Engineering pair, Observer, Frame-Inversion |

## Gates

- Design gate: `<where it happens>`
- Spec gate: `<where it happens; where the verdict is attached>`
- Results gate: `<where it happens; read date>`
- Execution path: `<adapter or generic runner or separate chats>`

## Door audit (ADAPTING.md section 3)

| Rule | Status |
|---|---|
| Only the transport touches the vendor | `<met / not met: how>` |
| Unknown call sites raise | |
| Every registered id has a contract | |
| Transport never falls back | |
| Environment isolation | |
| Timeouts measured | |
| Log record minimum fields | |

## Backlog created by the adoption

- `<gap, owner, by-date>`

## Review log

| Date | Artifact | Seats | Verdict | Reports |
|---|---|---|---|---|
