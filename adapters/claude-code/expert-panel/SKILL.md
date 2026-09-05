---
name: expert-panel
description: Convene an independent expert review panel on a design, spec, plan, or build result. Use when the user says "consult the expert panel", "expert panel", "panel review", asks for a review of a design/spec/plan/results, or at the three build gates (design before presenting, spec before user review, results before conclusions). Dispatches separate reviewer subagents by role title, never inline role-play, and returns a consolidated Blockers / Modify-before-build / Approve-as-is verdict.
---

# Expert panel (generic)

This is the generic form. **Step 0, before anything else:** (a) if the current project has its own
`.claude/skills/expert-panel/SKILL.md`, read that file and follow it instead of this one; personal
skills shadow project skills of the same name, so this file cannot rely on the project's copy
loading by itself. (b) Otherwise read the project's `docs/llm-framework/LOCAL.md` and take the
roster, the scoping table, and the gates from it. (c) If neither exists, derive the domain pair(s)
and the veto seat from the project's purpose (README, spec), write them into `LOCAL.md` as a
proposal, and say in the verdict that the roster is proposed, not confirmed.

## When this fires

- The user says "consult the expert panel", "expert panel", "panel review", or asks for a review of
  a design, spec, plan, backtest, or result. Saying it once means dispatch now; never ask them to
  repeat it.
- At the three build gates, unprompted: before a design is presented, before the user reviews a
  spec, after a build's results and before any conclusion is stated.

## How to run it in Claude Code

1. **Scope the seats** with the project's scoping table in `LOCAL.md` (fallback: section 2 below)
   and name the domain roles from its roster. State in one line which seats convened and why.
2. **Put the artifact in a file** if it is not one already. Reviewers read files and code, never
   pasted text.
3. **Dispatch two to four reviewer agents in one message** with the Agent tool as fresh
   general-purpose subagents. Never use a fork: a fork inherits this session's context and defeats
   independence. Use a capable model for decision logic, prompts, and specs; a mid-tier model for
   mechanical diffs. Each agent gets: its roles by title, the artifact path, the code paths, the
   "push on" list, the output shape (section 4), and a report path under the project's scratch
   directory. It writes the full report there and returns only the verdict plus a five-line summary.
4. **Dispatch the Frame-Inversion Reviewer as its own agent** with the inverted-frame instruction
   from section 3.
5. **Consolidate** (section 5): any blocker blocks; fold modifications into the artifact; re-verify
   each finding against the code or data before adopting it; record refuted findings with evidence.
6. **Reproduce load-bearing verdicts** (section 6): re-dispatch the decisive pair until it agrees
   across runs; record the run count.
7. **Present** the reviewed artifact with the consolidated verdict, the seats convened, and the
   report paths.
8. **If every reviewer approved with nothing new**, say so and re-run with sharper "push on"
   instructions before presenting.

Never: role-play the reviewers in this session; give reviewers personal names; skip the
frame-inversion lens; present an artifact with modifications still unfolded.


Independent, multi-perspective review of any design, spec, or build result before a person sees it.
Reviewers are separate model sessions (subagents) with only the artifact and the relevant code in
context. The author never reviews its own work inline. This file is written to be dropped into any
project as a skill or a checklist; only the domain pair in the roster needs adapting.


Independent, multi-perspective review of any design, spec, or build result before a person sees it.
Reviewers are separate model sessions with only the artifact and the relevant code in context: fresh
delegated agents where the coding tool has them, separate command-line runs or chats where it does
not. The author never reviews its own work inline. The protocol is independent of the model, the
vendor, and the tool; `adapters/` holds the tool-specific ways to run it. Only the domain pair in the
roster needs adapting per project.

## 1. Roster

The roster is project-specific and lives in the project's `docs/llm-framework/LOCAL.md`. Read it
first; if it does not exist, derive a roster from the project's purpose using the table below,
write it into `LOCAL.md` as a proposal, and say so in the verdict. Never review a project with
another project's domain roles.

Six peer pairs plus two unpaired seats plus one lens, of which the domain pair(s) and the veto seat
change per project and the rest are cross-domain. Each pair exists because its members have
opposite blind spots; they challenge each other before presenting one reconciled position.

