# Call-site contract

One file (or one doc-comment block) per model call site. Fill every field before writing the prompt.
A blank field is a design gap; a blank *consumer* means the call should not exist. A field that
cannot be known until the call has run (measured latency, cadence, quota share) is written as
`TBD(reason, by YYYY-MM-DD)` so the inventory test lets it through until the date. For an agentic
call, sections 5 and 6 describe the tool argument schemas and the tool server's checks.

Copy from the line below.

---

## Call site: `<package.module.function>`

**Id:** `<short-id>` (registered in the call-site inventory)
**Owner:** `<person or team>`
**Created:** `<YYYY-MM-DD>`  **Contract last reviewed:** `<YYYY-MM-DD>`
**Build stage:** `<what exists in code today; what is design only>`

### 1. Purpose and consumer

- What the output is: `<one sentence>`
- Who reads it: `<person, page, job, or system>`
- What decision changes because of it: `<one sentence>`
- What happens if the call never runs: `<one sentence>`

### 2. Trigger

- Event that runs it: `<event, request, or scheduled window>`
- Delta condition (runs only if): `<what must have changed since the last run>`
- Deduplication key: `<what makes two runs the same run>`
- Expected cadence: `<n per day>` and maximum: `<n per day>`

### 3. Inputs

**Injected facts** (the output may contain no other facts):

| Fact | Source of truth | Computed by | Snapshot |
|---|---|---|---|
| `<e.g. current price>` | `<table, API, file>` | `<function>` | `<same snapshot as guards: yes>` |

**Closed vocabularies** (the output may reference no other identifiers):

| Vocabulary | Shown to the model as | Validated against |
|---|---|---|
| `<e.g. user ids, page slugs, action names>` | `<list in prompt section X>` | `<the same list, by exact match>` |

**Doctrine** (stated in the prompt): `<what this call is for, what it is not, whose interests it serves>`

**External text**: `<none | which fields; scrubbed by <function>; fenced as data>`

**Ambiguous terms defined**: `<e.g. "change" = 3-month close-to-close, percent>`

### 4. Model, effort, budget

- Model: `<name>` (in whitelist: yes)
- Effort / reasoning level: `<level>`
- Measured latency: p50 `<s>`, p95 `<s>`, measured on `<date>`, n = `<n>`
- Timeout: `<s>` (= p95 × `<margin>`)
- Priority in the scheduler: `<high | normal | low>`
- Budget unit and expected use: `<e.g. 12 calls/day, ~5% of the daily quota>`

### 5. Output

**Schema** (requested at generation time):

```json
{ "<field>": "<type>", "evidence_used": ["<ids from the shown evidence>"] }
```

**Required citations**: `<which fields must cite shown evidence>`

**Worked examples in the prompt**: `<n>`, spanning classes: `<list>`

### 6. Validators, in order

| # | Layer | Check | Status | On failure |
|---|---|---|---|---|
| 1 | Schema | `<validator>` | built / planned(by date) | outcome = parse_failure, keep last good |
| 2 | Vocabulary | every id ∈ shown set | | drop the item, log `vocab_reject` |
| 3 | Numeric copy | every number == an injected value | | drop the item, log `numeric_reject` |
| 4 | Audit | `<specific failure mode checked>`; say what it does *not* catch | | bias chosen by cost asymmetry (see agent rules); state it |
| 5 | Suppression | `<what code refuses to surface regardless>` | | suppressed, counted |
| 6 | Structural | `<what the model cannot do at all>` | | n/a |

The status column exists because reviewers read a validators table as shipped defence. A planned
row is a commitment with a date, not a guarantee.

**Iteration loop**: `<does the model ever see its own prior output? if yes, drift test: <test name>>`

### 7. Failure policy

- Transport error / timeout / rate limit: `<skip loudly | keep last good (TTL <h>) | abort>`
- Parse failure: `<same or different>`
- Empty or fully-rejected output: `<what the consumer sees>`
- Last-good artifact location and TTL: `<path or table>, <h>`

### 8. Observability

- Log record fields beyond the standard set: `<extra fields>`
- Staleness surface ("as of" shown at): `<page, field, or endpoint>`
- Liveness derived from: `<this call's successful runs, window <h>>`
- Alert thresholds: parse failures `<n / window>`, API errors `<n / window>`, silence `<h>`

### 9. Tests

- Fixture files: `<path>` (recorded on `<date>`, includes failures: yes)
- Incident-pinned regressions: `<test name → incident date and one line>`
- Guard tests touching this site: `<inventory, one-door, secrets-in-logs>`
- Live smoke: `<opt-in flag>`, off by default

### 10. Evaluation

- Metric: `<what "worked" means, measurable>`
- Control: `<what it is compared against>`
- Read date: `<YYYY-MM-DD>`
- Kill criterion: `<the number below which this call is removed>`
- Consumption check: `<how we confirm something reads the output>`

