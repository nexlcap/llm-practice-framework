# Call-site contract

One file (or one doc-comment block) per model call site. Fill every field before writing the prompt.
A blank field is a design gap; a blank *consumer* means the call should not exist. A field that
cannot be known until the call has run (measured latency, cadence, quota share) is written as
`TBD(reason, by YYYY-MM-DD)` so the inventory test lets it through until the date. Fields tagged
with shapes in brackets, for example `[agentic]`, belong to those shapes: a call of another shape
deletes them and lists the deleted sections on its Shape line; the inventory test accepts a deleted
tagged section. A single untagged field that does not apply is `n/a(reason)`, where the reason names
the fact that makes the field moot, not a restatement of the field; a bare `n/a` is a blank. For an
agentic call, sections 5 and 6 describe the tool argument schemas and the tool server's checks,
section 4 carries the bounds, and section 11 the ceiling, the principal, and the approval step.

Copy from the line below.

---

## Call site: `<package.module.function>`

**Id:** `<short-id>` (registered in the call-site inventory)
**Owner:** `<person or team>`
**Created:** `<YYYY-MM-DD>`  **Contract last reviewed:** `<YYYY-MM-DD>`
**Shape:** `<scheduled artifact | request-response | conversation | agentic session>`; tagged sections deleted because the shape does not use them: `<list, or none>`
**Build stage:** `<what exists in code today; what is design only>`

### 1. Purpose and consumer

- What the output is: `<one sentence>`
- Who reads it: `<person, page, job, or system>`; the reader is `<the operator | a third party>`
- Whose data the evidence is: `<the reader's | the operator's | another party's, in which case section 11 says how it is scoped>`
- What decision changes because of it: `<one sentence>`
- What happens if the call never runs: `<one sentence>`

### 2. Trigger

- Event that runs it: `<event, request, user turn, or scheduled window>`
- Delta condition (runs only if) `[scheduled artifact]`: `<what must have changed since the last run>`
- Deduplication key: `<what makes two runs the same run>`; idempotency key carried by any
  side-effecting call: `<minted by the door per logical operation; identical across retries; never an attempt counter or a timestamp>`
- Expected cadence: `<n per day, or n per user per hour>`; maximum, enforced in the door: `<n>`

### 3. Inputs

**Injected facts** (the output may contain no other facts):

| Fact | Source of truth | Computed by | As of / max age | Snapshot |
|---|---|---|---|---|
| `<e.g. current price>` | `<table, API, file>` | `<function>` | `<timestamp shown; oldest acceptable>` | `<same snapshot as validators: yes>` |

**Data sources read by code for this call** (a change to any of them re-opens the spec gate):

| Source | Filter applied | Owner |
|---|---|---|
| `<table, index, API>` | `<the consumer's entitlement, applied by <function>>` | `<team>` |

**Closed vocabularies** (the output may reference no other identifiers):

| Vocabulary | Shown to the model as | Validated against | Scoped to |
|---|---|---|---|
| `<e.g. user ids, page slugs, action names>` | `<list in prompt section X>` | `<the same list, by exact match>` | `<the consumer's entitlement, or a global list with no owner>` |

**Stated policy** (in the prompt): `<what this call is for, what it is not, whose interests it serves>`

**External text** read by this call, directly or through a sub-agent: `<none | which fields; fenced with a per-call nonce by <function>; tool definitions pinned by <hash or version>>`; the log records `read_external`.

**Ceiling if the fence fails**: `<if every external field were hostile, the worst the model can cause is ...; bounded by <tool allowlist | closed vocabulary | tool-server rule>>`

**Context** `[conversation, agentic]`: ceiling `<tokens>`; dropped or compacted first: `<what>`; a compaction summary or sub-agent report that re-enters the context is treated as model output by `<how>`

**Ambiguous terms defined**: `<e.g. "change" = 3-month close-to-close, percent>`

### 4. Model, effort, budget