| Seat | Roles | The tension they resolve |
|---|---|---|
| Domain pair(s) | `<Domain Practitioner>` ↔ `<Domain Skeptic>` | Is the outcome real and usable vs. is the evidence sufficient. One pair per question the project must get right; a research project adds a methods pair (for example Social Scientist ↔ Research Methodologist) |
| Data pair | ML Engineer ↔ Data Engineer | Do labels, features, and framing match deployment vs. is the pipeline feeding them trustworthy |
| Security pair | Application Security ↔ Web / Content Security | Input handling, secrets, privilege vs. output rendering, injection, abuse |
| Systems pair | Systems Security ↔ DevOps / Infrastructure | Isolation and blast radius vs. deployment, failure modes, what breaks unattended |
| Engineering pair | Software Engineer ↔ Code Reviewer | Does the complexity earn its keep vs. edge cases, hidden coupling, tests that assert nothing |
| Experience pair | UX Designer ↔ Data Visualization | Can the user act on it vs. does the display say what the data says |
| Veto seat (unpaired) | `<Irreversible-resource Advisor>` | Anything that spends or commits an irreversible resource: money, legal exposure, personal data, reputation |
| Observer (unpaired, goes first) | Common Sense Observer | No domain background; asks "but why?"; experts must answer in plain language |
| Lens (always dispatched) | Frame-Inversion Reviewer | Reads the artifact as if it already shipped and caused the loss, then works back to what the framing hid |

**Adapting the domain pair(s).** Replace with the two roles whose disagreement matters most in the
project. Examples: Quant Trader ↔ Statistician for a trading system; Clinician ↔ Biostatistician for a
health product; Narrative Designer ↔ Community Moderator plus Social Scientist ↔ Research
Methodologist for a simulated community studied as an experiment; Support Lead ↔ Compliance Officer
for a customer-facing assistant. Add a pair when the project has a second question that a different
kind of expert would answer differently; drop to none only for a pure refactor. Replace the veto seat
with whoever owns the irreversible resource (tax, legal, privacy, spend, research validity).

**Rules of the roster.** Role titles only, never personal names. The observer speaks first, before
expert analysis, unfiltered. The frame-inversion lens is never skipped.

## 2. Scoping by change type

Convene only the seats the change touches. Proportionality is part of the protocol.

| Change type | Seats |
|---|---|
| Any change | Observer, Frame-Inversion, Engineering pair |
| Decision logic, model prompts, scoring, thresholds | + Domain pair, Data pair, Veto seat |
| New data source, scraper, credential, external text | + Security pair, Systems pair |
| Deployment, scheduling, process lifecycle, timeouts | + Systems pair |
| Dashboard, report, or anything a person reads | + Experience pair |
| Anything that spends, commits, or deletes | + Veto seat |
| Pure refactor with no behavior change | Engineering pair, Observer, Frame-Inversion only |

## 3. Dispatch

- **Two to four reviewer sessions, run in parallel.** Group seats by family (typically: domain +
  veto; security + systems; engineering + experience + observer). The frame-inversion lens is its
  own session.
- **Never role-play the panel inline.** The session that wrote the artifact cannot review it; with
  the artifact still in context every "reviewer" agrees with the author.
- **Each reviewer's prompt contains:** the roles it embodies (by title); the artifact path, to be read
  in full; the specific code files that matter; the build stage (what exists in code, what is design
  only), so a planned control is not reviewed as a shipped one; what to push on, named explicitly;
  the required output shape (section 4); and an instruction to challenge rather than approve, with
  examples of the kind of finding that would be valuable.
- **Say what to push on.** "Review this" produces approval. "Find the way this loses the user money in
  month three", "find the path where the guard is never called", "find the assumption the author
  made because they wrote the previous version" produce findings.
- **Give the frame-inversion reviewer the inverted frame explicitly.** "Assume this shipped, ran for a
  quarter, and caused a loss. Write the incident report. Then identify what in the artifact's framing
  made that outcome invisible."

### Reviewer prompt skeleton

