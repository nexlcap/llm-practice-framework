# Call-site contract

One file (or one doc-comment block) per model call site. Fill every field before writing the prompt.
A blank field is a design gap; a blank *consumer* means the call should not exist. A field that
cannot be known until the call has run (measured latency, cadence, quota share) is written as
`TBD(reason, by YYYY-MM-DD)` so the inventory test lets it through until the date. A field that does
not apply to the call's shape is written `n/a(reason)` and the reason is reviewed at the spec gate;
a bare `n/a` is a blank. For an agentic call, sections 5 and 6 describe the tool argument schemas and
the tool server's checks, and section 11 carries the bounds.

Copy from the line below.

---

## Call site: `<package.module.function>`

**Id:** `<short-id>` (registered in the call-site inventory)
**Owner:** `<person or team>`
**Created:** `<YYYY-MM-DD>`  **Contract last reviewed:** `<YYYY-MM-DD>`
**Shape:** `<scheduled artifact | request-response | conversation | agentic session>`; sections that do not apply, one reason each: `<list, or none>`
**Build stage:** `<what exists in code today; what is design only>`

### 1. Purpose and consumer

- What the output is: `<one sentence>`
- Who reads it: `<person, page, job, or system>`; the reader is `<the operator | a third party>`
- What decision changes because of it: `<one sentence>`
- What happens if the call never runs: `<one sentence>`

### 2. Trigger

- Event that runs it: `<event, request, user turn, or scheduled window>`
- Delta condition (runs only if): `<what must have changed since the last run>`
- Deduplication key: `<what makes two runs the same run>`; idempotency key carried by any
  side-effecting call: `<derivation>`
- Expected cadence: `<n per day, or n per user per hour>`; maximum, enforced in the door: `<n>`

### 3. Inputs

**Injected facts** (the output may contain no other facts):

| Fact | Source of truth | Computed by | Snapshot |
|---|---|---|---|
| `<e.g. current price>` | `<table, API, file>` | `<function>` | `<same snapshot as validators: yes>` |

**Closed vocabularies** (the output may reference no other identifiers):

| Vocabulary | Shown to the model as | Validated against | Scoped to |
|---|---|---|---|
| `<e.g. user ids, page slugs, action names>` | `<list in prompt section X>` | `<the same list, by exact match>` | `<the acting principal's records, or a global list>` |

**Stated policy** (in the prompt): `<what this call is for, what it is not, whose interests it serves>`

**External text**: `<none | which fields; fenced with a per-call nonce by <function>; tool definitions pinned by <version or hash>>`

**Ceiling if the fence fails**: `<if every external field were hostile, the worst the model can cause is ...; bounded by <tool allowlist | closed vocabulary | tool-server rule>>`

**Context**: ceiling `<tokens>`; dropped or compacted first: `<what>`; a compaction summary or sub-agent report that re-enters the context is treated as model output by `<how>`

**Ambiguous terms defined**: `<e.g. "change" = 3-month close-to-close, percent>`

### 4. Model, effort, budget

- Model: `<pinned snapshot id, never a moving alias>` (in the allowlist: yes); vendor retirement:
  `<date, or "not sooner than <date>">`; replacement candidate: `<id>`; migration test: `<fixtures
  and golden set re-run, effort re-swept, deprecated parameters removed>`
- Effort / reasoning level: `<level>`, set explicitly; re-swept on the golden set at every model change
- Output token cap: `<n>`; thinking counts toward it: `<yes | no>`
- Tier: `<interactive | batch>`
- Measured latency: p50 `<s>`, p95 `<s>`, measured on `<date>`, n = `<n>`
- Timeout: `<s>` (= p95 × `<margin>`), `<per attempt | total>`
- Priority in the scheduler: `<high | normal | low>`
- Cache: static prefix = `<sections>`; breakpoint after `<section>`; cached-read tokens logged: yes
- Budget unit and expected use: `<e.g. 12 calls/day, ~5% of the daily quota>`; hard cap per day,
  enforced in the door: `<n calls, <amount>>`
- For a loop: caps on turns `<n>`, tool calls `<n>`, tokens `<n>`, wall clock `<s>`
- Resources the model can move through tools: `<none | money, messages, records>`; per-action bound
  `<...>`; per-principal bound per `<period>` `<...>`; aggregate bound per day `<...>`; alerted at a
  bound: `<who>`; reversal path: `<...>`

### 5. Output

**Schema** (requested at generation time):

```json
{ "<field>": "<type>", "evidence_used": ["<ids from the shown evidence>"] }
```

