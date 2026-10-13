# Frame-Inversion Review: llm-practice-framework at b41ba8d (branch panel-2026-10-12, base 4c8d6ce)

Reviewer: Frame-Inversion Reviewer, fresh session. Gate: spec, before merge and publish. Build stage as
given: documents and scripts exist, 177 checks pass; the controls the documents describe for adopters
are design guidance; the only code is the scripts. Read in full: README.md, call-site-contract.md,
agent-rules.md, ADAPTING.md, evaluation.md, LOCAL.template.md, panel-protocol.md, adapters/README.md,
adapters/generic/panel-run.sh, the four reviewer prompts (1-domain-data-and-veto, 2-security-and-systems,
3-engineering-experience-observer, 4-frame-inversion), adapters/claude-code/skill-header.md,
adapters/claude-code/install.sh, adopt.sh, tests/run.sh; then, after the incident reports were drafted,
the round diff for push-on item 6. Not read: docs/reviews/ (as instructed), the 4c8d6ce tree (not
available to me), make-skill.sh and the generated SKILL.md (not in scope). Glob and Grep were not
available in this session, so I could not enumerate adapters/generic/prompts/; I read the four files
the tests name and assume there is no fifth.

Everything below rests on quoted text. Line numbers are those of the files as read today.

---

## 1. Incident reports

### Incident 1 (primary): one account's weekly summary served to another account through the keep-last-good path

**Adopter.** A B2B analytics SaaS with about 400 customer accounts. Service scale. Adopted b41ba8d on
2026-10-14; a small team that read every document and did what they said.

**The call site.** `digest.weekly_account_summary`, shape scheduled artifact; consumer: each account's
administrator (a third party); evidence: that account's own usage records. The contract was copied from
`call-site-contract.md` and every field filled:

- Trigger: "Deduplication key: ISO week". Cadence 400 per week, hard cap 600 per day in the door.
- Inputs: data sources "usage table, filtered to the account by `scope_to_account()`"; closed vocabulary
  "workspace ids, scoped to the account".
- Failure policy: "Parse failure or truncation: keep last good (TTL 10 d)". "Last-good artifact
  [scheduled artifact]: table `llm_artifact_last_good`, 10 d; at expiry the consumer sees 'no summary
  this week'".
- Observability: "Log record fields beyond the standard set: none"; "Liveness derived from: this call's
  successful runs, window 8 d"; "Content sample: 20 outputs a week, drawn at random by `sampler.py`
  across the week and stratified by hour, read by the Customer Success lead in the admin console".
- Tests: "Entitlement test: a fixture record owned by another account is never shown or emitted"
  (passes, through the production entry point).
- Evaluation: harm floor "any other-account data in the weekly sample pauses the feature (20 a week
  sees a 14 % rate with 95 % probability)".

Spec gate 2026-10-27, Claude Code adapter, four sessions: MODIFY-BEFORE-BUILD (timeout justification,
a missing alert threshold). Folded in. Door audit in LOCAL.md: eight of eight met. Ladder at the
results gate: level 3 in Inputs, Validators, Failure handling, Observability.

**Timeline.**

- 2026-11-02. First run. 400 calls, 400 `ok`.
- 2026-11-30. Three large accounts exceed the output token cap for the first time (more workspaces, a
  longer summary). Outcome `truncated`; the call site applies its policy and calls
  `keep_last_good('weekly_account_summary')`. The store is keyed by call-site id, because every other
  per-call-site thing is (the registry, the cap, the liveness window, the TTL) and the template field
  is singular. It returns the most recent successful artifact for the call site, which belongs to
  account M, and writes it into the three failing accounts' slots with the banner the framework
  requires: "last good shown, as of 2026-11-23". The banner is accurate. The content is M's.
- Same day. The alert "five parse failures per hour per call site" does not fire: three `truncated`
  records spread by the scheduler over four hours. The operations page shows `default_served: 3` for
  the call site; nothing alerts on it, because none of the starting alerts does.
- Every week after. Three to nine accounts, always the largest, receive another account's summary. The
  liveness check, "last `ok` record for this call site is younger than its cadence", is green every
  week. The content sampler draws 20 of the week's *outputs*; a re-served last-good artifact is not an
  output, so it is never in the sample, and the harm floor's counter stays at zero.
- 2027-01-11. An administrator at account K forwards their summary to support: it names account M's
  workspaces and the names of M's top users. Legal classifies it as a cross-tenant disclosure under the
  data processing agreements. Blast radius: 23 accounts over ten weeks, reconstructed from the artifact
  table's timestamps, because the call log's standard fields (call site, outcome class, output hash)
  cannot say which account a `truncated` record belonged to.

**What the team did because the framework told them to.**

- Kept the last good artifact with a TTL and showed the banner (README 3.4, 3.5, 3.7; contract 7 and 8).
- Derived liveness from "this call's successful runs" per call site (contract 8; ADAPTING rule 8).
- Wrote the entitlement test as specified: a fixture owned by another principal is "never shown or
  emitted" (README 3.2; contract 9; ADAPTING 6).
