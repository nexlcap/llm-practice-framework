# Review log

This framework's own panel reviews, under its own protocol (`panel-protocol.md` section 5: the
reports are copied into the repository, and each session's own verdict is recorded beside the
consolidated one). Each directory holds the consolidated verdict (`0-consolidated.md`) and one report
per reviewer session.

| Date | Artifact | Gate | Seats | Per-seat verdicts | Consolidated verdict | Reports |
|---|---|---|---|---|---|---|
| 2026-10-12 | the published framework at 4c8d6ce | design and spec, combined | Domain + Veto; Security + Systems; Engineering + Experience + Observer; Frame-Inversion (4 sessions) | BLOCKERS; MODIFY-BEFORE-BUILD; MODIFY-BEFORE-BUILD; BLOCKERS | BLOCKERS (7), folded in on branch `panel-2026-10-12` | `2026-10-12-panel/` |
| 2026-10-12 | the revision at f0c0a9b | spec, before merge | Domain + Data + Veto; Security + Systems; Engineering + Experience + Observer; Frame-Inversion (4 sessions, each resumed once after a session limit) | MODIFY-BEFORE-BUILD; MODIFY-BEFORE-BUILD; MODIFY-BEFORE-BUILD; BLOCKERS | BLOCKERS (2), folded in on the same branch | `2026-10-12-panel-2/` |
| 2026-10-12 to 13 | the cut revision at b41ba8d | spec, before merge | Engineering + Experience + Observer (with a shell on a scratch copy); Frame-Inversion (2 sessions, the first resumed once after a usage limit) | BLOCKERS; BLOCKERS | BLOCKERS (3), folded in on the same branch | `2026-10-12-panel-3/` |

The roster for all runs was proposed by the dispatching session, not confirmed by a `LOCAL.md`,
because this repository is the framework rather than an adopter. Findings refuted or declined are
listed in each consolidated verdict with the evidence. The protocol's second-person rule for a
refuted or demoted blocker (section 5) applies at Service scale; this repository is one person's,
and every blocker in the three runs was folded in rather than refuted.