- Model: `<an id the vendor documents as a fixed snapshot, never one documented as moving>` (in the
  allowlist: yes); vendor retirement: `<date | "not sooner than <date>" | none published, lifecycle
  page checked on <date>>`; replacement candidate: `<id>`; migration test: `<fixtures and golden set
  re-run, effort re-swept, deprecated parameters removed>`
- Effort / reasoning level: `<level>`, set explicitly; re-swept at every model change
- Output token cap: `<n>`; thinking counts toward it: `<yes | no>`
- Tier: `<interactive | batch, deadline tolerates the vendor's batch window>`
- Measured latency: p50 `<s>`, p95 `<s>`, measured on `<date>`, n = `<n>`
- Timeout: `<s>` (= p95 × `<margin>`), `<per attempt | total>`
- Priority in the scheduler: `<high | normal | low>`
- Cache: static prefix = `<sections>`; mechanism `<marker at the end of the prefix | automatic prefix cache | explicit cache resource, TTL <h>>`; cached-read tokens logged: yes
- Budget unit and expected use: `<e.g. 12 calls/day, ~5% of the daily quota>`; hard cap per day,
  enforced in the door: `<n calls, <amount>>`
- For a loop `[agentic]`: caps on turns `<n>`, tool calls `<n>`, tokens `<n>`, wall clock `<s>`;
  per-tool-call timeout `<s>`, enforced by the tool server
- Resources the model can move through tools `[agentic]`: `<none | money, messages, records>`;
  per-action bound `<...>`; per-principal bound per `<period>` `<...>`; aggregate bound per day
  `<...>`; alerted at a bound: `<who>`; reversal path: `<...>`

### 5. Output

**Schema** (requested at generation time):

```json
{ "<field>": "<type>", "evidence_used": ["<ids from the shown evidence>"] }
```

**Enforced at generation** (strict mode or constrained decoding): `<yes | no>`; residual cases the
validator still handles: `<refusal, truncation, constraints the decoder does not enforce>`

**Required citations**: `<which fields must cite shown evidence>`

**Worked examples in the prompt**: `<n>`, spanning classes: `<list>`

**Streaming** `[request-response, conversation]`: `<no | yes, buffered and validated before render | yes, residual stated here>`

### 6. Validators, in order

| # | Layer | Check | Status | On failure |
|---|---|---|---|---|
| 1 | Schema | `<validator>` | built / planned(by date) | outcome `parse_failure` or `truncated`; failure policy applies |
| 2 | Vocabulary | every id ∈ shown set and ∈ the consumer's entitlement, checked by the server | | drop the item, log `vocab_reject` (a log event, not an outcome class) |
| 3 | Numeric copy | every number == an injected or shown value whose evidence is within the entitlement | | drop the item, log `numeric_reject` (a log event) |
| 4 | Audit | `<specific failure mode checked>`; say what it does *not* catch | | bias by cost asymmetry, stated: `<precision-biased because the reader is the operator, or recall-biased because a miss reaches a third party, money, or personal data>` |
| 5 | Suppression | `<what code refuses to surface regardless>` | | suppressed, counted |
| 6 | Structural | `<what the model cannot do at all: no tool, no field, no record outside the consumer's entitlement>` | | n/a(nothing to fail: the path does not exist) |

The status column exists because reviewers read a validators table as shipped defence. A planned
row is a commitment with a date, not a guarantee, and the inventory test expires it like a TBD.

**Iteration loop** `[conversation, agentic]`: `<every turn sees the transcript. Which prior model
statements may it rely on (default: none; facts and entitlements are re-derived from tools each
turn)? Which user claims about prior turns are checked by code against the transcript? Drift and
ratchet test: <test name>>`

### 7. Failure policy

- Transport error / timeout: `<skip loudly | deterministic default <what> | keep last good (TTL <h>) | abort>`
- A deterministic default is labelled as a default where it is read and counted as `default_served`;
  the consumer can always tell it from a model answer: `<how>`