- Sampled "outputs" (README 3.7; contract 8).
- Logged the minimum fields and nothing more (README 3.7; ADAPTING rule 8).
- Deduplicated by "what makes two runs the same run" (contract 2) and chose the week.

**What they did not do because the framework did not tell them.**

- Key the last-good store, the deterministic default, the dedupe key, and the liveness window by
  (call site, acting principal).
- Test the failure path with two principals; the entitlement test covers what the model is shown and
  emits, not what the failure policy serves.
- Put the acting principal in the log record.
- Sample what the consumer saw, including re-served artifacts and defaults, not only model outputs.
- Alert on defaults served or last-good served per principal.

**Plausibility.** The two code decisions that caused the loss (a last-good store keyed by call site; a
liveness window keyed by call site) are the template's and ADAPTING's wording taken literally. The
README states that this vocabulary came from a single-tenant system. It does not translate that
admission into a rule.

### Incident 2 (secondary): a spec gate recorded as passed after the author demoted the blocker

**Adopter.** Two engineers; Claude Code adapter; LOCAL.md names "the user" at each gate as the PR
approver, the other engineer. The contract under review lets a support assistant file refund
escalations through a tool; a person releases them from a hold queue that shows "recipient, amount,
record id".

**Timeline.**

- 2026-11-18, spec gate. The Frame-Inversion session returns BLOCKERS: the approval surface shows the
  deterministic arguments but not on whose behalf the escalation was filed, and the only test of the
  principal is the server-side filter, not the binding from the authenticated request.
- Same day. The author's session re-verifies ("the door binds the principal from the ticket owner; the
  server filters on it"), classes it as a judgment finding, and re-dispatches the same seat once with
  the same prompt, as section 6 says. The second run raises two other modifications and not this one.
  Per section 6, "A blocker that does not reproduce is demoted to modify-before-build." Consolidated
  verdict: "MODIFY-BEFORE-BUILD (2 modify, 1 blocker absorbed)". Both raw reports are copied into
  docs/llm-framework/reviews/.
- CI: a report is linked and dated after the last change to the contract; the check is green. The
  approver reads the consolidated line and the folded-in modifications and approves. The review log
  records "MODIFY-BEFORE-BUILD".
- 2027-01-20. After a refactor of session start, a session for customer A is bound to customer B's id
  for the length of one request. The model files an escalation; the hold-queue reviewer sees a valid
  record id and amount for B and releases it; B is refunded for A's complaint. The postmortem finds the
  original FI report in docs/llm-framework/reviews/ with BLOCKERS on its verdict line, the review log
  with MODIFY, and no second person anywhere between them. The framework requires a second approver
  for moving a TBD date; it requires nobody for refuting a blocker.

---

## 2. What the framing hid (the inversion)

1. **"Call site" is the unit of everything; "principal" was bolted onto three rows.** The registry,
   the cap, the log, the liveness window, the TTL, the dedupe key, the default count, and the
   content-sample stratification are all per call site. The 2026 additions put the acting principal
   into Inputs, Validators, and Actions (ladder rows "evidence scoped to the principal", "structural
   ceiling", "Bounds per action, principal, and day") and nowhere else. The ladder's Failure handling
   row reads "Bounded retries with idempotency keys; TTL semantics or a visible default; caps with
   `cap_hit`" (README line 503) and its Observability row "Liveness from real calls; staleness surfaces;
   drift detection; content sample where the consumer is not the operator" (line 505). A project
   scores level 3 on both with a per-call-site store that leaks.

2. **The threat model is "the model misbehaves"; the leak is code.** The framework's ceiling is "what
   the model could reach and move if every instruction to it were ignored" (README line 44). Incident 1
   is not the model reaching anything; it is the failure-policy code around a model call serving the
   wrong person's artifact. The entitlement test is written against the model path ("never shown or
   emitted", contract line 167) because that is where the framing looks. Section order reinforces it:
   entitlement is settled in sections 3 and 6 of the contract; by section 7 (Failure policy) and 8
   (Observability) the author has "done" entitlement.

3. **The admission is phrased as vocabulary, not as a gap.** README lines 59-61: "The source was a
   scheduled, single-tenant decision-support pipeline whose output was read by its own operator. The
   principles transfer. The vocabulary of cadence, staleness, and keep-last-good was shaped by that
   system." A reader hears "the words are from there"; the rule that is missing (every persisted
   artifact, default, and liveness signal is per principal) is not implied by "vocabulary". The round
   diff removed the older, sharper admission that "the loss model (a false fact in prose)" was also
   shaped by that system, which was the sentence that told a multi-tenant adopter the framework's loss
   model was not theirs.