```
You are reviewing <artifact> as a panel of <Role A> and <Role B>.
Read <artifact path> in full, then <code paths>.
Push on: <three to five named concerns>.
For each role: independent assessment, then the peer challenge (what the other role
disputes), then one reconciled position: agree / disagree-with-reasoning / escalate.
Verdict: exactly one of BLOCKERS, MODIFY-BEFORE-BUILD, APPROVE-AS-IS, with each finding
as: what, where (file:line or section), why it matters, what would resolve it.
Do not approve without surfacing at least one concern the author did not already list;
if you find none, say so and explain what you checked.
```

## 4. Output shape

Per pair:

1. Each role's independent assessment.
2. The peer challenge: what each role disputes in the other's assessment.
3. One reconciled position: agree, disagree-with-reasoning, or escalate.
4. Verdict in exactly one class:
   - **Blockers**: must be resolved before build; the reason and the resolving change.
   - **Modify-before-build**: specific changes, folded into the artifact before it is presented.
   - **Approve-as-is**: with what was checked, so a lenient prompt is visible.

Consolidated verdicts read like "MODIFY-BEFORE-BUILD (3 modify, 1 blocker absorbed)" or "3
independent groups, unanimous approve, frame-inversion 1 modify".

## 5. Consolidation

- Any blocker from any seat blocks.
- Modifications are folded into the artifact before the user sees it. The user confirms a design the
  panel has already vetted; they are not the first-line reviewer.
- Every finding is a hypothesis. The author re-verifies each one against the code or the data before
  adopting it, and records refuted findings with the evidence. Panels are independent, not infallible.
- The consolidated verdict, the seats convened, and the links to each reviewer's report are recorded
  with the artifact. Copy the reports into the repository; scratch directories do not survive.
- A blocked spec gate blocks the *build*, not the adoption: record the open blockers with the
  artifact, fix what is small and code-verified now, and carry the rest to the next gate. Expect
  the first gate on an existing codebase to find more than the design under review.

## 6. Reproducing load-bearing verdicts

A single blocker, or a clean approve on something risky, is load-bearing. First try to verify it
directly: a finding that names a file and a line is checked against the code, and a verified finding
needs no reproduction run. Reproduction is for judgment findings that cannot be checked that way.
For those, re-dispatch the decisive pair (fresh session, same prompt) and require agreement across
runs. Two independent lenses reaching the same blocker in one round also counts as reproduction.

- A blocker that does not reproduce is demoted to modify-before-build.
- An approve that does not reproduce means the concern is live; treat it as modify.
- Record the run count with the verdict ("K=3 convergence"). The logic is unanimity: a finding
  counts when it appears in every run of one arm and none of the other.

## 7. Gates

Three, for every change, no exceptions for "quick" work:

| Gate | When | The questions |
|---|---|---|
| Design | Before the design is presented | Is the problem framed right? What is the simplest thing that works? What breaks unattended? |
| Spec | Before the user reviews the spec | Is every fact injected, every identifier closed, every failure policy named? What did the framing hide? |
| Results | After the build, before conclusions | Are the numbers plausible against known values? Cause or effect? Alternative explanations? Honest limitations? Does anything consume the output? |

## 8. Quality check on the panel itself

- If every reviewer approves and nothing new surfaced, the prompts were too lenient. Re-run with
  sharper "push on" instructions before recording the approval.
- The product of a panel is the surprising concern: the one the author did not already list.
- Findings about code adjacent to the change are welcome and are recorded separately as latent
  issues; reviewers read the surrounding code, not only the diff.
- The panel advises; the user decides. A panel argument that rests on the user's personal traits or
  habits is out of scope unless the user put it in scope.

## 9. Running it

Any tool works as long as each reviewer gets a fresh context, the artifact, and the code. With a
coding agent that can delegate to fresh-context agents, dispatch them in parallel. With a plain
command-line model or an HTTP API, run each reviewer as a separate invocation; `adapters/generic/`
has a runner and the four reviewer prompts. `adapters/` lists the tool-specific forms.

## 10. Cost

Two to four reviewer runs per gate, each reading the artifact plus code. The scoping table keeps it
proportionate. The justification, every time: a wrong decision, a wrong rule, or a misleading display
costs more than a few minutes of independent review.