- Rate limit or 5xx: retry `<none | n attempts, backoff with jitter, Retry-After honoured, inside
  the total timeout, each attempt logged>`, then the policy above
- Parse failure or truncation: `<same or different>`
- Empty or fully-rejected output: `<what the consumer sees>`
- Cap hit (`cap_hit`): `<what happens>`
- Last-good artifact `[scheduled artifact]`: location and TTL `<path or table>, <h>`; at expiry the
  consumer sees `<...>`; a system consumer treats it as absent: yes; cleared by `<code path>`
- Committed tool actions when a session aborts `[agentic]`: `<stay | compensated by <action> | require a person>`, per tool

### 8. Observability

- Log record fields beyond the standard set: `<extra fields>`
- Session or trace id: `<field>`; one event row per tool call `[agentic]`: `<table>`
- Staleness surface ("as of", "produced by a model | default served | last good shown", and the
  oldest evidence date, shown at): `<page, field, or endpoint>`
- Liveness derived from: `<this call's successful runs, window <h> | a scheduled canary call through
  the door against a synthetic principal, window <h>>`
- Content sample: `<n outputs per <period>, drawn at random by <code path> across the period and
  stratified by <queue or hour>, including the outputs held or discarded; read by <role>, who is not
  the approver, through <the source system's own surface, under its access control>; each read
  logged, a period without a read alerts; looking for <named outcomes>; findings go to <incident pin
  | validator | harm-floor count>; sample copies are not kept beyond the finding>` or
  `n/a(the reader is the operator)`
- Alert thresholds: parse failures `<n / window>`, API errors `<n / window>`, silence `<h>`, cap hits
  `<n / window>`, served model id outside the allowlist: any, canary output differs from its fixture
  beyond `<tolerance>`: any

### 9. Tests

- Fixture files: `<path>` (recorded on `<date>`; includes failures: yes; includes injection
  attempts: yes; redacted by `<function>`: yes)
- Incident-pinned regressions: `<test name → incident date and one line>`
- Guard tests touching this site: `<inventory, one-door, secrets-in-logs-and-fixtures, pinned-model>`
- Entitlement test: `<a fixture record owned by another principal is never shown or emitted>`
- Live smoke: `<opt-in flag>`, off by default

### 10. Evaluation

- File: `evaluations/<id>.md` (metric, control, dev and golden sets, kill criterion, harm floor, control retention)
- Read date: `<YYYY-MM-DD>` (repeated here so the inventory test can expire it)

### 11. Security and data

- Secrets in prompt, logs, or fixtures: `<none, verified by guard test <name> on <date> | list, remediation by <date>>`
- Injection surface: `<fields carrying external text, tool results, tool definitions, and their fence>`; ceiling if the fence fails: see section 3
- Acting principal: `<the consumer in section 1 | a service identity acting for <consumer>, with
  reads and evidence narrowed to that consumer's entitlement by <function>, tested by <test>>`; bound
  by `<code path>` at session start from the authenticated request (a session-scoped credential or
  principal id the tool server receives from the door), never a tool argument the model fills; a
  service identity's own scope is never the answer
- Tools available to the model `[agentic]`: `<none | allowlist>`; tool servers mounted: `<name and
  the hash of its pinned tool list for servers we control; version with review per bump for
  third-party servers>`
- Reads the model can cause `[agentic]`: `<none | tools, and the entitlement each is limited to>`
- Writes the model can cause `[agentic]`: `<none | via tool server, validated by <function>>`
- Irreversible actions reachable through tools `[agentic]`: `<none | list>`; approval: `<human
  approval at <surface> by <role>, the surface showing the deterministic tool arguments | reversible
  by <mechanism, window>, released by <role>>`; approvals per hour and reversals after approval are
  counted in the evaluation