4. **Independence is session independence; the person stays the same.** "The author never reviews its
   own work in the session that wrote it" (panel-protocol line 6). The author is still the orchestrator,
   the author chooses the push-on list and the seats, the author re-verifies and refutes, the author
   demotes a blocker that does not reproduce, the author writes the consolidated line the approver
   reads. "Any blocker blocks" is true of the raw report and false of the record.

5. **"A panel report is linked" is existence, not outcome.** README 3.10: "a check in CI on any change
   touching a registered call site or a contract (a panel report is linked, no read date has expired)".
   ADAPTING 5.6 is the same: the CI check "fails any change ... unless it links a report ... dated after
   the last change". The framework's own P3, "Instructions are requests; code is the control", is not
   applied to the verdict: nothing structural reads it.

6. **"Read-only tools" is the control in the generic runner and a request in the Claude Code adapter.**
   In panel-run.sh the reviewer's only output is stdout and it has no filesystem; the ceiling is real.
   In the skill header the reviewer has Read on the whole filesystem and "Write to its own report path
   only", which is a sentence in a prompt. The two are described with one phrase.

---

## 3. Findings

Grades: BLOCKER / MODIFY / LIMITATION. Findings are grouped under the push-on items, in order.

### Push-on 1. Acting principal and entitlement

**F1. Nothing in the failure policy, the last-good store, the deterministic default, the dedupe key,
the liveness window, the log record, or the content sample is keyed by the acting principal; the
entitlement test covers only the model path.** BLOCKER.

- Where:
  - README 3.4, line 266-268: "Where an artifact persists between runs, the last good one is kept with
    a TTL, a timeout or parse failure never overwrites it, and the contract says what the consumer sees
    when the TTL expires."
  - README 3.5, line 296-297: "A deterministic default is visibly a default where it is read and is
    counted per call site".
  - README 3.7, line 351-354 (log minimum fields): "timestamp, call site, session or trace id, parent
    call id for an agent step, requested and served model id, effort, duration, input, output, and
    cached-read tokens, stop reason, whether external text was read (`read_external`), outcome class,
    prompt-template hash, output hash." No principal.
  - README 3.7, line 373-375: the sample is "drawn at random by code across the period, including the
    outputs the audit held or the agent discarded".
  - call-site-contract.md line 38: "Deduplication key: `<what makes two runs the same run>`"; line
    139-140: "Last-good artifact `[scheduled artifact]`: location and TTL `<path or table>, <h>`";
    line 149: "Liveness derived from: `<this call's successful runs, window <h> | ...>`"; line 167:
    "Entitlement test: `<a fixture record owned by another principal is never shown or emitted>`".
  - ADAPTING rule 8, line 188-189: "Liveness is \"last `ok` record for this call site is younger than
    its cadence\", computed from this log and nothing else".
  - ADAPTING 6, line 355-357: "a fixture record owned by another principal (and one with no owner) is
    never shown and never emitted, tested through the production entry point."
  - README line 190-191 is the only place a multi-principal call is addressed: "A call that produces
    output for several consumers at once is several calls, one principal each." It says how many calls;
    it says nothing about what those calls share.
- Why it matters: Incident 1. The framework explicitly addresses products where "the model can read or
  move another person's data" (README line 62) and claims "within bounds" in its first paragraph. A
  diligent team following the template as written builds per-call-site keep-last-good, per-call-site
  liveness, and a principal-less log, and the leak is silent: the pipeline is green, the banner is
  correct, the sample never sees it, and the blast radius is unrecoverable from the log. The README's
  own line 59-61 names this vocabulary as single-tenant-shaped and then stops.
- What would resolve it:
  1. One sentence in README 3.4/3.5 and agent-rules "(artifact)": "Where a call runs for more than one
     principal, the last-good artifact, the deterministic default, the dedupe key, and the liveness
     window are keyed by (call site, acting principal); a failure for one principal never serves
     another's artifact."
  2. Add "acting principal (an opaque id)" to the log record's minimum fields in README 3.7, ADAPTING
     rule 8, and contract 8, so `default_served`, `vocab_reject`, and `truncated` can be attributed.
  3. Extend the entitlement test in README 3.2, contract 9, and ADAPTING 6: "...is never shown, emitted,
     or served, including by the failure policy; the test runs a failure fixture for principal A after a
     success for principal B."
  4. In contract 8 and README 3.7, sample "what the consumer received", stating that defaults and
     re-served artifacts are in the population.
  5. Add "defaults or last-good served, per principal above `<n>`" to the starting alerts in ADAPTING 6.
  6. Add "per principal where the call runs for more than one" to the ladder's Failure handling and
     Observability level-3 cells.

**F2. The approval surface shows the deterministic arguments but not the acting principal; the
consumer branch of the principal field names no binding test.** MODIFY.

- Where: README 3.5 line 325-326: "The approval surface shows the deterministic tool arguments
  (recipient, amount, record id), not the model's description". Contract 11 line 189-191: "the surface
  showing the deterministic tool arguments". Contract 11 line 179-183: "Acting principal: `<the consumer
  in section 1 | a service identity acting for <consumer>, with reads and evidence narrowed to that
  consumer's entitlement by <function>, tested by <test>>`; bound by `<code path>` at session start
  from the authenticated request" — "tested by" appears only in the service-identity branch.
