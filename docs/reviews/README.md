# Review log

This framework's own panel reviews, under its own protocol (`panel-protocol.md` section 5: the
reports are copied into the repository). Each directory holds the consolidated verdict
(`0-consolidated.md`) and one report per reviewer session.

| Date | Artifact | Gate | Seats | Verdict | Reports |
|---|---|---|---|---|---|
| 2026-10-12 | the published framework at 4c8d6ce | design and spec, combined | Domain + Veto; Security + Systems; Engineering + Experience + Observer; Frame-Inversion (4 sessions) | BLOCKERS (7), folded in on branch `panel-2026-10-12` | `2026-10-12-panel/` |
| 2026-10-12 | the revision at f0c0a9b | spec, before merge | Domain + Data + Veto; Security + Systems; Engineering + Experience + Observer; Frame-Inversion (4 sessions, each resumed once after a session limit) | BLOCKERS (2), folded in on the same branch | `2026-10-12-panel-2/` |

The roster for both runs was proposed by the dispatching session, not confirmed by a `LOCAL.md`,
because this repository is the framework rather than an adopter. Findings refuted or declined are
listed in each consolidated verdict with the evidence.