### 11. Security

- Secrets in prompt or logs: none (prompt logged as hash)
- Injection surface: `<fields carrying external text and their scrubber>`
- Tools available to the model: `<none | allowlist>`
- Writes the model can cause: `<none | via tool server, validated by <function>>`

### 12. Review

| Gate | Date | Reviewers (roles) | Verdict | Link |
|---|---|---|---|---|
| Design | | | | |
| Spec | | | | |
| Results | | | | |

---

## Worked example (abridged)

**Call site:** `triage.classify_ticket`  **Id:** `ticket-triage`

- **Purpose:** assign one of the known queues to an inbound support ticket. **Consumer:** the routing
  job. **Decision changed:** which queue receives the ticket. **If it never runs:** tickets land in
  the manual queue, which is the safe default.
- **Trigger:** ticket created; delta: not already classified; dedupe: ticket id. Cadence ~200/day.
- **Injected facts:** ticket subject, body (external text, scrubbed, fenced), customer tier (from
  the CRM). **Closed vocabulary:** queue names, the full list of 14, validated by exact match.
  **Doctrine:** "Prefer the manual queue when unsure; never invent a queue." **Defined terms:**
  "urgent" means tier A or a stated outage.
- **Model:** small tier, effort low; p95 measured 4.1 s on 2026-08-30 (n = 300); timeout 12 s.
- **Output:** `{ "queue": "<name>", "confidence": "high|low", "evidence_used": ["subject", "body"] }`.
- **Validators:** schema; queue ∈ list else manual; confidence low → manual (suppression); the
  deterministic keyword map runs first and the model only sees tickets it did not match (structural).
- **Failure policy:** any failure → manual queue, logged, no retry storm.
- **Observability:** `queue`, `confidence`, `map_hit` logged; liveness from successful runs over 2 h;
  alert on 5 parse failures per hour.
- **Tests:** 40 recorded tickets including 6 malformed outputs; regression "2026-08-12 invented queue
  'Billing-EU'"; inventory test lists `ticket-triage`.
- **Evaluation:** metric = agreement with the manual queue's final assignment; control = keyword map
  alone; read date 2026-10-01; kill if agreement is not at least 10 points above the map.
- **Security:** no secrets; body scrubbed of instruction-like lines; no tools; no writes.

## Worked example: an agentic call (abridged)

**Call site:** `assistant.run_session`  **Id:** `support_session`

- **Purpose:** one support-assistant session that reads a customer's tickets and may reply, tag,
  or escalate through tools. **Consumer:** the customer (the reply) and the support team (the
  tags and escalations). **If it never runs:** tickets wait for a person; nothing breaks.
- **Trigger:** a ticket enters the queue and no session is open for it; dedupe by ticket id.
- **Injected facts:** customer tier and open tickets (from the CRM, at session start); ticket text
  and history through read tools, live at read time (the server retrieves, the model judges).
  **Closed vocabularies:** ticket ids, tag names, and escalation queues exist only as tool
  arguments validated by the tool server against the database; the tool list itself is the action
  vocabulary and nothing outside it exists. **Doctrine:** "Answer only from the ticket and the
  knowledge base shown; escalate when unsure; never promise a refund." **External text:** every
  ticket is customer-written and reaches the model through tool results; the server strips
  instruction-like lines and fences each ticket as data; instruction-following on ticket content
  is a known residual risk, bounded by the tool allowlist.
- **Model:** mid tier; timeout 600 s wall clock, TBD(measure p95 over the first 200 sessions, by
  a date); priority normal.
- **Output:** no completion-level schema. The output is a sequence of tool calls; each tool's
  argument schema is the schema layer, and the transcript is stored on the session row.
- **Validators:** (1) tool argument schemas; (2) ids and tags exist for this customer; (3) numeric
  copy: any amount in a reply must equal an amount shown in a tool result; (4) audit: a second
  deterministic pass blocks replies containing "refund" unless an escalation was filed; (5)
  suppression: caps of 12 tool calls, 2 replies, 600 s; (6) structural: only the support tool
  server is mounted; built-in tools are disabled; the server acts only as this assistant on this
  ticket.
- **Failure policy:** transport error or timeout: committed tool actions stay, the session is
  marked aborted with the partial transcript, the ticket returns to the human queue; no retry.
- **Observability:** one call record per session with outcome class; one event row per tool call;
  the ticket view shows "assistant replied at <time>". Liveness: completed sessions per hour.
- **Tests:** recorded transcripts including an aborted one; tool server tests for every refusal;
  a guard test that no code outside the door spawns the model.
- **Evaluation:** metric = share of assistant replies not edited by a person before sending;
  control = the human-only queue; read date set; kill if below 60 % after four weeks.
- **Security:** no secrets in prompts; the tool server holds the database credential, the model
  process does not; the process group is killed on timeout so the tool server never outlives the
  session.
