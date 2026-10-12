# Frame-Inversion Review: LLM Practice Framework, revision of 2026-10-12

Artifact: `<checkout>`, branch `panel-2026-10-12`, HEAD `f0c0a9b`, compared
against the published version `4c8d6ce`. Reviewer: Frame-Inversion Reviewer, fresh context, no
access to `docs/reviews/`. Read in full: `README.md`, `call-site-contract.md`, `ADAPTING.md`,
`agent-rules.md`, `evaluation.md`, `LOCAL.template.md`, `panel-protocol.md`, `adapters/README.md`,
`adopt.sh`, `adapters/generic/panel-run.sh`; also read `tests/run.sh`, the four generic reviewer
prompts, `adapters/claude-code/skill-header.md`, and `git diff 4c8d6ce..HEAD` on the documents so
that sentences added today can be marked as such. Nothing in the repository was modified.

Build stage, as I take it: the documents are the shipped artifact. The scripts exist and have tests.
Every control the documents describe (door, inventory test, tool server, content sample, CI check)
is a design an adopter must build; in the scenarios below I assume the adopter built all of it
faithfully, because the question is what the text itself causes or conceals when followed.

Web checks used (dated 2026-10-12): Anthropic's September 2025 postmortem of three infrastructure
bugs that degraded output for a fixed model name (a routing bug sent Sonnet 4 requests to the wrong
server pool, 16 % of requests at peak; a TPU misconfiguration corrupted token output), and
Anthropic's current deprecation policy of at least 60 days' notice before retirement (an archived
version promised 6 months). Sources at the end.

Counts I verified by command, used below: the copyable contract template has 135 angle-bracket
placeholders (70 in `4c8d6ce`); the two worked examples carry 8 `n/a(...)` fields (0 before);
`README.md` is 538 lines (350 before); there is no worked example of the scheduled-artifact shape.

---

## Scenario 1. Adopted faithfully in October 2026; serious loss by Q2 2027

### The product I judge most exposed, and why

I considered the five shapes named in the brief. The one the revised text leaves most exposed is a
**per-tenant scheduled digest in a multi-tenant SaaS, produced under a service identity from a
shared retrieval index and sent to the tenant's own contacts**. It combines (a) the framework's home
shape (scheduled artifact, delta-gated, keep-last-good), (b) retrieval over documents where the
access rule lives in the retriever, and (d) a service identity acting for many principals at once.
It is the most exposed because every one of the revision's new fields can be filled truthfully and
compliantly while the control the field is named after does not exist; the other four shapes force
at least one visible `n/a(...)` or an obviously unfillable field that a reviewer can push on. The
other four are assessed after the incident report.

### The contract, as the team filled it (compliant on paper)

Call site `digest.weekly_account_digest`, id `account_digest`. Shape: scheduled artifact; delta
condition: any change to the tenant's invoices, orders, or supplier notes in the week; dedupe key:
tenant id + ISO week. Consumer: "the tenant's billing contacts (a third party)". Injected facts:
invoice totals, due dates, order counts from the billing database. Evidence: up to twelve retrieved
chunks from the shared document index (contracts, supplier notes, support threads), filtered by
`tenant_id`. Closed vocabularies: invoice ids, order ids, document ids, "scoped to the acting
principal's records". Acting principal: `svc-digest` (a service identity). Ceiling if the fence
fails: "a misleading digest that a hold queue can pull; no tools, no writes". Validators: schema
(enforced at generation); vocabulary (ids ∈ shown set, checked by code); numeric copy (every number
equals an injected or shown value); audit, recall-biased ("any amount or percentage not among the
shown values holds the digest for a person"); suppression (no digest when fewer than two facts
changed); structural (no tool, no write; the model process has no network egress). Failure policy:
transport error or timeout → deterministic default (a template digest built from the injected facts
only); cap hit → skip loudly. Irreversible action: send to a third party; gate: "reversible by hold
queue, 60 minutes, operations can pull". Rule-of-two: untrusted input yes (supplier notes), private
data yes, communicates externally yes; "three yeses: approval step above (hold queue)". Content
sample: 20 digests per day read by the customer-success lead for "disclosure of another account's
data, wrong commitments, tone". Harm floor: "any disclosure of another tenant's data in the daily
sample pauses the feature". Model: pinned snapshot `mid-2026-07-15`, vendor retirement "not sooner
than 2027-07-15". Panel: Privacy Officer and customer-relationship owner seated as vetoes; three
gates; CI verdict-link check; inventory test with TBD, read-date, and retirement expiry. Build
stage: everything built before launch except the content sample, planned(by 2026-11-30), then built.

The spec-gate panel returned MODIFY-BEFORE-BUILD (add "produced by a model, as of" to the digest
footer), folded in. The results gate approved. The frame-inversion reviewer at the spec gate wrote
an incident about a wrong invoice total reaching a customer (the loss model the framework teaches) and
one about a supplier note injecting a discount promise; both were covered by the numeric copy check
and the recall-biased audit, and the reviewer said so.

### Timeline

- **2026-11-09.** Launch. ~30,000 tenants, delta-gated to ~6,000 digests per weekday, batch tier,
  03:00 UTC, hold queue releases at 04:00 UTC. Hold-queue pulls since launch: 0.
- **2027-01-12.** The supplier-portal team (a different repository, no model call) ships "shared
  supplier notes": a supplier serving several buyer tenants can write one note visible to each of
  them. The document index stores these with `tenant_id = NULL` and a `visible_to` list. The
  retriever filter, written in October as `tenant_id == :tenant OR tenant_id IS NULL` because the
  index already held a handful of global "platform notice" documents with null tenant, now admits
  every shared supplier note to every tenant's retrieval. No file under the door, no registered call
  site, and no contract changed; the CI gate did not fire; no panel was convened.