**Enforced at generation** (strict mode or constrained decoding): `<yes | no>`; residual cases the
validator still handles: `<refusal, truncation, constraints the decoder does not enforce>`

**Required citations**: `<which fields must cite shown evidence>`

**Worked examples in the prompt**: `<n>`, spanning classes: `<list>`

**Streaming**: `<no | yes, buffered and validated before render | yes, residual stated here>`

### 6. Validators, in order

| # | Layer | Check | Status | On failure |
|---|---|---|---|---|
| 1 | Schema | `<validator>` | built / planned(by date) | outcome `parse_failure` or `truncated`; failure policy applies |
| 2 | Vocabulary | every id ∈ shown set and ∈ the acting principal's scope, checked by the server | | drop the item, log `vocab_reject` |
| 3 | Numeric copy | every number == an injected or shown value | | drop the item, log `numeric_reject` |
| 4 | Audit | `<specific failure mode checked>`; say what it does *not* catch | | bias by cost asymmetry, stated: `<precision-biased because the reader is the operator, or recall-biased because a miss reaches a third party, money, or personal data>` |
| 5 | Suppression | `<what code refuses to surface regardless>` | | suppressed, counted |
| 6 | Structural | `<what the model cannot do at all: no tool, no field, no record outside the principal's scope>` | | n/a(nothing to fail: the path does not exist) |

The status column exists because reviewers read a validators table as shipped defence. A planned
row is a commitment with a date, not a guarantee.

**Iteration loop**: `<does the model ever see its own prior output? In a conversation every turn
does. Which prior model statements may it rely on (default: none; facts and entitlements are
re-derived from tools each turn)? Which user claims about prior turns are checked against the
transcript? Drift and ratchet test: <test name>>`

### 7. Failure policy

- Transport error / timeout: `<skip loudly | deterministic default <what> | keep last good (TTL <h>) | abort>`
- Rate limit or 5xx: retry `<none | n attempts, backoff with jitter, Retry-After honoured, inside
  the total timeout, each attempt logged>`, then the policy above
- Parse failure or truncation: `<same or different>`
- Empty or fully-rejected output: `<what the consumer sees>`
- Cap hit (`cap_hit`): `<what happens>`
- Last-good artifact location and TTL: `<path or table>, <h>`; at expiry the consumer sees
  `<...>`; a system consumer treats it as absent: yes; cleared by `<code path>`
- Committed tool actions when a session aborts: `<stay | compensated by <action> | require a person>`,
  per tool

### 8. Observability

- Log record fields beyond the standard set: `<extra fields>`
- Session or trace id: `<field>`; one event row per tool call: `<table>`
- Staleness surface ("as of" and "produced by a model" shown at): `<page, field, or endpoint>`
- Liveness derived from: `<this call's successful runs, window <h> | a scheduled canary call through the door, window <h>>`
- Content sample: `<n outputs per day read by <role>, looking for <named outcomes>; findings go to
  <incident pin | validator | harm-floor count>>` or `n/a(the reader is the operator)`
- Alert thresholds: parse failures `<n / window>`, API errors `<n / window>`, silence `<h>`, cap hits
  `<n / window>`, served model id outside the allowlist: any

### 9. Tests

- Fixture files: `<path>` (recorded on `<date>`; includes failures: yes; includes injection
  attempts: yes; redacted by `<function>`: yes)
- Incident-pinned regressions: `<test name → incident date and one line>`
- Guard tests touching this site: `<inventory, one-door, secrets-in-logs-and-fixtures, pinned-model>`
- Live smoke: `<opt-in flag>`, off by default

### 10. Evaluation

- File: `evaluations/<id>.md` (metric, control, golden set, kill criterion, harm floor, control retention)
- Read date: `<YYYY-MM-DD>` (repeated here so the inventory test can expire it)

### 11. Security and data

- Secrets in prompt, logs, or fixtures: `<none, verified by guard test <name> on <date> | list, remediation by <date>>`
- Injection surface: `<fields carrying external text, tool results, tool definitions, and their fence>`; ceiling if the fence fails: see section 3
- Acting principal: `<the requesting user | a service identity>`; every read and write is scoped to
  it by the tool server, never by the model's reading of who the requester claims to be
