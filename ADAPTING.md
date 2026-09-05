# Adapting the framework to your project

This is the step-by-step guide. `README.md` says what the framework is; this file says how to make
it yours: which parts apply at your scale, how to install the documents, how to build the one door
in your language, how to tailor the panel to your domain and your tool, and how to keep the copy
current. Budget an afternoon for steps 1 to 5, an hour per model call for step 4, and another half
day for the first panel gate: on an existing codebase it will find defects in code the artifact
merely describes, and folding those in is part of adoption, not a detour from it.

---

## 1. Decide the scale first

The framework is proportionate by design. Pick the row that describes the project and adopt that
column; grow into the next row when the project does.

| Scale | What it looks like | Mandatory | Optional until it hurts |
|---|---|---|---|
| **Script** | One or two model calls, one person, output read by that person | Injected facts, structured output with schema validation, one function that makes the call, a log line per call, one recorded fixture, one separate reviewer session before relying on it | Registry, throttle, evaluation file, full panel |
| **Service** | Calls in production, other code or people depend on the output | Everything in the core: contract per call, one door with guard and inventory tests, guard layers, failure policy, per-call log with outcome classes, staleness surfaces, incident-pinned tests, evaluation with a read date, panel at the three gates | Throttle with live utilization, drift detection |
| **Agentic product** | The model can act: call tools, write data, message people | Everything above, plus tool allowlists, a validating tool server, injection scrub and fence on all external text, the security and systems pairs at every gate | Nothing; all of it applies |

Write the chosen scale in `docs/llm-framework/LOCAL.md` and in the project's instructions file above
the pasted rules (not inside the framework files, which refreshes overwrite). Reviewers will hold you
to it.

---

## 2. Install the documents

From the framework checkout:

```
./adopt.sh /path/to/project                 # detects AGENTS.md, CLAUDE.md, GEMINI.md
./adopt.sh /path/to/project .cursor/rules/llm.md   # or name the instructions file yourself
```

This copies `README.md`, `ADAPTING.md`, `call-site-contract.md`, `evaluation.md`,
`panel-protocol.md`, and `agent-rules.md` into `docs/llm-framework/`, creates `LOCAL.md` from a
template if it does not exist, creates `contracts/` and `evaluations/`, and appends `agent-rules.md`
to the instructions file once. If no instructions file exists it infers the tool from its config
directory and says which file it chose; check that your tool actually reads that file. Re-running
is safe and never touches `LOCAL.md`.

Without the script: copy the same files and paste `agent-rules.md` into whatever your coding agent
reads. If your team uses no coding agent, paste it into `CONTRIBUTING.md` and add the pull-request
checklist from `README.md` section 6 to the PR template. The rules are for people as much as for
agents.

The script creates:

```
docs/llm-framework/LOCAL.md       # scale, roster, scoping table, gates, door audit, backlog, review log
docs/llm-framework/contracts/     # one call-site contract per model call
docs/llm-framework/evaluations/   # one pre-registration per model feature (copy evaluation.md)
```

If the project already has a door module, do the door audit in `LOCAL.md` before writing any
contract: one row per rule in section 3, met or not met and how. The gaps become the first backlog.

---

## 3. Build the one door

One module owns every model call. Its shape is the same in any language:

```
llm/
  transport     talks to the vendor (HTTP, SDK, or a command-line client); the ONLY file that
                imports the vendor library or names its endpoint
  complete()    the single entry point: complete(call_site, prompt, schema, effort, timeout)
  registry      the allowlist: call-site id -> owner, contract path, default effort and timeout
  log           writes one record per call, success or failure, before returning
  throttle      (service scale and up) priority, concurrency cap, pause on limit errors
```

Rules to enforce on day one, each with a test:

- **Only `transport` imports the vendor.** A guard test greps or parses the whole codebase for the
  vendor's import, module name, endpoint host, or command name, and fails on any hit outside
  `transport`. Add the test before the second call site exists.
- **Unknown call sites raise.** `complete()` looks the id up in the registry and raises on a miss.
  No default route.
- **Every registered id has a contract.** An inventory test walks the registry and asserts a file
  exists at `docs/llm-framework/contracts/<id>.md` with no unfilled template placeholder (the
  backticked `<...>` form). Fields that cannot be known before the call runs (measured latency,
  cadence, quota share) are written as `TBD(reason, by YYYY-MM-DD)`. The test enforces three
  things: a bare `TBD` or `TODO` anywhere in a contract fails; a `TBD(...)` without a by-date fails;
  a `TBD(...)` whose by-date has passed fails. The last one is deliberate: an expired provisional
  field turns the suite red until someone either fills it in or consciously moves the date, and
  the moved date is a visible diff. Nothing else expires a TBD. Let the by-date match across a
  line wrap (`by\s+YYYY-MM-DD`); prose reflows.