- Sandbox `[agentic]`: `<filesystem scope; network-egress allowlist; the model process holds no credential>`
- Server-side vendor tools (web search, code execution): `<off | listed; their results are external text the fence cannot reach>`
- Rule-of-two check: processes untrusted input `<y/n>`; reaches private data or sensitive systems
  `<y/n>`; changes state or communicates externally `<y/n>`. Three yeses require a human approval at
  a named surface by a named role (a reversibility window is not an approval), or a split into a
  reader with no tools and an actor that never sees untrusted text, where the reader's output reaches
  the actor only as schema-validated values from a closed vocabulary, never as free text: `<which>`
- Data sent to the vendor: classes in the prompt `<none | personal | regulated | confidential>`;
  vendor terms relied on: `<retention <d>, training opt-out, zero-data-retention, region, agreement>`
  (or "per LOCAL.md vendor terms")
- Data kept: transcripts, fixtures, last-good artifacts at `<location>`; retention `<d>`; access
  `<role>`; redaction `<function | none, because ...>`; the content sample as a processing activity:
  `<reader role, n per period, what it is redacted to, retention>`
- Project-level controls (sandbox, guard tests, vendor terms) that are the same for every call site:
  `<per LOCAL.md door audit of <date>>`

### 12. Review

| Gate | Date | Reviewers (roles) | Verdict | Link |
|---|---|---|---|---|
| Design | | | | |
| Spec | | | | |
| Results | | | | |

---

## Worked example (abridged: Owner, Created, Streaming, Priority, and the Review table are omitted)

**Call site:** `triage.classify_ticket`  **Id:** `ticket-triage`  **Shape:** request-response;
deleted tagged sections: delta condition, Context, loop caps, resources, Iteration loop, last-good
artifact, committed tool actions, event rows, tools, reads, writes, irreversible actions, sandbox.
**Build stage:** all six validators and the fixtures built; alerting planned(by 2026-11-15).