- Tools available to the model: `<none | allowlist>`; tool servers mounted: `<name@version or hash | none>`
- Reads the model can cause: `<none | tools, and the scope each is limited to>`
- Writes the model can cause: `<none | via tool server, validated by <function>>`
- Irreversible actions reachable through tools: `<none | list>`; gate: `<human approval at <surface> | reversible by <mechanism, window>>`
- Sandbox: `<filesystem scope; network-egress allowlist; the model process holds no credential>`
- Server-side vendor tools (web search, code execution): `<off | listed; their results are external text the fence cannot reach>`
- Rule-of-two check: processes untrusted input `<y/n>`; reaches private data or sensitive systems
  `<y/n>`; changes state or communicates externally `<y/n>`. Three yeses require the approval step
  above, or a split into a reader with no tools and an actor that never sees untrusted text: `<which>`
- Data sent to the vendor: classes in the prompt `<none | personal | regulated | confidential>`;
  vendor terms relied on: `<retention <d>, training opt-out, zero-data-retention, region, agreement>`
- Data kept: transcripts, fixtures, last-good artifacts at `<location>`; retention `<d>`; access
  `<role>`; redaction `<function | none, because ...>`

### 12. Review

| Gate | Date | Reviewers (roles) | Verdict | Link |
|---|---|---|---|---|
| Design | | | | |
| Spec | | | | |
| Results | | | | |

---

## Worked example (abridged)

**Call site:** `triage.classify_ticket`  **Id:** `ticket-triage`  **Shape:** request-response;
delta condition and keep-last-good `n/a(one classification per ticket)`.
**Build stage:** all six validators and the fixtures built; alerting planned(by 2026-11-15).