- **The transport never falls back.** On error, timeout, or limit it raises a typed error; the call
  site chooses skip-loudly, keep-last-good, or abort. A test asserts no retry to another model.
- **Environment isolation.** The transport runs with an explicit environment allowlist, its own
  config directory, credentials handled in one place, a model whitelist, and a pinned client
  version. Credentials never appear in the log; the log carries a hash of the prompt.
- **Timeouts are measured.** Ship with a generous ceiling, log durations for a week, then set
  p95 times a margin per call site in the registry.

Log record, minimum fields: timestamp, call site, model, effort, duration, input and output tokens
if available, outcome class (`ok`, `parse_failure`, `api_error`, `timeout`, `refused`,
`rate_limited`), prompt hash, output hash. Put it wherever your project keeps operational data; a
table or an append-only file both work. Liveness is "last `ok` record for this call site is younger
than its cadence", computed from this log and nothing else.

### 3.1 Retrofitting onto code that already calls a model

Most adoptions are not green-field. If a transport layer and call sites already exist:

1. **Inventory before anything.** List every place that reaches the model, including tests and
   scripts. Grep for the vendor's import, endpoint, or command name; the list is the first version
   of the registry.
2. **Audit the door** against the six rules above, one row each in `LOCAL.md`, met or not met and
   how. Gaps become the backlog with by-dates. Do not fix them all first; the audit is the map.
3. **Register every existing call site now**, even ones without a contract yet, and turn on the
   "unknown call sites raise" check. This freezes the surface: nothing new gets added unregistered
   while contracts are backfilled.
4. **Backfill contracts in order of cost of being wrong**, one per sitting, and mark what the code
   does not yet do as `TBD(...)` rather than describing the design as if it were built. A contract
   that describes planned controls as present is the most common retrofit defect; reviewers read it
   as a security claim.
5. **Add the guard and inventory tests** before the next feature lands, not after.

---

## 4. Write the first contract

Choose the call with the highest cost of being wrong, not the easiest one. Copy
`call-site-contract.md` to `docs/llm-framework/contracts/<id>.md` and fill every field. For an
agentic call (the model acts through tools) the output schema is each tool's argument schema and the
closed vocabularies are enforced by the tool server; say so in the contract rather than leaving the
fields blank. Register the id in the registry at the same time so the inventory test guards the
contract from day one. Then
implement in this order, because each step constrains the next:

1. **Validators first.** Schema, closed-vocabulary check, numeric copy check, suppression rules.
   They define what the output may be before you ask for it.
2. **Fixtures second.** Run the call by hand a few times, save the raw outputs (good and bad) as
   fixture files, and write the tests against them. Include a malformed one and a fully-rejected one.
3. **Prompt third.** Role, doctrine, injected facts, closed vocabularies, task, output schema, worked
   examples. Ask for citations of the evidence used.
4. **Log and surfaces fourth.** Confirm the record lands and the "as of" shows where the output is
   read.
5. **Evaluation file last.** Metric, control, read date, kill criterion, in
   `docs/llm-framework/evaluations/<id>.md`. Put the read date in a calendar.

A contract is done when a reviewer can answer, from the contract alone, what happens when the call
fails, what the output may contain, and how you will know whether it was worth it.

---

## 5. Tailor the panel

### 5.1 Choose the domain pair

Ask: which disagreements cost this project the most when they are settled wrongly? Name the two
roles that hold each position. They must have opposite blind spots; two roles that would agree are
one role. Most projects have one such question; a project that is also an experiment has two (the
product question and the method question) and gets two pairs. The panel reads the roster from
`LOCAL.md`, so once it is written there every gate uses it without retyping.

| Project type | Domain pair | The tension |
|---|---|---|
| Trading or investing | Quant Trader ↔ Statistician | Tradeable edge vs. statistical sufficiency |
| Health or clinical | Clinician ↔ Biostatistician | Fits practice vs. evidence quality |
| E-commerce or growth | Merchandiser ↔ Experimentation Lead | Sells vs. measured uplift |
| Legal or compliance | Practitioner ↔ Regulator's Examiner | Workable vs. defensible |
| Education | Teacher ↔ Learning Scientist | Engages vs. demonstrably teaches |
| Simulated community or game | Narrative Designer ↔ Community Moderator | Believable vs. safe |
| Any project run as a research experiment | + Social Scientist ↔ Research Methodologist | Interesting finding vs. defensible design (power, blinding, confounds) |
| Internal tooling | Power User ↔ Support Owner | Fast for experts vs. survivable for everyone |
| Data pipeline | Analyst who consumes it ↔ Source-system Owner | Useful vs. faithful to the source |

### 5.2 Choose the veto seat