- Why: Incident 2. If the binding is wrong, every argument the approver sees is valid for the wrong
  person; the approver has no way to notice. The entitlement test (F1) tests the filter, not the binding.
- Resolve: add "and on whose behalf (the acting principal)" to the approval-surface sentence in README
  3.5, agent-rules, and contract 11; add to contract 9 and ADAPTING 6 a binding test: "a request
  authenticated as A cannot start a session bound to B, tested through the production entry point".

**F3. A sub-agent's principal is not stated to be inherited from the door.** MODIFY.

- Where: README P1 line 91-93: "a sub-agent that read any external text is external text to its
  caller: fenced, labelled, and under the caller's ceiling." Contract 11 line 180-182: the principal is
  "bound by `<code path>` at session start". A sub-agent's session starts from a tool call the model
  makes; nothing says its principal is the parent's, not an argument of the spawning call.
- Resolve: one clause in P1 or 3.5: "a sub-agent session inherits the parent's acting principal from
  the door, never from the arguments of the call that spawned it."

**F4. Operator-internal content that reaches a third party is a named category with no validator and
no harm-floor line.** MODIFY.

- Where: contract 1 line 30 names the category: "Whose data the evidence is: `<the reader's | the
  operator's | another party's ...>`". The agentic example reads "ticket text and history through read
  tools" (line 284-285), lists for the recall-biased audit "money, eligibility, or a commitment, or
  contains a URL, email address, or phone number not in the knowledge base" (line 307-309), and sets
  the harm floor at "any disclosure of another account's data or any unauthorised action" (line 338-339).
  Internal notes on a ticket's history are the operator's data about this customer; a draft that quotes
  them discloses to a third party and is caught by none of the listed checks.
- Resolve: add "operator-internal fields (internal notes, internal tags, margin or risk fields)" to the
  audit's held classes in the example and to README 3.4 layer 4; add a "visible to the reader: y/n"
  column to the data-sources table in contract 3.

**F5. The first worked example contradicts itself on per-customer reads and models the pattern the
"Mistakes" section forbids.** MODIFY.

- Where: call-site-contract.md line 233: "customer tier (from the CRM, as of the ticket's creation)";
  line 258: "entitlement test n/a(no per-customer reads: one ticket in, one queue out)"; line 265-266:
  "acting principal: the operator's routing service". ADAPTING 8 line 431-433: "Letting a service
  identity be the acting principal. The identity that runs the call is not the party whose entitlement
  bounds the output."
- Why: the example is what adopters copy. It shows an `n/a` whose reason is false on its own terms
  (a CRM lookup by customer is a per-customer read) and a service identity as principal, justified by
  the consumer being the operator; the next adopter copies both into a call whose consumer is not.
- Resolve: change the `n/a` to a one-line entitlement test (the CRM read is keyed by the ticket's
  customer id, and a fixture tier record for another customer is never read), and add to the example
  why a service identity is acceptable here and the sentence that makes it unacceptable elsewhere.

### Push-on 2. The panel's own ceiling

**F6. The CI gate checks that a report exists, not what it says; the author refutes blockers alone;
the "unanimity" rule is unintelligible; the review log records only the consolidated verdict.** MODIFY.

- Where: README 3.10 line 453-455: "a check in CI on any change touching a registered call site or a
  contract (a panel report is linked, no read date has expired)". ADAPTING 5.6 line 330-332: "a CI
  check fails any change that touches the door, a registered call site, or a contract unless it links a
  report ... dated after the last change to those paths". panel-protocol 5 line 126-127: "Every finding
  is a hypothesis. The author re-verifies each one against the code or the data before adopting it, and
  records refuted findings with the evidence." Section 6 line 144: "A blocker that does not reproduce
  is demoted to modify-before-build." Line 141-142: "re-dispatch the decisive pair (fresh session, same
  prompt) and require agreement across runs." Line 146-147: "The logic is unanimity: a finding counts
  when it appears in every run that raised it and in none of the runs that did not" — both clauses are
  tautologies; the sentence specifies nothing. Section 4 line 117-118 offers "MODIFY-BEFORE-BUILD (3
  modify, 1 blocker absorbed)" as a model consolidated verdict. LOCAL.template.md Review log columns:
  "| Date | Artifact | Seats | Verdict | Reports |", one verdict. Contrast ADAPTING 8 line 442-443:
  "Bumping TBD dates. A moved by-date is a decision; it gets a second approver".
- Why: Incident 2. A stochastic reviewer re-run once will fail to raise a true blocker often; the
  protocol then demotes it on the author's say-so, the CI check cannot tell, and the approver reads a
  line the author wrote. The framework's P3 is not applied to its own gate.
- Resolve: (a) the CI check parses the verdict line of every linked report (the runner already does)
  and fails on BLOCKERS or no verdict line; (b) at Service scale and above, a refuted or demoted
  blocker needs a second person, as a moved by-date does, and the record says who; (c) the Review log
  carries the raw per-seat verdicts beside the consolidated one; (d) replace the unanimity sentence with
  an operational rule (for example: "a blocker is confirmed if it appears in at least one of K
  re-dispatches; it is demoted only if it appears in none of K >= 2").

**F7. In the Claude Code adapter the reviewer's write scope is a request; the report travels from an
untrusted read to a committed file through a model, and the committed directory is not scanned.** MODIFY.

- Where: skill-header.md line 30-32: "fresh subagents with read-only tools (Read, Grep, Glob, and Write
  to its own report path only; never Bash or Edit: they read untrusted text)". Line 39-40: "It writes
  the full report there and returns only the verdict plus a five-line summary." Line 49-50: "copy the
  reports into the repository." panel-protocol 3 line 69-72: "In a coding agent: file reading and
  search, plus writing its own report file, never shell or edit ... This is the panel's own ceiling."
  README 3.8 line 384-386: "a guard test scans the fixtures directory for secrets and personal-data
  patterns." ADAPTING 6 line 351-352: "one for secrets and personal-data patterns in log records and in
  the fixtures directory". README P3 line 105: "Instructions are requests; code is the control."
- Why: "to its own report path only" binds only where the tool's permission system enforces it; a
  reviewer that has Read a file can Write over it, including the artifact under review or another
  reviewer's report in the shared scratch directory. Separately, a reviewer told to quote what it reads
  can be steered to quote a credential or a fixture line; the orchestrator (a model) copies the report
  into docs/llm-framework/reviews/, which no guard test scans. The generic runner's ceiling (stdout
  only) is the real one; the adapter's is described with the same words.
- Resolve: in skill-header and panel-protocol 3, say that the write restriction is a request unless
  the tool's permission rules deny Write outside the report path, and prefer having the reviewer return
  the report text for the orchestrator to write (the generic runner's shape); scope reviewers' Read to
  the project where the tool allows; add docs/llm-framework/reviews/ to the secrets-and-personal-data
  guard in README 3.8 and ADAPTING 6; tell reviewers not to quote fixture or credential content.

**F8. The runner reports the last verdict-token line while the output shape puts findings, which
quote, after the verdict.** MODIFY.

- Where: panel-run.sh line 140: `grep -E '^(BLOCKERS|MODIFY-BEFORE-BUILD|APPROVE-AS-IS)[[:space:]]*$'
  ... | tail -1`. 4-frame-inversion.md line 25 and 28: "each item quoting the artifact" ... "Then the
  verdict ... Under it, each finding as: what, where, why it matters, what would resolve it." tests/run.sh
  line 267-274 pins the last-line semantics.
- Why: a reviewer that writes BLOCKERS and then, in a finding, quotes a line of the artifact that is a
  bare token (a Review table, a prior panel report, this framework's own documents) flips the summary
  line. The protocol says a person reads the report; the line is what the person reads first.
- Resolve: report "CONFLICTING VERDICT LINES; read the report" when more than one distinct token line
  is present, or require the verdict as the last line of the report (as this panel's own brief did) and
  parse the last line only.

**F9. The panel's own model calls are outside the door, outside any contract, and nothing says the
inputs are redacted or under which vendor terms they travel.** MODIFY, and a LIMITATION to state.

- Where: panel-protocol 9 line 180-181: "Any tool works as long as each reviewer gets a fresh context,
  the artifact, and the code"; section 10 covers cost only. agent-rules line 16: "No model call exists
  without a call-site contract". Contract 11 line 200-202 states "Data sent to the vendor" for the
  product call only. LOCAL.template.md "Vendor terms relied on" is for the product. panel-run.sh line
  132 passes HOME, so the CLI's own credential store decides which account the artifact goes to.
- Why: at a results gate the artifact can carry sampled outputs and findings (the content sample
  "copies are not kept beyond the finding", contract line 155, so findings do keep copies). Those go
  to a vendor under whatever account the reviewer CLI resolves, with no log record, no pinned model,
  no data-class statement. The framework applies P4 and P6 to the product and not to itself.
- Resolve: a line in panel-protocol 9 and LOCAL.md: the panel's vendor, account, model, and terms are
  recorded; results artifacts handed to the panel are redacted like fixtures; the runner prints the
  command and the variable names it passed so the run record shows what reached the reviewer.

### Push-on 3. The existing adopter of 4c8d6ce

**F10. A refresh reports success while LOCAL.md keeps the old template's sections; the template is
never copied into the project; the skill is installed "once per machine" and never refreshed.** MODIFY.

- Where: adopt.sh line 84-87: LOCAL.md is created only `if [ ! -f "$dest/LOCAL.md" ]`; LOCAL.template.md
  is not in `files` (line 21) and is not copied. ADAPTING 2 line 61-63: "Re-running is safe: it checks
  everything before writing anything, refreshes the six files and the marked block in place, and never
  touches `LOCAL.md`". ADAPTING 7 says nothing about LOCAL.md's sections. README line 79:
  "adapters/claude-code/install.sh      # optional, once per machine, for that tool"; ADAPTING 7 does not
  mention re-running it. This round added to LOCAL.template.md "Project-level controls referenced by
  every contract" (vendor terms, sandbox, guard tests, content-sample readers), a scoping-table row, and
  a door-audit wording change; contract 11 now says "(or \"per LOCAL.md vendor terms\")" and "per
  LOCAL.md door audit of `<date>`".
- Why: an 4c8d6ce adopter re-runs adopt.sh, sees "copied the six framework documents", and their
  contracts point at LOCAL.md sections that do not exist; reviewers who "read this file first"
  (LOCAL.template line 4) read the old one. Their orchestrator follows a skill from 4c8d6ce (no
  read-only-tools instruction, no "sessions dispatched" record) while the project's panel-protocol.md
  says otherwise. Nothing reports either.
- Resolve: adopt.sh compares the `## ` headings of LOCAL.template.md with the project's LOCAL.md and
  prints the headings LOCAL.md lacks (or copies LOCAL.template.md beside it so `diff` is one command);
  ADAPTING 7 says to re-run install.sh after updating the framework checkout and README line 79 says
  "once per machine and after each framework update".