- **Purpose:** assign one of the known queues to an inbound support ticket. **Consumer:** the routing
  job (the operator's system). **Decision changed:** which queue receives the ticket. **If it never
  runs:** tickets land in the manual queue, which is the safe default.
- **Trigger:** ticket created; dedupe: ticket id. Cadence ~200/day, hard cap 2,000/day in the door.
- **Injected facts:** ticket subject, body (external text, fenced with a nonce), customer tier (from
  the CRM). **Closed vocabulary:** queue names, the full list of 14, validated by exact match, global.
  **Stated policy:** "Prefer the manual queue when unsure; never invent a queue." **Ceiling if the
  fence fails:** a wrong queue, corrected by the queue owner; no tools, no writes. **Defined terms:**
  "urgent" means tier A or a stated outage.
- **Model:** small tier, pinned snapshot `small-2026-06-01`, retirement not sooner than 2027-06-01,
  replacement `small-2026-10-01` tested on the golden set; effort low, set explicitly; output cap 200
  tokens; p95 measured 4.1 s on 2026-08-30 (n = 300); timeout 12 s total, 2 retries with backoff on
  rate limits inside it; static prefix (role, policy, schema, examples) cached, ticket text last.
- **Output:** `{ "queue": "<name>", "confidence": "high|low", "evidence_used": ["subject", "body"] }`,
  enforced at generation; validator keeps refusal and truncation.
- **Validators:** schema; queue ∈ list else manual; numeric copy n/a(no numbers); audit n/a(the
  consumer is a routing job with a safe default; no trust surface); confidence low → manual
  (suppression); the deterministic keyword map runs first and the model only sees tickets it did not
  match (structural).
- **Failure policy:** any failure, including `cap_hit` → manual queue, logged, no further retry.
- **Observability:** `queue`, `confidence`, `map_hit`, served model id logged; liveness from
  successful runs over 2 h in business hours, canary ticket hourly otherwise; alert on 5 parse
  failures per hour; "routed by the assistant at <time>" on the ticket; content sample
  n/a(reader is the operator; the queue owner sees every misroute).
- **Tests:** 40 recorded tickets, names and emails redacted, including 6 malformed outputs and 3
  injection attempts; regression "2026-08-12 invented queue 'Billing-EU'"; inventory test lists
  `ticket-triage`.
- **Evaluation:** `evaluations/ticket-triage.md`: metric = agreement with the manual queue's final
  assignment; control = keyword map alone; golden set 300 labelled tickets; read date 2026-11-30;
  kill if agreement is not at least 10 points above the map; harm floor n/a(a misroute is recoverable).
- **Security and data:** no secrets (guard test `test_no_secrets_in_logs_or_fixtures`, 2026-09-01);
  no tools; no writes; principal n/a(no reads); personal data in prompts (names in ticket text),
  vendor zero-data-retention agreement; fixtures redacted; no transcripts kept.

## Worked example: an agentic call (abridged)

**Call site:** `assistant.run_session`  **Id:** `support_session`  **Shape:** agentic session;
delta condition `n/a(one session per ticket)`; keep-last-good `n/a(nothing persists between
sessions)`.
**Build stage:** tool server, caps, and the draft-not-send design built; the recall-biased audit and
the daily content sample planned(by 2026-11-15).

- **Purpose:** one support-assistant session that reads a customer's tickets and may draft a reply,
  tag, or escalate through tools. **Consumer:** the support agent who reads and sends the draft (the
  operator), and the customer who reads the sent reply (a third party). **If it never runs:** tickets
  wait for a person; nothing breaks.
- **Trigger:** a ticket enters the queue and no session is open for it; dedupe by ticket id; every
  write carries the idempotency key `ticket id + tool + attempt`.
- **Injected facts:** customer tier and open tickets (from the CRM, at session start); ticket text
  and history through read tools, live at read time (the server retrieves, the model judges).
  **Closed vocabularies:** ticket ids, tag names, and escalation queues exist only as tool arguments;
  the tool server validates each against the records the acting principal (this ticket's customer)
  is entitled to, never against the whole database. Existence is not a vocabulary check. **Stated
  policy:** "Draft only from the ticket and the knowledge base shown; escalate when unsure; a refund
  or credit is an escalation, never a promise." **External text:** every ticket is customer-written
  and reaches the model through tool results; the server fences each ticket with the session nonce.
  **Ceiling if the fence fails:** a wrong tag on this customer's ticket, or a wrong draft that a
  person reads before anything leaves; no tool moves money or sends.
- **Model:** mid tier, pinned snapshot `mid-2026-07-15`, retirement recorded; effort medium, set
  explicitly; timeout 600 s wall clock, TBD(measure p95 over the first 200 sessions, by 2026-11-15);
  caps 12 tool calls, 2 drafts, 600 s, 60k tokens; escalations per customer per 30 days capped at 2 by
  the tool server; resources the model can move directly: none.
- **Output:** no completion-level schema. The output is a sequence of tool calls; each tool's
  argument schema is the schema layer, and the transcript is stored on the session row, redacted,
  with a 90-day retention.
- **Validators:** (1) tool argument schemas; (2) ids and tags ∈ this customer's records, checked by
  the server; (3) numeric copy: any amount in a draft must equal an amount shown in a tool result;
  (4) audit, recall-biased: any draft that mentions money, eligibility, or a commitment, or contains
  a URL, email address, or phone number not in the knowledge base, is held for a person with the
  reason shown; (5) suppression: the caps; (6) structural: no tool sends to the customer or moves
  money (a refund or credit is an `escalate` call with a reason code from a closed set of six, acted
  on by a person); only the support tool server is mounted; built-in tools are disabled; every read
  is scoped to this ticket's customer.
- **Failure policy:** transport error, timeout, or `cap_hit`: committed tags stay (they are
  reversible by the agent), drafts are discarded, the session is marked aborted with the partial
  transcript, the ticket returns to the human queue; rate limits: 3 retries with backoff inside the
  600 s; no retry of the session.
- **Observability:** one call record per session with outcome class and session id; one event row
  per tool call; the ticket view shows "draft by the assistant at <time>; sent by <agent> at <time>".
  Liveness: completed sessions per hour in business hours, one canary session per hour otherwise.
  Content sample: 20 sent replies per day read by the support lead for disclosure of another
  account's data, wrong commitments, and tone; findings become incident pins or validators.
- **Tests:** recorded transcripts, redacted, including an aborted one and three with injected
  instructions in the ticket text; tool server tests for every refusal, including a read outside the
  principal's scope; a guard test that no code outside the door spawns the model.
- **Evaluation:** `evaluations/support_session.md`: metric = share of sampled sent replies a
  reviewer rates correct and within policy (the share not edited by a person measures the reviewer's
  effort, not the reply); control = the human-only queue; read date 2026-12-15; kill if below 80 %;
  harm floor = any disclosure of another account's data or any unauthorised action in the daily
  sample pauses the feature; control retention = a person sends every reply, and removing that is a
  decision-logic change that convenes the veto seats (privacy, customer relationship).
- **Security and data:** no secrets in prompts (guard test, 2026-09-01); the tool server holds the
  database credential, the model process does not and has no network egress except the tool server;
  acting principal = this ticket's customer; irreversible actions reachable: none (send is a human
  action); rule of two: untrusted input yes, private data yes, external communication no; data sent
  to the vendor: personal (names, ticket text) under a zero-data-retention agreement; data kept:
  redacted transcripts 90 days, support role only; the process group is killed on timeout so the
  tool server never outlives the session.