What can this project do that cannot be undone? Money spent, a record deleted, a message sent,
personal data exposed, a legal position taken. The veto seat is the role that owns that resource:
Tax or Treasury, Privacy Officer, Safety Lead, Counsel. If nothing is irreversible, drop the seat
and say so in the scoping table.

### 5.3 Write your scoping table

Copy the table in `panel-protocol.md` section 2 and replace the change types with the ones your
project actually has (for example: "new persona generator", "new scraper", "prompt change",
"schema migration"). Every row keeps the observer, the frame-inversion lens, and the engineering
pair. Add the domain pair to rows that change what the model decides, the security and systems pairs
to rows that add a surface, the veto seat to rows that spend or delete.

### 5.4 Pick the execution path for your tool

| Your tool can... | Do this |
|---|---|
| Delegate to fresh-context agents in parallel | Use or write an adapter: a short header that says how to dispatch, followed by the protocol body. `adapters/claude-code/` is the pattern; `adapters/README.md` says what an adapter must and must not do. Tools discover skills at session start, so restart sessions after installing. |
| Run a model from the command line | `adapters/generic/panel-run.sh` with `LLM_REVIEW_CMD` set. Reviewers get the artifact and code inlined. Put the change-specific concerns in `PANEL_PUSH_ON`. |
| Only chat | Open one fresh chat per reviewer prompt in `adapters/generic/prompts/`, paste the prompt and the artifact, save each reply as a report. Separate chats are separate contexts; this is a valid panel. |

The one thing no path may do is ask the session that wrote the artifact to review it.

### 5.5 Tell reviewers the build stage

Every reviewer prompt states what exists in code and what is design only, and every contract
carries a build-stage line and a status column on its validators. The single largest class of
findings in a retrofit gate is "the contract describes a control that is not built"; stating the
stage up front turns those into a checklist instead of blockers.

### 5.6 Put the gates in the workflow

Decide where each gate physically happens and write it down:

- **Design gate**: before the design is shown to whoever approves it. In a solo project, before you
  start building.
- **Spec gate**: before the spec is marked ready. Attach the consolidated verdict to the spec.
- **Results gate**: before conclusions are stated or the feature is called done. Attach the verdict
  to the PR or the results document.

Add "panel verdict linked" to the PR template. A solo developer runs the same gates; the minimum
viable panel is three sessions: engineering pair, observer, frame inversion.

---

## 6. Tests, observability, and evaluation in your stack

- **Fixture recording.** Add a flag that, when set, writes each raw model output to a fixtures
  directory named by call site and timestamp. Record for a day, curate, commit. Tests read fixtures
  only; no test calls the model. Add one opt-in live smoke test that says in its name that it
  spends budget.
- **Guard tests.** One for the vendor import, one for the registry inventory, one for secrets in
  log records, one per architectural rule you add later.
- **Incident pins.** When a model call misbehaves in production, the fix ships with a test whose
  description opens with the date and one line of what happened. Over time this is the project's real
  history.
- **Surfaces.** Wherever a model-produced artifact is shown, show its age. On the operations page,
  show the call log's outcome classes per call site for the last day and the liveness per call site.
- **Alerts.** Start with: five parse failures per hour per call site, any API error class above ten
  per hour, silence longer than twice the cadence. Tune from the log after two weeks.
- **Evaluation.** On the read date, compare against the control written in the evaluation file, and
  record the result in the same file. Remove features that miss the kill criterion and keep the
  file as the record of why.

---

## 7. Keep the copy current

The documents are copied, not linked, so a project's copy does not change under it. To refresh:

```
./adopt.sh /path/to/project     # overwrites the five framework files, leaves everything else
```

Keep project-specific additions out of those five files so a refresh cannot clobber them:

- `docs/llm-framework/LOCAL.md` for the scale decision, the domain pair, the veto seat, the scoping
  table, and where the gates live.
- `docs/llm-framework/contracts/` and `docs/llm-framework/evaluations/` for the per-call material.

Diff before committing a refresh, and re-run the panel's spec gate on any project document a
changed rule invalidates.

---

## 8. Mistakes people make when adapting

- **Pasting the rules and keeping direct vendor calls elsewhere.** A rule without a guard test is
  a suggestion. Build the door and the test before writing the second call.
- **Filling in the panel yourself.** A checklist the author ticks is inline role-play. Every
  reviewer is a separate session.
- **Copying the roster verbatim.** A trading pair reviewing a tutoring product finds nothing. Do
  step 5.1.
- **Adding a sentence to the prompt when the model misbehaves.** Add a guard layer instead, then
  test it with a fixture that reproduces the misbehavior.
- **Guessing timeouts.** Measure for a week first. A guessed timeout either kills good calls or
  hides a hung one.
- **Skipping the read date.** A model feature without a kill criterion is permanent by default,
  whether or not it works.
- **Treating panel findings as facts.** Re-verify each one. The panel is independent, not
  infallible, and a refuted finding is worth recording too.