**F11. The legacy-block detection is tested against today's wording, not the published one; a partial
write is possible with a misleading message.** MODIFY.

- Where: adopt.sh line 54 detects an unmarked block by `^## LLM usage rules` and the sentence 'No model
  call exists without a call-site contract'. tests/run.sh line 126: `cat "$fw/agent-rules.md" >
  "$p/AGENTS.md"` — the fixture is the current file. If the 4c8d6ce heading or sentence differed, or the
  adopter edited the heading (as test `t_adopt_edits_inside_block_replaced_outside_kept` shows they
  do), detection misses and adopt.sh appends a second, marked block: "appended the rules block",
  success, two rule sets. Separately, adopt.sh copies the documents (line 81-83) before the rewritten
  block is checked (line 105-106); on that failure it prints "$rules was not changed" although the
  documents were.
- Resolve: make the legacy fixture a verbatim copy of the 4c8d6ce agent-rules.md (checked into
  tests/fixtures), and detect on the sentence alone with a heading-agnostic check or on a hash of the
  published block; move the rewrite dry-run into the pre-flight so no document is copied when the block
  cannot be rewritten.

**F12. The runner's allowlist examples omit model and profile variables, and the runner does not
record what it passed.** MODIFY; HOME as a credential store is a LIMITATION to state.

- Where: panel-run.sh line 10-13: "an API key, a config path; often LANG, TERM, TMPDIR, XDG_CONFIG_HOME,
  HTTPS_PROXY, NO_PROXY, SSL_CERT_FILE"; line 53 passes an unset name empty with a stderr note; line
  132: `env -i PATH="$PATH" ${HOME+HOME="$HOME"}`; line 120-121 prints roster and seats only. ADAPTING
  5.4 line 304: "(an API key, a proxy)".
- Why: a missing API key fails loudly; a missing model or profile variable does not. The CLI falls back
  to its default model or to a credential under HOME, and the panel runs on a different model or account
  than LOCAL.md says, with a clean report. The "environment allowlist" bounds variables, not files under
  HOME, and the docs do not say so. (The diff shows this behaviour predates the round; what is new is
  the prose promising "nothing else from your environment reaches it".)
- Resolve: add model/profile variables to the examples; print `LLM_REVIEW_CMD` and the PANEL_ENV_PASS
  names at the start of a run; one sentence in adapters/README: "HOME is passed, so the command's own
  configuration and credential files are reachable; the allowlist bounds variables, not files."

### Push-on 4. Scale exemptions

**F13. The Script row and the Agentic row are both true of a one-person tool-using script, and the
Script exemption in agent-rules drops every ceiling rule.** MODIFY.

- Where: ADAPTING 1 line 19-20: "Pick the row that describes the project and adopt that column"; line
  24 Script: "One or two model calls, one person, output read by that person"; line 26 Agentic
  product: "The model can act: call tools, write data, message people". agent-rules line 5-9: "At
  Script scale only the Mandatory cell of the Script row ... is required (injected facts,
  schema-validated structured output, one function that calls the model, a log line per call, one
  redacted fixture, one separate reviewer session); every other rule here is advice until the project
  grows." The Script Mandatory cell has no tool allowlist, no approval step, no ceiling. The scale is
  self-declared in LOCAL.md ("Scale: `<script | service | agentic product>` and one sentence on why").
- Why: a personal script that drafts and sends mail, or runs a coding agent with shell, satisfies the
  Script row's first two clauses and is read by its author; it also "can act". With both rows true the
  author picks the cheaper one and the agent reads that every bound is advice. The README's limits
  section says "the veto seats cannot be dropped for a product that reaches a third party", which the
  Script row does not mention.
- Resolve: one sentence under the table: "Capability and audience decide the row, not size: the moment
  the model can act through a tool, or the output reaches anyone but the person running it, the project
  is Agentic or Service whatever its size." Add to the Script Mandatory cell "no tool the model can call,
  or the Agentic row".

**F14. "n/a(reason)" is reviewed by people only, and the examples normalise "recoverable" as the
reason for dropping a harm floor.** LIMITATION to state (the structural check cannot judge a reason).

- Where: README line 163: "a single field that does not apply is `n/a(reason)` and the reason is
  reviewed at the spec gate". Worked example 1 line 263: "harm floor n/a(a misroute is recoverable)";
  evaluation.md line 26: "`n/a(reason: the reader is the operator and the output is recoverable)`".
  The example's own defined term "urgent means tier A or a stated outage" (line 237) describes a
  misroute whose delay is not recoverable for the customer.
- Resolve: state that `n/a` reasons are a review-only control, and in the example either keep a small
  floor (urgent tickets misrouted out of the urgent queue) or say why the delay is acceptable.

### Push-on 5. The README's claims about itself

**F15. "Which rules are backed by an incident and which are reasoned is stated" is a class-level list,
and the whole third-party and principal apparatus is in the reasoned class.** MODIFY.

- Where: README line 7-8: "which rules are backed by an incident and which are reasoned is stated under
  Provenance and limits at the end." Line 543-548: "Most rules trace to a specific incident or
  measurement there. The rules added since (agentic calls, the TBD convention, audit bias by cost
  asymmetry, and the 2026 additions on model lifecycle, caching, structured outputs, context, principal
  scope, harm floors, and data handling) came from adoption feedback and from this framework's own
  panel reviews ... they are reasoned". Line 548-549: "The incident record itself is not public."
- Why: a reader who relies on "backed by an incident" for the rules that bound another person's data or
  money is relying on rules that have never been tested by a loss, and has to parse a parenthetical
  list to learn that. The claim in line 7-8 says "stated", which a reader takes as per rule. "Most" is
  unverifiable by construction. The round also removed the older sentence "where a rule seems
  arbitrary, treat it as a hypothesis with a stated rationale", which was the reader's calibration.
- Resolve: soften line 7-8 to "the Provenance section says which groups of rules are reasoned rather
  than paid for"; add one sentence to "Where it came from" (line 59-64): "every rule here about another
  person's data, money, or messages is reasoned, not paid for"; restore the hypothesis sentence.

**F16. Limitations a reader needs that are not stated.** LIMITATION.

- The content sample is a human-review processing activity. The contract names it as one (line 204-205:
  "the content sample as a processing activity: `<reader role, n per period, what it is redacted to,
  retention>`") but Provenance and limits does not say that customer agreements, residency terms, or
  "no human review" commitments may forbid it, and that where they do the harm floor cannot be measured
  by sampling and the framework offers only the deterministic checks.
- The failure path and caches are not in the ceiling (F1): the framework bounds the model, and says
  nothing about code that serves artifacts when the model fails. One sentence in limits would have told
  Incident 1's team to look.
- The panel's own vendor exposure (F9).
- HOME and the credential store in the generic runner (F12).

### Push-on 6. The cut

**F17. Rules and admissions that lived only in README text and are now stated nowhere.** MODIFY.

- "A delegated agent's brief is the single source of its requirements **and is read-only to that
  agent**" (old README 3.11, diff line 1075-1076). agent-rules line 103 now reads "A delegated agent's
  brief is the single source of its requirements." The read-only clause is gone. An agent that edits its
  brief to match what it built is the spec-drift failure the clause existed for; "Configuration, rules,
  and credentials are human-only files" does not cover a brief. Restore the clause in agent-rules.
- "The budget unit is whatever is scarce: money, a quota window, wall-clock, or a rate limit" (old
  README 3.6 lead, diff line 930-931). Contract 4 line 85 still asks for "Budget unit and expected use";
  the term is no longer defined anywhere, including the README Terms list. Add it to Terms.
- "The examples, the loss model (a false fact in prose), and the observability vocabulary (cadence,
  staleness, keep-last-good) were shaped by that system" (old "Where it came from", diff line 516-517).
  The new paragraph keeps the vocabulary clause and drops the loss model. This is the sentence that
  told a multi-tenant adopter that the framework's idea of a loss was not theirs; see section 2, item 3.
  Restore it, and finish it: "a loss that is a disclosure or an action on the wrong person's behalf is
  reasoned here, not paid for."
- "where a rule seems arbitrary, treat it as a hypothesis with a stated rationale" (old intro, diff line
  511). See F15.
- The old 3.1 lead ("two tiers ... is the usual shape") is a heuristic, not a rule; its loss is fine.
- Cross-references checked and found intact: README 6 -> ADAPTING time budget (ADAPTING line 6-13) and
  2.1; ADAPTING 2 -> 2.1; README 3.11 -> agent-rules "Agent workflow"; README 5 and agent-rules -> ADAPTING
  section 1 Script row; README 3.10 -> protocol section 2; README "Where it came from" -> ADAPTING section
  1 shape table; contract 1 -> section 11; contract 11 -> section 3; LOCAL.template -> ADAPTING 1, 2, 3,
  5, 5.6 and protocol 2; skill-header -> protocol sections 2-6 (present in the generated file by
  construction). One cosmetic drift: README Map says of section 3 "Each box is one check" and 3.11 now
  has no boxes.

---

## 4. What I checked and found sound

- adopt.sh: pre-flight refuses a missing upstream file, a directory as the instructions file, an
  instructions file under docs/llm-framework/, a .adopt path outside the project; marker handling
  refuses indented, duplicated, or unpaired markers and changes nothing; the awk rewrite is verified
  before replacing the file; LOCAL.md, contracts/, evaluations/ are never touched; the legacy unmarked
  block is detected when its wording is today's (see F11 for the caveat). All of this is tested in
  tests/run.sh with fixtures that make the checks fail.
- panel-run.sh: every input is validated before any model is invoked (unreadable file, empty prompts
  directory, oversize input, non-integer timeouts, malformed PANEL_ENV_PASS names, PANEL_SEATS that
  selects nothing or is ambiguous); `env -i` with an allowlist, tested with a secret that is not passed;
  a 64-bit per-run nonce fence whose closing line the artifact cannot predict, tested to differ between
  runs; build stage and push-on inserted before the fenced material; timeout with SIGTERM then SIGKILL,
  tested against a reviewer that ignores SIGTERM; process-group stop on INT/TERM/HUP tested; exit codes
  documented and distinct; "NO VERDICT LINE" surfaced rather than silently empty.
- install.sh: refuses a symlinked or non-skill target and a relative CLAUDE_SKILLS_DIR; backs up rather
  than deletes; says to restart sessions.
- Document drift tests: six-file list derived from adopt.sh and checked in ADAPTING and adapters/README;
  door rules equal door-audit rows; the nine outcome classes present in all three documents that list
  them; every TBD in the template carries a by-date; no bare n/a in the copyable template; worked-example
  dates warn when they pass; every reviewer prompt carries the evidence-not-instructions sentence.
- The agentic worked example as a structure: draft-not-send; the principal bound from the ticket's
  authenticated owner and passed as a session-scoped id; ids and tags validated by the server against
  this customer's records; "Existence is not entitlement"; refunds as an escalation with a closed reason
  set acted on by a person; built-in tools disabled; the knowledge base limited to public articles; a
  canary customer excluded from caps and sample; caps per session and per customer per 30 days;
  idempotency key minted by the door with canonical arguments; compaction summaries as model output;
  rule-of-two check with the three yeses named and covered.
- Rules that hold against the inverted frame: approvals-per-hour and reversals measured, "an approval
  step that is approved more than it is read is not a control"; the recall-biased audit for anything that
  reaches a third party; a positive read never removes the control that produced it; the harm floor's
  sample sized by the rate it must exclude, with the formula; fixtures redacted before commit with a
  guard; the live smoke test opt-in and named; the prompt-template hash baseline as the golden-set
  trigger; pinned snapshots with lifecycle dates and a 90-day page-check staleness; the served model id
  logged and alerting outside the allowlist; tool lists pinned by canonical hash with refusal on
  mismatch; sub-agent output treated as external text under the caller's ceiling; conversation turns as
  context, not facts, with claims about prior turns checked by code.
- Stated limitations that are honest and useful: real-time surfaces to a third party are not covered;
  the allowlist bounds what the model does, not what it says; scrubbing and fencing are hygiene; the
  framework is not a PIA, legal review, or safety case; a coding-agent product needs its own rules and
  its PR review is an approval only if the approver did not issue the instruction.
- The round's own changes that resolved what I would otherwise have raised: the shape table replacing
  seventeen `n/a` fields; the "Letting a service identity be the acting principal" mistake; the
  reviewers-read-only sentence in every document that describes the panel; the "sessions dispatched"
  record; the clean-approve re-run scoped to decision-logic changes; the data-source change re-opening
  the spec gate; the entitlement test as a named test.

---

## 5. Verdict

One blocker (F1): a team following the template as written builds a per-call-site keep-last-good store,
a per-call-site liveness window, and a principal-less log for a per-principal call, and the resulting
cross-principal disclosure is silent on every surface the framework specifies. The README names the
single-tenant origin of exactly this vocabulary and does not convert the admission into a rule. The fix
is a few sentences in six places and one extension of the entitlement test, and it belongs before
publish because adopters build what the text says. The remaining findings are modifications and
limitations to state; F6 and F7 are the ones I would fold in next, because they are the framework's own
P3 applied to its own gate.

BLOCKERS