- **Purpose:** assign one of the known queues to an inbound support ticket. **Consumer:** the routing
  job (the operator's system); the evidence is the customer's ticket, read by the operator's own
  support staff in any case. **Decision changed:** which queue receives the ticket. **If it never
  runs:** tickets land in the manual queue, which is the safe default.
- **Trigger:** ticket created; dedupe: ticket id. Cadence ~200/day, hard cap 2,000/day in the door.
- **Injected facts:** ticket subject, body (external text, fenced with a nonce; `read_external` yes),
  customer tier (from the CRM, as of the ticket's creation). **Data sources read by code:** the
  tickets table filtered to the one ticket, the CRM tier field. **Closed vocabulary:** queue names,
  the full list of 14, validated by exact match, a global list owned by support operations. **Stated
  policy:** "Prefer the manual queue when unsure; never invent a queue." **Ceiling if the fence
  fails:** a wrong queue, corrected by the queue owner; no tools, no writes. **Defined terms:**
  "urgent" means tier A or a stated outage.
- **Model:** small tier, pinned snapshot `small-2026-06-01` (documented as fixed), retirement not
  sooner than 2027-06-01, replacement `small-2026-10-01` tested on the golden set; effort low, set
  explicitly; output cap 200 tokens; p95 measured 4.1 s on 2026-08-30 (n = 300); timeout 12 s total,
  2 retries with backoff on rate limits inside it; static prefix (role, policy, schema, examples)
  cached with the vendor's prefix cache, ticket text last.
- **Output:** a JSON object with `queue` (one of the 14), `confidence` (`high` or `low`), and
  `evidence_used` (`subject`, `body`), enforced at generation; the validator keeps refusal and
  truncation.
- **Validators:** schema; queue ∈ list else manual; numeric copy n/a(no numbers); audit n/a(the
  consumer is a routing job with a safe default; no trust surface); confidence low → manual
  (suppression); the deterministic keyword map runs first and the model only sees tickets it did not
  match (structural).
- **Failure policy:** any failure, including `cap_hit` → manual queue, logged as `default_served`
  and shown on the ticket as "routed by default", no further retry.
- **Observability:** `queue`, `confidence`, `map_hit`, served model id logged; liveness from
  successful runs over 2 h in business hours, an hourly canary ticket for a synthetic customer
  otherwise; alert on 5 parse failures per hour; "routed by the assistant at <time>" on the ticket;
  content sample n/a(the reader is the operator; the queue owner sees every misroute).
- **Tests:** 40 recorded tickets, names and emails redacted, including 6 malformed outputs and 3
  injection attempts; regression "2026-08-12 invented queue 'Billing-EU'"; inventory test lists
  `ticket-triage`; entitlement test n/a(no per-customer reads: one ticket in, one queue out).
- **Evaluation:** `evaluations/ticket-triage.md`: metric = agreement with a blind label; dev set 200
  tickets for prompt iteration; golden set 300 tickets labelled before launch and refreshed with 50
  blind labels a month by a reviewer who does not see the model's queue; control = keyword map
  alone; read date 2026-11-30; kill if agreement is not at least 10 points above the map; harm floor
  n/a(a misroute is recoverable).
- **Security and data:** no secrets (guard test `test_no_secrets_in_logs_or_fixtures`, 2026-09-01);
  no tools; no writes; acting principal: the operator's routing service, reading one ticket at a
  time, no cross-customer evidence; personal data in prompts (names in ticket text) under the vendor
  zero-data-retention agreement recorded in LOCAL.md; fixtures redacted; no transcripts kept.

## Worked example: an agentic call (abridged: Owner, Created, Priority, and the Review table are omitted)

**Call site:** `assistant.run_session`  **Id:** `support_session`  **Shape:** agentic session;
deleted tagged sections: delta condition, Streaming, last-good artifact.
**Build stage:** tool server, caps, principal binding, and the draft-not-send design built; the
recall-biased audit and the content sample planned(by 2026-11-15).

- **Purpose:** one support-assistant session that reads a customer's tickets and may draft a reply,
  tag, or escalate through tools. **Consumer:** the support agent who reads and sends the draft (the
  operator), and the customer who reads the sent reply (a third party); the evidence is the
  customer's own data. **If it never runs:** tickets wait for a person; nothing breaks.
- **Trigger:** a ticket enters the queue and no session is open for it; dedupe by ticket id; every
  write carries an idempotency key minted by the door per logical operation, `session id + turn +
  tool + canonical arguments`, identical across retries, and the tool server rejects a repeat.
- **Injected facts:** customer tier and open tickets (from the CRM, at session start, as of that
  moment); ticket text and history through read tools, live at read time (the server retrieves, the
  model judges). **Data sources read by code:** the tickets and CRM tables, filtered to this ticket's
  customer by the tool server; the knowledge base, public articles only. **Closed vocabularies:**
  ticket ids, tag names, and escalation queues exist only as tool arguments; the tool server
  validates each against the records this ticket's customer is entitled to, never against the whole
  database. Existence is not entitlement. **Stated policy:** "Draft only from the ticket and the
  knowledge base shown; escalate when unsure; a refund or credit is an escalation, never a promise."
  **External text:** every ticket is customer-written and reaches the model through tool results;
  the server fences each ticket with the session nonce; `read_external` yes. **Ceiling if the fence
  fails:** a wrong tag on this customer's ticket, or a wrong draft that a person reads before anything
  leaves; no tool sends or moves money; no record of another customer is reachable. **Context:** 60k
  tokens; the oldest tool results are compacted first; a compaction summary is labelled model output
  and no fact in it is acted on without a tool re-read.
- **Model:** mid tier, pinned snapshot `mid-2026-07-15` (documented as fixed), retirement not sooner
  than 2027-07-15; effort medium, set explicitly; timeout 600 s wall clock, TBD(measure p95 over the
  first 200 sessions, by 2026-11-15); per-tool-call timeout 20 s; caps 12 tool calls, 2 drafts, 600 s,
  60k tokens; escalations per customer per 30 days capped at 2 by the tool server; resources the
  model can move directly: none.
- **Output:** no completion-level schema. The output is a sequence of tool calls; each tool's
  argument schema is the schema layer, and the transcript is stored on the session row, redacted,
  with a 90-day retention.
- **Validators:** (1) tool argument schemas; (2) ids and tags ∈ this customer's records, checked by
  the server; (3) numeric copy: any amount in a draft must equal an amount shown in a tool result for
  this customer; (4) audit, recall-biased: any draft that mentions money, eligibility, or a
  commitment, or contains a URL, email address, or phone number not in the knowledge base, is held
  for a person with the reason shown; (5) suppression: the caps; (6) structural: no tool sends to
  the customer or moves money (a refund or credit is an `escalate` call with a reason code from a
  closed set of six, acted on by a person); only the support tool server is mounted; built-in tools
  are disabled; every read is scoped to this ticket's customer. **Iteration loop:** every turn sees
  the transcript; no prior model statement is relied on (entitlements and ticket facts are re-read
  through tools each turn); a customer's claim about an earlier turn is checked by a server-side
  tool against the transcript; drift test `test_session_ratchet_2026_09_20`.
- **Failure policy:** transport error, timeout, or `cap_hit`: committed tags stay (they are
  reversible by the agent), drafts are discarded, the session is marked aborted with the partial
  transcript, the ticket returns to the human queue; rate limits: 3 retries with backoff inside the
  600 s; no retry of the session.
- **Observability:** one call record per session with outcome class and session id; one event row
  per tool call; the ticket view shows "draft by the assistant at <time>; sent by <agent> at <time>".
  Liveness: completed sessions per hour in business hours, one canary session per hour otherwise
  against a synthetic customer with its own records, excluded from the sample and the caps. Content
  sample: 100 outputs a week, drawn at random by the sampler across the week and stratified by queue,
  of which 30 are drafts the audit held or the agent discarded; read by the support lead (not the
  sending agent) in the ticket system under its own access control, each read logged; a week without
  a read alerts; looking for disclosure of another account's data, wrong commitments, and tone;
  findings become incident pins or validators.
- **Tests:** recorded transcripts, redacted, including an aborted one and three with injected
  instructions in the ticket text; tool server tests for every refusal, including a read of a record
  owned by another customer and of a record with no owner; a guard test that no code outside the
  door spawns the model.
- **Evaluation:** `evaluations/support_session.md`: metric = share of sampled sent replies a
  reviewer rates correct and within policy (the share not edited by a person measures the reviewer's
  effort, not the reply); dev set 60 recorded sessions; golden set 150 recorded sessions with their
  tool results, replayed against the recorded results (no live tools), labelled by two support leads
  who do not see the model's drafts, scored once per candidate, refreshed quarterly; control = the
  human-only queue; read date 2026-12-15; kill if below 80 %; harm floor = any disclosure of another
  account's data or any unauthorised action in the weekly sample pauses the feature (100 a week sees
  a 3 % rate with 95 % probability; a lower rate is caught by the entitlement test, not the sample);
  control retention = a person sends every reply, and removing that is a decision-logic change that
  convenes the veto seats (privacy, customer relationship).
- **Security and data:** no secrets in prompts (guard test, 2026-09-01); the tool server holds the
  database credential, the model process does not and has no network egress except the tool server;
  acting principal = this ticket's customer, bound by the door from the ticket's authenticated owner
  at session start and passed to the tool server as a session-scoped principal id, never a tool
  argument; irreversible actions reachable: none (send is a human action at the ticket view, which
  shows the draft and the recipient); rule of two: untrusted input yes; private data yes; changes
  state yes (tags, escalations) and communicates externally no (a person sends): three yeses,
  covered by draft-not-send for communication and by reversible tags and a person-acted escalation
  for state; data sent to the vendor: personal (names, ticket text) under the zero-data-retention
  agreement in LOCAL.md; data kept: redacted transcripts 90 days, support role only; the content
  sample is read in place and nothing is exported; the process group is killed on timeout so the
  tool server never outlives the session.