- **2027-01-19 onward.** Supplier notes written for buyer B ("agreed 12 % volume rebate for
  Northwind through Q2; contact: j.alvarez@northwind.example") are retrieved for buyer A when A buys
  from the same supplier. The model, instructed to summarise "this week's relevant supplier
  activity", copies the rebate and the name. Vocabulary check: the document id is in the shown set
  and in `svc-digest`'s scope (everything). Numeric copy: 12 % is a shown value. Recall-biased audit:
  the percentage is among the shown values, so nothing is held. Hold queue: released at 04:00.
  Roughly 0.4 % of digests (≈ 24 per weekday) carry another tenant's commercial terms or contact
  names.
- **Content sample.** 20 of ~6,000 per day. Probability that a day's sample contains at least one
  affected digest: 1 − 0.996^20 ≈ 7.7 %. The reader must also recognise that a company named inside a
  supplier's note is another tenant, which a customer-success lead does for perhaps a third of
  tenant names; effective daily detection ≈ 2.5 %. Over the 55 weekdays before external detection the
  chance of never catching it in the sample was about 25 %, and that is what happened. The daily
  sample log reads "20 read, 0 findings" for every day of the incident. Harm-floor count: 0.
- **2027-03-31.** Buyer B's procurement director receives a forwarded screenshot: buyer A asked the
  shared supplier why Northwind gets 12 %. Complaint to the vendor's account manager, then to legal.
- **2027-04-02.** Feature paused by hand. Reconstruction from the retained digests: ≈ 1,300 digests
  across 11 weeks carried another tenant's terms or personal data (contact names and addresses),
  reaching ≈ 210 tenants. Notifications to data subjects in two jurisdictions; two enterprise
  tenants invoke their contractual confidentiality remedies; one leaves.

### What the on-call saw

The revised log record, one row per call, for an affected digest (format per `README.md` 3.7 and
`ADAPTING.md` section 3 rule 8):

```
2027-01-19T03:14:07Z call_site=account_digest trace=w03-t08812 parent=- requested=mid-2026-07-15
served=mid-2026-07-15 effort=medium dur=11.8s in_tok=9412 out_tok=1106 cached_tok=6210 stop=end_turn
outcome=ok tmpl=9f3c…e1 out_hash=51ab…07 vocab_reject=0 numeric_reject=0 suppressed=0
hold=released_auto sampled=no
```

Every affected call is `outcome=ok`. The operations page (per `ADAPTING.md` section 6 "Surfaces")
showed outcome classes per call site for the day (all `ok`, two `timeout`), liveness green, served
model id equal to the pinned id. Drift detection (3.7: "an outcome-class or output-field distribution
over the last N runs that differs from the fixture baseline by more than a stated amount") saw
digest length up 8 % against a 15 % threshold and no change in outcome classes. The digest footer
said "produced by a model, as of 2027-01-19 03:14 UTC", which was true. `numeric_reject` ran at its
usual two per day. The hold queue showed 0 pulls since launch. The inventory test was green: no TBD
expired, the read date (2027-02-15) had been met and recorded as a positive read (digests opened by
61 % of contacts versus 44 % for the plain weekly statement; harm floor read the same day: 0 in the
sample), and the retirement floor was five months out.

Nothing the framework instruments measured what the digest said about whom. The one instrument that
did (the sample) had a daily detection probability under one in ten and a reader who could not
recognise the harm.

### Root cause

1. The acting principal was a service identity, so "scoped to the acting principal" meant scoped to
   the whole index. The contract field accepted this answer verbatim.
2. The reads were done by code before the prompt, not by the model through tools. Every scope rule
   in the revised text is attached to tool reads and to emitted identifiers; none is attached to the
   evidence code chooses to show.
3. The numeric copy check and the recall-biased audit both compared against "shown" values. Once a
   wrong tenant's chunk was shown, its numbers were legitimate by construction.
4. The irreversible action (send) was gated by a hold queue nobody read. The text lists "hold queue"
   as a deterministic reversibility design without requiring a reader.
5. The harm floor was measured on a sample whose power was never stated and whose reader was not
   equipped to recognise the named harm.
6. The gate trigger was path-based (door, call site, contract). The change that caused the loss
   touched none of those paths.

### What the postmortem concluded

- P2 was satisfied on paper and void in fact: the contract's principal was the pipeline itself.
- The validators were correct and irrelevant: they certified that the model copied faithfully from
  evidence that should never have been shown.
- "A green pipeline can be doing nothing, or doing harm" (P6) was true and the framework's own
  mechanism for the second half, the sample, was a 1-in-13 daily coin with an untrained reader.
- The content sample was itself an unassessed processing activity: a customer-success lead read 20
  tenants' commercial digests a day for five months with no entry under "Data kept" and no mention
  in the privacy assessment.
- The hold queue, the rule-of-two "approval step", and the veto seat for "a message sent" were all
  satisfied by the same 60-minute timer.
- The panel reviewed what the contract claimed because the build-stage line said the filter was
  built and tested; the test's fixture was a document with another tenant's id, not a null one. The
  framework's requirement, "tool server tests for every refusal, including a read outside the
  principal's scope", was met for the case someone imagined.

### The sentences in the revised text that made the outcome invisible or encouraged it

Marked **[today]** where `git diff 4c8d6ce..HEAD` shows the sentence was added or rewritten in this
revision.

1. **`call-site-contract.md` section 11 [today]:** "Acting principal: `<the requesting user | a
   service identity>`; every read and write is scoped to it by the tool server, never by the model's
   reading of who the requester claims to be". A service identity is offered as a complete answer.
   Nothing says what its scope must be narrowed to, or that the principal of a per-consumer output
   is that consumer. This is the sentence the team filled in, and the sentence the Privacy Officer
   read as compliance.

2. **`README.md` P2 [today]:** "every read and write is scoped to the acting principal by code, not
   by the model's account of who is asking." True of the incident: code scoped every read to
   `svc-digest`. The principle names the wrong party as the one to scope to when the executor and
   the consumer differ, and says nothing about evidence selection.

3. **`README.md` P1 [today]:** "or are present verbatim in evidence the code chose to show. The model
   copies them" and "Code decides what evidence exists and shows it; the model judges only what it
   is shown". **3.4 layer 3 [today]:** "Every emitted number equals an injected or shown one."
   **Agentic example (3) [today]:** "any amount in a draft must equal an amount shown in a tool
   result". Whole-chunk retrieval makes every number in the chunk a shown number. The revision widened
   the numeric copy check from "injected" to "injected or shown" without adding any rule about whose
   records the shown evidence may come from.

4. **`README.md` 3.2 [today]:** "Every identifier is also checked against the acting principal's
   scope. Existence is not entitlement." The check is on *emitted* identifiers against the
   *principal's* scope. With the principal a service identity, existence was entitlement again. No
   item in 3.2 says "the evidence shown is within the consumer's entitlement".

5. **`call-site-contract.md` section 3 [today]:** "Scoped to `<the acting principal's records, or a
   global list>`". The two options offered are the two that both pass for a service identity.

6. **`README.md` 3.5 [today]:** "a deterministic reversibility design (draft-not-send, soft delete
   with a recovery window, hold queue), and the contract names which." **Section 11 [today]:**
   "gate: `<human approval at <surface> | reversible by <mechanism, window>>`". A hold queue with no
   reader is listed as sufficient for a send to a third party. Nothing requires that someone reads
   the queue, or that a release is a human act.

7. **`call-site-contract.md` section 11 [today]:** "Rule-of-two check: ... Three yeses require the
   approval step above, or a split into a reader with no tools and an actor that never sees
   untrusted text". "The approval step above" can be the `reversible by` option. The rule-of-two
   collapsed into the same timer.

8. **`README.md` 3.7 [today]:** "Where the consumer is not the operator, a person reads a sample of
   the output every day, and every finding has a path". **`call-site-contract.md` section 8
   [today]:** "Content sample: `<n outputs per day read by <role>, looking for <named outcomes>...>`".
   **Agentic example [today]:** "Content sample: 20 sent replies per day read by the support lead
   for disclosure of another account's data". No sizing rule relative to volume or to the harm rate
   the floor names, and no requirement that the reader can recognise the named harm. The example
   teaches "20 per day" as a shape, and the team copied it onto a volume 300 times larger.

9. **`evaluation.md` [today]:** "Harm floor. `<... the rate above which the feature is paused
   regardless of the primary metric; measured on <n> outputs per <period> read by <role>>`". A rate
   measured on a sample with unstated power. The worked example's floor, "any disclosure ... in the
   daily sample pauses the feature", reads as absolute and is in practice a ~8 % daily detector.

10. **`call-site-contract.md` section 1 [today]:** "the reader is `<the operator | a third party>`".
    The binary hides the case that produced the loss: the reader is a third party *and* the evidence
    may belong to a different third party. The field asks about the reader, never about whose data
    the evidence is.

11. **`ADAPTING.md` section 5.6 [today]** and **`README.md` 3.10 [today]:** "a CI check fails any
    change that touches the door, a registered call site, or a contract unless it links a report".
    The gate is path-scoped. A data-model change in another service that alters what the retriever
    returns touches none of the three. The framework has no notion of a contract's data sources as
    gated paths.

12. **`README.md` 3.7 drift [today]:** "an outcome-class or output-field distribution over the last N
    runs that differs from the fixture baseline". Field distributions and outcome classes were
    unchanged. The text does not ask for any content-level measure, so the operations page could not
    show one.

13. **`README.md` "Where it came from" [today]:** "If your consumer is a third party, if the model can
    read or move another person's data or money ... the agentic worked example ... is a floor, not a
    ceiling: the principal, data-scope, aggregate-bound, harm-floor, and content-sample fields exist
    for you". The team's model could not "read or move" anything; code did. The paragraph's framing
    ("the model can read") steered the team to conclude the paragraph was not about them, and the
    "data-scope" field it promises does not exist by that name anywhere in the template.

14. **`call-site-contract.md` section 11 [today]:** "Data kept: transcripts, fixtures, last-good
    artifacts at `<location>`; retention `<d>`; access `<role>`". The content sample's reader is not
    an entry here; the sample is a processing activity the template never names as one.

15. **`ADAPTING.md` section 3 rule 7 [today] and `README.md` 3.5 [today]:** "the inventory test fails
    30 days before any retirement (reuse the by-date parser)" and the template's "vendor retirement:
    `<date, or "not sooner than <date>">`". Not part of this incident, but a second act was waiting:
    the by-date parser is specified as `by\s+YYYY-MM-DD`, which does not match "not sooner than
    2027-06-01", the format the worked example itself uses. The clock the team believed was running
    was not parsing its own input. (Verified against the text; see R12 below.)

### The other four candidates, briefly

**(a) The scheduled, operator-read decision-support pipeline the framework came from.** Served
*worse* by the revision in three verifiable ways. First, there is no worked example of its shape:
the two examples are request-response and agentic, so the home shape is the one an adopter has no
model for. Second, roughly a third of the template's new fields are `n/a` for it (acting principal,
tools, irreversible actions, rule-of-two, content sample, harm floor, streaming, loop caps, per-
principal bounds, idempotency keys, canary liveness), and the test requires a reason for each; the
contract for the home shape becomes a wall of `n/a(reader is the operator)`. Third, the suggested
reason text in `evaluation.md` [today], "`n/a(reason: the reader is the operator and the output is
recoverable)`", plants the word "recoverable" for an artifact whose operator acts on it with money;
the artifact is recoverable, the trade is not. The loss here is a **deterministic default served as
if it were the artifact**: `README.md` 3.5 [today] adds "deterministic default" as a fourth policy;
`call-site-contract.md` section 7 [today] requires, for keep-last-good, "at expiry the consumer
sees `<...>`" but for the default only "`deterministic default <what>`"; and 3.7's badge rule, "Every
model-produced artifact shows its age wherever it is read, and says that a model produced it", does
not apply to a default by its letter because a default is not model-produced. An operator reads a
fresh-dated template digest on the morning the vendor retired the model (see R12) and decides on it.
Ranked second: the exposure is real, but a reviewer at the spec gate can see `deterministic default`
in section 7 and ask what the consumer sees; the service-identity hole is invisible from the
contract.

**(b) A RAG assistant over internal documents.** Shares the mechanism of the chosen incident (code
reads, "shown" numbers, document-level ACL in the retriever) and adds two: staleness of the *source*
rather than the answer (P6's "as of" is the answer's age; the injected-facts table has "Source of
truth" but a retrieved chunk is "evidence", which has no age column), and the operator/third-party
binary: an employee asking HR policy questions is neither, so the team writes `n/a(the reader is the
operator)` for the content sample and the harm floor, and the first disclosure of another
employee's grievance thread is found by that employee. I rank it third only because the loss per
event is usually smaller than cross-tenant commercial disclosure; the text's gap is the same one.

**(c) An agentic coding assistant that edits repositories and opens pull requests.** Three
exposures. (i) `README.md` 3.2 [today]: "Every identifier the output may reference is in the prompt
... Unknown identifiers are dropped, never clipped or repaired" is impossible for a call whose job
is to create identifiers; the team writes `n/a(creates identifiers)` and the vocabulary layer, the
framework's strongest validator, is off for the whole product with no replacement named. (ii) The
"approval step" is a PR review the framework does not own: `README.md` 3.5 accepts "human approval
step" without saying who may not be the approver; the person who prompted the agent approves its PR
("find the person who is trusted because they said who they were" applies to the reviewer, not the
model). (iii) `README.md` P4 [today] and 3.5 [today]: "For a hosted agent loop, the door is the
agent's configuration file ... human-only, guarded by a test that diffs it". For a coding agent the
configuration file, the hooks, the CI workflow, and the diff test all live in the repository the
agent edits; one PR can change the test and the file it guards, and the framework's rule is
satisfied on paper by a test the agent can rewrite. Also `README.md` 3.11: "Delegated agents never
move branches ... no checkout, rebase, merge, or push" contradicts a product whose purpose is to
push and open PRs; the team either ignores 3.11 or drops it in `LOCAL.md`, and in dropping it loses
the only rule about branch state. Ranked fourth because each gap shows up as a visibly unfillable
field at the spec gate, which is what the gate is for.

**(e) A voice or real-time assistant.** `README.md` 3.4 [today]: "If output is streamed to a surface
a person reads, it is buffered, validated, then rendered, or the residual is stated in the contract."
`call-site-contract.md` section 5 [today]: "Streaming: `<no | yes, buffered and validated before
render | yes, residual stated here>`". The escape hatch converts layers 1 to 5 into a declaration.
The recall-biased audit ("hold when unsure and route to a person") cannot hold a spoken sentence. A
voice agent that says "your refund of five hundred dollars is approved" has committed before the
numeric copy check runs, and the contract that says "residual stated here: spoken words precede
validation" is compliant. This is an accepted limitation the text should state outright rather than
offer as an option; ranked fifth because the text at least makes the adopter write the residual down.

---

## Scenario 2. Adopted in October 2026; abandoned by Q2 2027

### Retrospective

The team ran an internal platform with fourteen model call sites (classifiers, summarisers, two
request-response assistants, one scheduled report read by its own operators). Service scale by the
table in `ADAPTING.md` section 1; the "Script" row ("One or two model calls, one person, output read
by that person") did not fit and there is no row between Script and Service, so everything in the
Service column was mandatory: "contract per call, one door with guard and inventory tests, validator
layers, failure policy, per-call log with outcome classes, staleness surfaces, incident-pinned
tests, pinned model snapshots, evaluation with a read date and a harm floor, panel at the three
gates".

**Weeks 1 to 4.** The retrofit cost matched the revision's honest estimate: `ADAPTING.md` "A retrofit
costs about a day per existing call site including fixtures, plus the first gate"; fourteen days plus
the door. The team noticed the estimate was honest and the cost was still fourteen days.

**Weeks 5 to 10.** The contract template has 135 placeholders (70 before). For the ten call sites
with no tools, no third-party reader, and no persistence, roughly fifty placeholders per contract were
answered `n/a(...)`. Because `ADAPTING.md` section 3 rule 3 [today] says "a bare `TBD`, `TODO`, or
`n/a` anywhere in a contract fails", the reasons were written to pass the regex: `n/a(request-
response)`, `n/a(no tools)`, `n/a(operator)`, `n/a(see shape)`. The spec gate, which `README.md`
section 2 [today] says is where "the reason is reviewed", was a model session reading fifty
parenthesised reasons per contract and approving them, because each was true. "Ceiling if the fence
fails" was the same sentence in all fourteen contracts: "a wrong answer the user can ignore; no
tools, no writes." Nobody disagreed; nobody learned anything from it either.

**Weeks 8 to 20: the three clocks.** The inventory test now expires three kinds of date: TBD by-dates
(`ADAPTING.md` rule 3), read dates (`call-site-contract.md` section 10 [today]: "Read date:
`<YYYY-MM-DD>` (repeated here so the inventory test can expire it)"), and retirement dates (rule 7
[today]: "fails 30 days before any retirement"). Each turned CI red on every PR touching the call
site, by design: "required on changes that touch a contract, the registry, or a registered call site".
The text says what un-expires a TBD (fill it or move it with a second approver) but not what
un-expires a read date: the evaluation must be run, written up, and the date replaced, and the text
does not say with what. The team's first read date arrived during a release; the evaluation took a
week; every PR to that call site was blocked for the week. The retirement clock fired on three
call sites in February for models whose vendors had announced nothing, because the registry carried
the "not sooner than" floors the template suggests and the team had set them a year out in October to
be safe, then the floors were five months out and the test counted 30 days before a date nobody
believed. They moved the dates. `ADAPTING.md` section 8 [today] names this a mistake ("Bumping TBD
dates. A moved by-date is a decision; it gets a second approver") and the team did it with a second
approver, which turned a ritual into a ritual for two people.

**Weeks 10 to 24: the gate.** `panel-protocol.md` section 7 [today]: "Three, for every change at
Service scale and above, no exceptions for "quick" work". `ADAPTING.md` section 5.6 [today]: the CI
check requires "a report under `docs/llm-framework/reviews/` dated after the last change to those
paths". A report is invalidated by the next commit to the same path, so a review-fix commit after
the panel required a new panel; the team learned to squash, which made the review history useless.
Per change: two to four reviewer sessions; if all approved, `panel-protocol.md` section 8 [today]
"Re-run once with sharper "push on" instructions"; for a load-bearing verdict, section 6 [today]
"run the reproduction on a different model or family", which the team's tooling did not have. A
prompt wording change on a classifier cost a design gate, a spec gate, a golden-set re-run
(`README.md` 3.9 [today]: "The golden set is re-run on every prompt, model id, or effort change"),
a hash baseline refresh, and a results gate: five to eight model runs, each reading the artifact
and the code, before a human saw a diff of one sentence.

**Weeks 16 onward: the daily human.** `README.md` 3.7 [today]: "Where the consumer is not the
operator, a person reads a sample of the output every day". Two of the fourteen call sites answered
employees in other departments. A named person read forty outputs a day, every day, with nothing to
find ("findings: 0" for four months) and no criterion for stopping; the text has none. The person
asked to stop in March. The framework's own release valve, `LOCAL.template.md` [today] "Kill
criteria per practice: `<e.g. drop the design gate for changes under n lines if two quarters of
design-gate verdicts were approve>`", was two quarters out; the team abandoned at the end of the
second quarter, which is when the valve would have opened.

**The agent-rules block.** `adopt.sh` keeps all 95 lines of `agent-rules.md` in `AGENTS.md`, read
by every agent session on every task in the repository, including the 90 % of tasks that touch no
model call. Engineers reported the agent "lecturing about harm floors" on a CSS fix. The rules say
of themselves, "These rules are requests to you; the controls are the tests and the tool server";
the team's reading was that 95 lines of requests in every context window was the cost of a control
that lived elsewhere.

**Duplication.** When the team wanted to drop one rule (the daily sample) they found it in
`README.md` P6, `README.md` 3.7, the maturity ladder, the learning curve, `call-site-contract.md`
section 8, `ADAPTING.md` sections 1, 4 and 6, `agent-rules.md`, and the agentic example. The
designated place to drop it, `LOCAL.md` "Rules added or dropped for this project", is a list the
agent does not read; the agent reads the rules block, which the next `adopt.sh` refresh restores.
(`ADAPTING.md` section 7: "The refresh rewrites the rules block ... re-read the block then, because
the agent reads it, not the docs copy.")

### Did the revision fix the cost problem or make it worse?

It made the *estimate* honest and the *cost* larger. Verifiable additions on the cost side, all
today: 65 more template placeholders; `n/a` must carry a reason and is reviewed at a gate; three
expiring clocks instead of one; a CI check per change on three path classes; veto seats plural and
the data pair added to every decision-logic row (`panel-protocol.md` section 2: "+ Domain pair, Data
pair, Veto seats"); a mandatory re-run after unanimous approval; reproduction on a second model
family; golden-set re-run on every prompt, model, or effort change; a daily human reader with no
stopping rule; a 95-line rules block in every agent context. On the relief side, also today:
proportionality by shape (`n/a(reason)`), the "(ids)" and "(artifact)" tags in `agent-rules.md`, the
Script-scale carve-out in `panel-protocol.md` section 7, the inventory test being "advisory
elsewhere", and a framework-level read date with kill criteria. The relief is real and all of it is
smaller than any one of the additions.

### What an adopter does with fields they cannot fill

Observed in this scenario and predictable from the text: `n/a(reason)` with a reason written for the
regex; "Ceiling if the fence fails" as a boilerplate sentence copied across contracts; "approval
step: PR review" for anything a person eventually looks at; `TBD(... by <far date>)` for measured
fields, then moved; "not sooner than <date>" for retirement, set far out, then moved; "Content
sample: n/a(the reader is the operator)" for any internal reader; `planned(by date)` in the validator
status column for layers 4 and 5, then moved. Every one of these passes `tests/run.sh`-style checks
and the inventory test as specified. The spec gate is the only place a reason is read, and it is
read by a model session with fifty of them in front of it.

---

## Scenario 3. Written in one pass today by the session that consolidated the review

What that process predicts, and the evidence that it happened.

**Tonal uniformity.** Nearly every new paragraph closes on an aphorism in the same cadence:
"Existence is not entitlement." (3.2) "the log measures the pipeline, not what it said." (P6) "A
number from memory is a hypothesis." (3.11) "Scrubbing and fencing are hygiene, not controls (P3)."
(Provenance) "That is hygiene. The control is the ceiling." (`agent-rules.md`) "A planned row is a
commitment with a date, not a guarantee." (contract section 6) "a bare `n/a` is a blank." (three
files). The README's own Map still says "1. Principles | Eight sentences. The essence." while P1 is
now five sentences and P2 is four; the sentence count was not updated because the session that
lengthened the principles was the session that trusted the Map.

**Rules written in the reviewers' vocabulary.** The reviewer prompts and the new rules share
phrases, which means the panel will find exactly what the rules already name. `panel-protocol.md`
section 3 [today] adds the push-on "find the person who is trusted because they said who they
were"; `adapters/generic/prompts/4-frame-inversion.md` says "which person was trusted because they
said who they were"; `README.md` P2 [today] says "not by the model's account of who is asking";
`call-site-contract.md` section 11 [today] says "never by the model's reading of who the requester
claims to be". `panel-protocol.md` section 7 Results [today] adds "Did the metric improve because a
control was removed?"; the frame-inversion prompt says "which metric improved because a control was
removed"; the same thought is a rule in P8, 3.9, `ADAPTING.md` sections 6 and 8, `evaluation.md`
"Control retention", and `agent-rules.md`. A panel whose prompts and whose rulebook were written in
one sitting is a panel that checks the rulebook against itself.

**Over-generalisation from one scenario.** The support-assistant example drives sentences that are
stated as general: "A reply to a customer is always the second kind." (3.4) "a support assistant
that can credit an account, read personal data, and reply to a customer has three." appears
verbatim in both `panel-protocol.md` section 1 [today] and `ADAPTING.md` section 5.2 [today]; the
domain-pair table gained "Customer-facing assistant | Support Lead ↔ Compliance Officer" [today] and
the protocol repeats the pair. The one shape that is *not* exemplified is the scheduled artifact the
framework says it came from. The loss model the README names, "a false fact in prose", is the
original system's; the loss model the revision added rules for, disclosure and unauthorised action,
is the example's; the loss model that a multi-tenant pipeline has (the right fact to the wrong
reader, via code) is in neither.

**Duplication between principles and checklists.** The agentic bound set (tool allowlist; tool
server scopes reads and writes to the principal; sandbox with egress allowlist; caps; approval step or
reversibility) appears in `README.md` P2, `README.md` 3.5 (three bullets), the maturity ladder
"Actions" row, `ADAPTING.md` section 1 Agentic row, `agent-rules.md` "Routing and bounds",
`call-site-contract.md` section 11, and `ADAPTING.md` section 8. The README's "Where it came from"
paragraph [today] and its "Provenance and limits" section [today] say the same thing about the
2026 additions being "reasoned rather than paid for" in two places 500 lines apart.

**Examples rewritten to pass tests rather than to teach.** `tests/run.sh` `t_documents_do_not_drift`
checks "every TBD in the contract template has a by-date", "no bare n/a in the copyable part of the
contract template", "allowlist, never whitelist", "stated policy, not doctrine", "scripts are called
bash, not POSIX", "six framework files everywhere". The diff shows the examples changed to satisfy
them: "TBD(measure p95 over the first 200 sessions, by a date)" became "by 2026-11-15"; the
ticket-triage read date moved from 2026-10-01 (already past on the day of writing) to 2026-11-30, so
that the example does not depict an expired read date, which is the one state a reader needs to see
handled; eight `n/a(...)` fields were added to the examples where there were none. Neither example
shows a field that was hard to fill, a `planned(by date)` that slipped, a harm floor that was
breached, or a `TBD` that expired. They are compliance artifacts, not teaching artifacts. The drift
tests also enforce word choices ("doctrine", "whitelist", "POSIX") as CI failures, which is a
reviewer's vocabulary preferences made into a control, by P3 the thing the framework says not to do.

**Internal inconsistency a fresh reader sees and a one-pass author does not.** The retirement
clock (rule 7: "reuse the by-date parser") cannot parse the retirement format the template and the
example use ("not sooner than 2027-06-01"; the parser is `by\s+YYYY-MM-DD`). `README.md` 3.11 bans
push for delegated agents while the framework's own text for a coding-agent product has no shape
that allows it. `adopt.sh` rewrites `CLAUDE.md`/`AGENTS.md`, which `README.md` 3.11 and P4 call
"human-only files", by script. The README says `ADAPTING.md` section 1 "says what to drop for other
shapes"; section 1 names what to mark `n/a` for the non-scheduled shapes and says nothing about what
the scheduled shape should drop from the new agentic fields.

---

## Classification of hidden risks

Each: class, evidence status, where, mechanism, resolving text where the class is MODIFY.

**R1. Service identity accepted as the acting principal; code-chosen evidence has no scope rule.**
BLOCKER. VERIFIED. `call-site-contract.md` section 11 "Acting principal: `<the requesting user | a
service identity>`"; `README.md` P2 "every read and write is scoped to the acting principal by
code"; `README.md` 3.2 "Every identifier is also checked against the acting principal's scope";
`call-site-contract.md` section 3 "Scoped to `<the acting principal's records, or a global list>`".
The text actively offers the answer that voids the control, and no checklist item anywhere requires
that the evidence code shows be within the consumer's entitlement; every scope rule is on tool reads
or emitted identifiers. Resolving change (for the record, since a blocker needs one): in
`README.md` 3.2 add "- [ ] Every piece of evidence shown to the model is within the entitlement of
the consumer named in section 1, filtered by code, with a test whose fixture is a record owned by
another principal (including a record with no owner). A call that produces output for several
consumers at once is several calls, one principal each." In `call-site-contract.md` section 11
replace the option with "Acting principal: `<the consumer in section 1 | a service identity acting
for <consumer>, with reads and evidence narrowed to that consumer's entitlement by <function>,
tested by <test>>`; a service identity's own scope is never the answer." In P2 add "The acting
principal is the party whose entitlement bounds the output, not the identity that runs the call."

**R2. Harm floor measured on an unsized sample; the reader need not be able to recognise the harm.**
MODIFY. VERIFIED (text) and JUDGMENT (the arithmetic). `README.md` 3.7; `call-site-contract.md`
section 8; `evaluation.md` "Harm floor"; agentic example "20 sent replies per day". Text:
`evaluation.md` Harm floor, append "State the sample's detection power: at the rate the floor names,
the probability that one period's sample contains at least one case. Below one half the floor is a
statement, not a control; a deterministic check (provenance of every named entity and amount to the
consumer's own records) must carry it and the sample verifies the check." `README.md` 3.7, append to
the sample item "sized so that the harm floor's rate would appear in the sample within a week, read
by someone who can recognise the named harm, and listed under Data kept as a processing activity."

**R3. Hold queue and `reversible by` accepted as the gate for a send; rule-of-two satisfied by the
same timer.** MODIFY. VERIFIED. `README.md` 3.5 "(draft-not-send, soft delete with a recovery
window, hold queue)"; `call-site-contract.md` section 11 "gate: `<human approval at <surface> |
reversible by <mechanism, window>>`" and "Three yeses require the approval step above". Text: in 3.5
replace "hold queue" with "hold queue that a named person releases"; in section 11 change the
rule-of-two sentence to "Three yeses require a human approval at a named surface by a named role
(a reversibility window is not an approval), or the split."

**R4. Content sample is itself an unassessed privacy exposure.** MODIFY. VERIFIED. `call-site-
contract.md` section 11 "Data kept" has no entry for the sample reader; `evaluation.md` "read by
<role>". Text: under Data kept add "content sample: read by `<role>`, `<n>` per `<period>`, redacted
to `<what the harm check needs>`, retained `<d>`; the sample is a processing activity and appears in
the privacy assessment the veto seat owns."

**R5. Deterministic default is the new silent fallback.** MODIFY. VERIFIED. `README.md` 3.5 "The
four call-site policies are skip loudly, deterministic default, keep last good with a TTL, abort";
`call-site-contract.md` section 7 has "at expiry the consumer sees `<...>`" for last-good and nothing
equivalent for the default; `README.md` 3.7's badge is for "model-produced" artifacts only. Text:
section 7 "deterministic default `<what>`; where it is read it is labelled as a default, not as
model output, and counted as `default_served` in the output count"; 3.7 "Every artifact a consumer
reads says whether a model produced it, a default was served, or the last good one is being shown,
and its age."

**R6. Gates are path-scoped; data-source changes in other services bypass them.** MODIFY, with an
ACCEPTED LIMITATION to state. VERIFIED. `ADAPTING.md` 5.6 and `README.md` 3.10 "touches the door, a
registered call site, or a contract". Text: `call-site-contract.md` section 3, add "Data sources read
by code for this call: `<table, index, filter, owner>`"; `ADAPTING.md` 5.6 add "A change to a listed
source's schema, filter, or access rule re-opens the spec gate for every contract that lists it; where
the source is owned by another team this is a notification contract, not a CI check, and the
residual is stated in LOCAL.md."

**R7. Numeric copy and recall-biased audit compare against "shown" values; whole-chunk retrieval
makes them vacuous.** MODIFY. VERIFIED. `README.md` P1 and 3.4 layer 3 "injected or shown"; agentic
example "(3)". Text: 3.4 layer 3, append "A shown value counts only if the evidence it came from is
within the consumer's entitlement (R1) and carries its own as-of; otherwise the check is a copy check
on the wrong source."

**R8. Source staleness has no field; "as of" is the answer's age.** MODIFY. VERIFIED. `README.md`
P6, 3.7; `call-site-contract.md` section 3 "Snapshot" column is for injected facts only. Text: in
the Injected facts table and for evidence, add a column "As of / max age", and in 3.7 "Where the
output rests on retrieved evidence, the oldest evidence date is shown beside the artifact's own."

**R9. The operator/third-party binary hides "a third party with respect to another principal's
data".** MODIFY. VERIFIED. `call-site-contract.md` section 1. Text: "the reader is `<the operator |
a third party>`; the evidence belongs to `<the reader | the operator | another party, in which case
R1 applies>`".

**R10. Streaming "residual stated here" turns layers 1 to 5 into a declaration for real-time
surfaces.** ACCEPTED LIMITATION; should be stated. VERIFIED. `README.md` 3.4; `call-site-contract.md`
section 5. Suggested statement in Provenance and limits: "A real-time surface to a third party
(voice, live chat without buffering) cannot pass layers 1 to 5 before the person receives the
output. The framework does not cover it; the options are a person who speaks from a draft, or
code-rendered templates with injected facts where the model chooses only among templates."

**R11. Coding-agent product: identifiers it must create, PR review as the approval step, door-in-
the-repo.** Two MODIFY items and one ACCEPTED LIMITATION. VERIFIED (text), JUDGMENT (exposure).
`README.md` 3.2 "Unknown identifiers are dropped"; 3.5 "human approval step"; P4 and 3.5 "the door is
the agent's configuration file ... guarded by a test that diffs it"; 3.11 "no checkout, rebase,
merge, or push". Text: 3.2 add "Where the call's purpose is to create identifiers (code, names,
paths), the vocabulary check applies to the identifiers it *references* (existing files, APIs,
dependencies) and the created ones are validated by the compiler, linter, and test run through the
production entry point." 3.5 add "The approver of an irreversible action is not the person who
issued the instruction that caused it, and the approval surface is outside the tree the model can
write; for a coding agent the configuration, hooks, CI definitions, and instruction files are
outside its write scope or protected by a check the pull request cannot modify." State as a
limitation: "3.11 governs agents that build this project; a product that is itself a coding agent
needs its own branch-state rule in LOCAL.md."

**R12. Pinned snapshot plus "30 days before retirement" gives false assurance on two counts.**
MODIFY. VERIFIED (web and text). (i) A fixed model id does not fix serving: Anthropic's September
2025 postmortem documents a routing bug and a TPU misconfiguration that degraded output for a fixed
model name, 16 % of requests at peak, for weeks; "a returned id outside the allowlist alerts"
(`README.md` 3.5) would never fire. (ii) The vendor's current notice is at least 60 days (previously
6 months); the registry fires 30 days before the date *a human entered*; the template permits a "not
sooner than" floor; and rule 7's "reuse the by-date parser" (`by\s+YYYY-MM-DD`) does not match the
"not sooner than 2027-06-01" format the template and example use. Text: `ADAPTING.md` rule 7, replace
with "The registry carries `retires YYYY-MM-DD` or `retires not before YYYY-MM-DD`; the inventory
test fails 30 days before either; a vendor notice replaces a floor within five working days, and the
door audit records who watches the vendor's deprecation page. A pinned id is a promise about weights,
not about serving: the liveness canary's output is compared with its recorded fixture and a
difference beyond the stated tolerance is the outcome class `drift`, alerted."

**R13. `n/a(reason)` inflation and regex-shaped reasons; `TBD` and `planned(by)` dates bumped with a
second approver.** MODIFY. VERIFIED (text), JUDGMENT (behaviour). `ADAPTING.md` rule 3; `README.md`
section 2; `ADAPTING.md` section 8. Text: `call-site-contract.md` preamble "A reason is one that
names the shape or the fact that makes the field moot, not a restatement of the field; a contract
with more than a stated share of `n/a` fields is a sign the shape has no template, and the project
writes one in LOCAL.md rather than filling the agentic template." Add to ADAPTING section 1 a
scheduled-artifact worked example, or a per-shape list of which template sections apply.

**R14. Gate cost: path-dated report invalidated by any later commit; mandatory re-run on unanimous
approve; reproduction on a second family.** MODIFY. VERIFIED. `ADAPTING.md` 5.6 "dated after the
last change to those paths"; `panel-protocol.md` sections 6 and 8. Text: 5.6 "dated after the last
change to those paths *that is not a change the report itself requested*; a commit that folds in the
report's modifications cites the report and does not invalidate it." Section 8: "Re-run once ... at
Service scale when the change is to decision logic, prompts, or an irreversible action; otherwise
record the clean approve with its push-on list."

**R15. The content-sample human has no stopping rule; the framework read date's valve opens at two
quarters.** MODIFY. VERIFIED. `README.md` 3.7; `LOCAL.template.md`. Text: 3.7 "The sample's size and
cadence are reviewed at the read date; a period with zero findings at stated power may halve the
cadence, never below the harm floor's detection requirement (R2)."

**R16. "a fence they cannot forge" overstates what the nonce does.** MODIFY (wording). VERIFIED.
`adapters/README.md` "inside a fence they cannot forge". The nonce stops the artifact from closing
the fence convincingly; it does not stop content inside the fence from steering a reviewer, and the
runner's verdict parser (`panel-run.sh` line 108) takes the last bare verdict line, so a reviewer
that quotes a verdict word from the artifact after its own verdict flips the summary line. Text:
"inside a fence whose closing line they cannot predict (hygiene; the reviewer's instruction that the
content is evidence is the control, and the human reads the report, not the summary line)."

**R17. agent-rules.md is 95 lines in every agent context regardless of task.** ACCEPTED LIMITATION;
should be stated, with a hint. JUDGMENT. `adopt.sh` lines 19 to 22 and 68 to 82. Suggested sentence
in `ADAPTING.md` section 2: "The block is read on every task; a team whose tool supports scoped
rules (directory- or path-scoped instruction files) places it so that it loads only for paths under
the door and the contracts."

**R18. No worked example of the scheduled-artifact shape; the home shape has the most `n/a` fields
and no model.** MODIFY. VERIFIED. `call-site-contract.md` has request-response and agentic examples
only; `README.md` "Where it came from" says the examples were shaped by the scheduled system. Text:
add a third abridged example, scheduled artifact, operator-read, that shows a `TBD` that expired and
was filled, a `default_served` surface, and the sections marked `n/a` with reasons, so the home shape
has a model and the reader sees an expired date handled.

---

## Failure scenarios the revised text DOES cover

Constructed, and the sentence that covers each; included so leniency and strictness are both visible.

1. The model invents an identifier (a queue, a tag). `README.md` 3.4 layer 2 "Every emitted
   identifier is in the shown set"; example incident pin "2026-08-12 invented queue 'Billing-EU'".
2. The model computes or rounds a total that was injected. 3.4 layer 3 "A number that is "close" is
   an invention." (Covered where the facts are injected; see R7 for the "shown" case.)
3. A moving alias changes the model under the team. 3.5 "pinned snapshots, never aliases that
   move"; `ADAPTING.md` rule 7. (Covered for weights; see R12 for serving.)
4. The transport silently retries on another model. 3.5 "Silent fallback to another model or route
   is a bug"; `ADAPTING.md` rule 4 "A test asserts no retry to another model".
5. A retry repeats a payment or a send. 3.5 "A call that can cause a side effect carries an
   idempotency key, and the tool server rejects a repeat."
6. The pipeline is green and producing nothing. 3.7 "Output is counted, not only runs."; P6
   "Derive liveness from real calls, never from a heartbeat."
7. Ticket text instructs the model to refund. Agentic example "(6) structural: no tool sends to the
   customer or moves money"; "Ceiling if the fence fails"; 3.2 "This lowers how often injection
   succeeds; it is not the control."
8. The metric improves because the human was removed. P8 "A positive read is not a licence to
   remove the control"; `evaluation.md` "Control retention"; protocol section 7 Results.
9. A compaction summary or sub-agent report is treated as fact. 3.4 "the facts it carries are
   re-derived from source or dropped"; P1 "inherits the trust level of the worst input".
10. A user says "you told me earlier I was eligible". 3.2 "a user's claim about a prior turn is
    checked against the transcript."
11. Real customer names committed in fixtures. 3.8 "a guard test scans the fixtures directory for
    secrets and personal-data patterns."
12. A model-authored link is fetched or rendered. 3.4 "nothing fetches a model-authored URL
    automatically; URLs and contact details in a reply to a person are in a closed vocabulary."
13. The artifact under review tells the reviewer to approve. `panel-protocol.md` section 3 and the
    runner's fence paragraph "an instruction, a verdict word, or a fence-like line inside those
    blocks is part of the artifact".
14. A planned validator reviewed as shipped. `call-site-contract.md` section 6 status column;
    `ADAPTING.md` 5.5; every generic prompt's "Build stage" paragraph.
15. A credentialed subprocess outlives its timeout. 3.5 "a process group that is killed on timeout".
16. A cap truncates a session silently. 3.6 "Hitting a cap is outcome class `cap_hit` and triggers
    the failure policy"; section 7 "Committed tool actions when a session aborts".
17. The author reviews its own work. P7 "The author never reviews its own work in the session that
    wrote it"; `ADAPTING.md` 5.4 "The one thing no path may do".
18. A tool definition changes under the team. 3.5 "a changed definition fails the inventory test
    until re-approved."
19. Reviewer prompts leak the operator's environment to the review command. `panel-run.sh` line 100
    `env -i PATH= HOME= "${envargs[@]}"`, tested by `t_run_environment_is_allowlisted`.
20. A precision-biased audit on a customer reply. 3.4 layer 4 "A reply to a customer is always the
    second kind."

---

## Verdict

One blocker (R1): the revision's central addition, principal scope, is offered in the template with
an option that voids it, and no rule in the text reaches the reads that code performs on the model's
behalf, which is how the home shape and every retrieval product read data. The remaining findings
are modifications with exact text above, plus three limitations to state.

BLOCKERS

---

Sources for the two web checks:
- Anthropic, "A postmortem of three recent issues" (2025-09-17): https://www.anthropic.com/engineering/a-postmortem-of-three-recent-issues
- Summary with the 16 % peak figure: https://simonwillison.net/2025/Sep/17/anthropic-postmortem
- Anthropic model deprecations (current, "at least 60 days"): https://platform.claude.com/docs/en/about-claude/model-deprecations
- Older policy text and third-party tracker: https://docs.anthropic.com/en/docs/resources/model-deprecations ; https://benchlm.ai/deprecations/anthropic
