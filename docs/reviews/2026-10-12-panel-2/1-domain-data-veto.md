# Panel 2, session 1: Domain pair, Data pair, Veto seat

Artifact: LLM Practice Framework, branch `panel-2026-10-12` at HEAD f0c0a9b, against base 4c8d6ce.
Gate: spec gate on the revision (merge and publish decision). Build stage: documents are
specifications an adopter builds to; the four bash scripts and `tests/run.sh` are shipped code.
Reviewed: 2026-10-12.

Seats: LLM Production Engineer <-> Methodology Skeptic (domain pair); ML Engineer <-> Data Engineer
(data pair); Adopter's Time and Credibility Advocate (veto).

Order of work followed: all revised files were read in full and Part 1 below was written before
`docs/reviews/2026-10-12-panel/0-consolidated.md` was opened. Part 2 (closure of the first panel's
items) was written after.

Evidence basis: `README.md`, `call-site-contract.md`, `ADAPTING.md`, `agent-rules.md`,
`evaluation.md`, `LOCAL.template.md`, `panel-protocol.md`, `adapters/README.md`,
`adapters/claude-code/skill-header.md`, `adapters/generic/prompts/*.md`, the four scripts,
`tests/run.sh`; `git diff 4c8d6ce..HEAD` on every document; `tests/run.sh` executed (108 checks, 0
failed, exit 0); vendor documentation fetched on 2026-10-12 from Anthropic (prompt caching,
structured outputs, model deprecations, models overview, batch processing), OpenAI (prompt caching,
structured outputs, deprecations, batch) and Google (Gemini models, deprecations, caching API).

---

# Part 1. Independent assessment of the revision as it stands

## 1.1 What the revision is

The base (4c8d6ce) was a scheduled-pipeline practice written up as a general framework. The
revision adds a shape vocabulary (scheduled artifact, request-response, conversation, agentic
session), a bounding principle (P2), an Actions row on the ladder, a second worked example (agentic
support session), the `n/a(reason)` convention, pinned snapshots with retirement dates, cache
layout, structured-output residuals, batch tier, nine outcome classes, four failure policies, a
daily content sample, harm floor and control retention in the evaluation, judge discipline, a
rule-of-two check, and data-handling fields. README grew 350 -> 538 lines; the copyable contract
template grew from 66 to 120 backticked placeholders (counted with `grep -o` over the section
between the first `---` and `## Worked example`, base vs head).

## 1.2 Vendor-neutrality and correctness of the 2026 additions (push-on A)

Checked against three vendors' current documentation. Summary table, then findings.

| Claim in the revision | Anthropic | OpenAI | Google | Status |
|---|---|---|---|---|
| Caching rewards a byte-stable static prefix | "Cache hits require 100% identical prompt segments" | "Cache reuse requires the entire rendered prefix to match" | implicit caching: "putting large and common contents at the beginning of your prompt" | VERIFIED, universal |
| A breakpoint sits at the end of the static prefix | explicit `cache_control` breakpoints, or one automatic top-level marker; "one cache breakpoint at the end of your static content" | automatic by default; explicit `prompt_cache_breakpoint` only on GPT-5.6+ | explicit caching is a `CachedContent` resource with a `ttl`, referenced by name; no breakpoint concept | VERIFIED as Anthropic/OpenAI-explicit vocabulary; NOT universal |
| An effort change invalidates the cache | "Changing the `output_config.effort` value always invalidates message blocks", tools/system "model-specific" | `reasoning.effort` is listed among settings that change the rendered prefix and so prevent reuse | not documented (Gemini uses thinking level/budget) | VERIFIED for both major vendors; slightly overstated (Anthropic: system/tools cache may survive) |
| API-enforced structured output leaves refusals, truncation, unenforced constraints | `stop_reason: "refusal"`; `stop_reason: "max_tokens"` "may not match your schema"; numeric and string constraints "not supported" | `refusal` field; `incomplete` with `max_output_tokens`; a supported-schemas subset | n/a (not checked) | VERIFIED, both vendors |
| Vendor aliases can move while dated snapshots do not | "Every Claude model ID is a pinned snapshot, including the dateless IDs used from the 4.6 generation on"; pre-4.6 aliases resolve to dated IDs | alias-to-snapshot mappings listed (e.g. `gpt-4-turbo` -> `gpt-4-turbo-2024-04-09`) | `-latest` is "hot-swapped with every new release"; stable models "usually don't change" | VERIFIED in substance; "dated" is one vendor's convention; Google's "stable" is weaker than "do not move" |
| Retirements come with notice | "at least 60 days' notice"; "not sooner than" dates published for active models | GA models "at least 6 months", specialized "3 months", preview "such as 2 weeks" | "advance notice"; many models "No shutdown date announced"; preview "at least 2 weeks" | VERIFIED; notice ranges from 2 weeks to 6 months; a retirement date is NOT published in advance for active models at two of three vendors |
| Batch tiers are cheaper for non-interactive work | "50% of the standard API prices"; most batches under 1 hour; "expire if processing does not complete within 24 hours" | "50% cost discount"; 24-hour window; unfinished requests are cancelled at expiry | not checked | VERIFIED; both carry a 24-hour window and a partial-expiry outcome |

**Finding A1 (Production Engineer). "Cache breakpoint" stated as universal.**
Where: `README.md:215-216` ("the cache breakpoint sits at its end, and cached-read tokens are
logged"); `call-site-contract.md:73` ("breakpoint after `<section>`"); `README.md:510` (PR
checklist). Why: an OpenAI adopter on most models has no breakpoint to place; a Gemini adopter using
explicit caching creates a cache resource instead. The checklist box is unanswerable for them.
Resolve: README 3.3 bullet: "The static prefix is byte-stable across calls (no timestamps, no
per-run ids); where the vendor requires a cache marker it sits at the end of that prefix, and where
caching is automatic the prefix is still kept first and unchanged; cached-read tokens are logged
under whatever field the vendor returns." Contract line 73: "Cache: static prefix = `<sections>`;
mechanism `<marker at end of prefix | automatic prefix cache | explicit cache resource, TTL <h>>`;
cached-read tokens logged: yes". VERIFIED (three vendor pages quoted above).

**Finding A2 (Production Engineer). "Dated snapshot" is one vendor's convention.**
Where: `ADAPTING.md:132-133` ("The registry names a dated snapshot, never an alias that moves").
README 3.5 (`README.md:276`) and the contract (`call-site-contract.md:64`) say "pinned snapshot",
which is correct. Why: Anthropic's current IDs (`claude-sonnet-5-5`) are dateless and documented as
pinned snapshots; an adopter following ADAPTING literally will look for a dated form that does not
exist. Resolve: "The registry names an id the vendor documents as a fixed snapshot (dated where the
vendor dates them), never one documented as moving (`-latest`, a bare family alias, a 'stable'
pointer the vendor says it may hot-swap)." VERIFIED (Anthropic models overview, Google models page).

**Finding A3 (Production Engineer). Retirement date is assumed to exist.**
Where: `README.md:276-278` ("Each carries its vendor retirement date, and the inventory test fails
30 days before it"); `call-site-contract.md:64-65` offers `<date, or "not sooner than <date>">`;
`ADAPTING.md:133-134`. Why: OpenAI and Google publish no date for active models; the field has no
honest value, so adopters will invent one or write a bare TBD. Also, a vendor giving two weeks'
notice (preview models at two vendors) cannot satisfy a 30-day pre-alarm; the rule should push
adopters off preview ids rather than pretend the alarm works. Resolve: contract line 64-65: "vendor
retirement: `<date | "not sooner than <date>" | none published, lifecycle page checked on <date>>`";
README 3.5 bullet add: "Where the vendor publishes no date, the registry carries the date the
lifecycle page was last checked and the inventory test fails when that is older than 90 days;
preview or experimental ids, which vendors retire on two weeks' notice, are not pinned in
production." VERIFIED (deprecation pages, three vendors).

**Finding A4 (Production Engineer). Batch stated as an unconditional MUST.**
Where: `README.md:321` ("Non-interactive work goes to the batch tier where one exists, and the
contract names the tier"). Why: both vendors' batch tiers carry a 24-hour completion window and an
`expired` outcome for unfinished requests. A scheduled artifact due at 07:00 is non-interactive and
cannot promise the batch window; the outcome-class list has no class for a batch request that
expired (is it `timeout` or `cancelled`?). Resolve: "Non-interactive work whose deadline tolerates
the vendor's batch window (24 hours at the vendors checked) goes to the batch tier; the contract
names the tier and maps a request that expires unprocessed to `cancelled`." VERIFIED (both batch
pages).

**Finding A5 (Skeptic). Effort/cache sentence is slightly stronger than the evidence.**
Where: `README.md:322-323` ("Effort is changed between workloads, not within a conversation,
because a change invalidates the cache"). Why: true for the conversation prefix at both vendors;
Anthropic says the system and tool cache survive on some models. Minor. Resolve: "...because both
major vendors render effort into the prompt, so a change is a cache miss on at least the
conversation." VERIFIED.

**Sound (checked, no change needed):** structured-output residuals (`README.md:217-219`,
`agent-rules.md:20-21`, `call-site-contract.md:89-90`) match both vendors' documented caveats
exactly; "vendor defaults differ per model and move" (`README.md:225`) matches Anthropic's per-model
default effort table; "batch ... cheaper" matches 50% at both vendors; the "served model id" rule is
vendor-neutral; the framework never quotes a price, a TTL, or a token minimum, which is the right
call for a document that will outlive this quarter's numbers.

## 1.3 Over-correction toward a customer-facing agentic product (push-on B)

The question is whether new unconditional MUSTs are wrong or wasteful for (a) a Script-scale
project, (b) a scheduled batch pipeline, (c) an agentic coding tool.

**Finding B1 (Skeptic, Veto). `agent-rules.md` applies every rule at every scale; the preamble
exempts only the panel.**
Where: `agent-rules.md:5-6` ("At Script scale the panel is one separate reviewer session, not three
gates"); the Script row of `ADAPTING.md:23` makes registry, throttle, evaluation file and full panel
optional, and by omission everything not in its Mandatory cell. But the rules file is what the
coding agent reads, and it says, unconditionally: guard test and inventory test (`:43-44`), pinned
snapshots with retirement dates (`:45-46`), idempotency keys (`:48`), nine outcome classes and
served model id (`:65-67`), pre-registered golden set and harm floor (`:76-78`). A Script-scale
adopter's agent will build a door, a registry and an evaluation file for a two-call script, or
ignore the file. Resolve: preamble sentence: "At Script scale only the Mandatory cell of the
Script row in `ADAPTING.md` section 1 is required (injected facts, schema-validated structured
output, one function that calls the model, a log line per call, one redacted fixture, one separate
reviewer session); every other rule here is advice until the project grows." Also mark the
scheduled-shape rules the way `(artifact)` and `(ids)` are marked: `(scheduled)` on "delta-gate on
changed input, deduplicate schedules, tie cadence to the consumer" (`agent-rules.md:60-61`).
JUDGMENT, with the text quoted.

**Finding B2 (Skeptic). The ladder contradicts the Script row.**
Where: `README.md:455-456` ("Script scale ... targets level 2 in Routing, Evaluation, and Review")
versus `README.md:461` (Routing level 2 = "One client, enforced by a guard test"), `README.md:469`
(Evaluation level 2 = "Metric and read date") and `ADAPTING.md:23` (Script: guard test not
mandatory, "evaluation file" optional). Why: a reviewer scoring a Script project by the ladder will
fail it against the framework's own exemption. Resolve: "Script scale targets level 1 in Routing,
level 2 in Review, and is not scored on Evaluation until it has an evaluation file." VERIFIED (lines
quoted).

**Finding B3 (Production Engineer). Canary call and daily content sample are stated without a
scale or volume condition.**
Where: `README.md:332-334` (canary for request-response), `README.md:343-344` and
`agent-rules.md:68-69` ("a person reads a sample of the output every day"). Why: for a Script or a
low-volume internal request-response feature a scheduled canary is spend with no reader, and a daily
human read of an internal colleague-facing feature with five outputs a day is a rule that will decay
in the first holiday week. Resolve: canary bullet: "...where the shape has no natural cadence and
the project is at Service scale or above"; sample bullet: "Where the consumer is not the operator, a
named person reads a sample of the output at a stated cadence; daily where the reader is a third
party or the output can commit, disclose or move anything; every finding has a path..." See also
E3 for how the sample should be observed. JUDGMENT.

**Finding B4 (Production Engineer). Tool-definition hash pinning will be bypassed by agentic
coding-tool adopters.**
Where: `README.md:296-297` ("pinned by version or hash in the registry; a changed definition fails
the inventory test until re-approved"); `ADAPTING.md:90-91`. Why: for a product this is the right
control against tool-description injection. For a team whose "agentic session" is a coding agent
with third-party MCP servers that update weekly, the inventory test will be red most of the time and
will be downgraded to a warning, which `ADAPTING.md:364-365` says never to do. Resolve: scope it:
"For tool servers the project ships or controls, pinned by version or hash in the registry; for
third-party servers, pinned by version with a review on each bump, and the contract says which."
JUDGMENT.

**Sound (checked):** the `(artifact)` and `(ids)` markers in `agent-rules.md:6-9` and `:17,:38`
correctly exempt request-response and agentic shapes from keep-last-good and prompt-listed
vocabularies; the `n/a(reason)` convention is defined identically in `README.md:57-58,159-162`,
`call-site-contract.md:6-8`, `ADAPTING.md:112`, `agent-rules.md:14`; the Agentic row
(`ADAPTING.md:25`) and the agentic worked example are a floor only "if your consumer is a third
party, if the model can read or move another person's data or money, or if every turn feeds the
next" (`README.md:17-21`), which is the right conditional; the hosted-agent-loop door
(`README.md:110-112, 302-304`) is a sensible reading of P4 for coding tools; 3.11's git restriction
(`README.md:416-417`) is correctly narrow.

## 1.4 Length and adopter cost (push-on C)

**Veto seat: the honest time to fill the revised contract for one call site.** 120 placeholders in
12 sections. For a request-response call the engineer already knows, assuming the door exists:
header and sections 1-2, 30 min; section 3 (two tables, policy, external text, ceiling, context,
terms), 60-75 min because it requires reading the prompt builder; section 4 (retirement date lookup
on the vendor lifecycle page, effort, caps, cache layout, tier, latency as TBD), 45 min; sections
5-6, 45 min; sections 7-8, 40 min; sections 9-10, 25 min; section 11 (vendor data terms, data
classes, rule-of-two, sandbox, server-side tools), 60 min because it requires reading the vendor
agreement and asking someone. Total: five to six hours for a known call site; a full day for the
first one; one and a half to two days for an agentic call. Reasonable people will land between four
and eight hours.

**Finding C1 (Veto). The stated budgets contradict each other and the estimate above.**
Where: `ADAPTING.md:6-7` ("Budget an afternoon for steps 1 to 5 on a green-field project with one
call site, an hour per further call site for step 4, a day for the door and its tests") and
`README.md:476-478`. Why: steps 1 to 5 include step 3 (the door), which the same sentence budgets at
a day; "an hour per further call site" is a fifth of the honest figure for a 120-field template;
`README.md:490` tells the adopter to pick "the call with the highest cost of being wrong" for the
first contract, which is never the one-hour one. An adopter who plans a sprint on these numbers and
misses by 5x blames the framework, in public. Resolve: ADAPTING line 6-8: "Budget an afternoon for
steps 1, 2 and 4 on a green-field project with one simple call site, a day for step 3 (the door and
its two tests), half a day per further call site for step 4 (a day for an agentic one), and half a
day for the first panel gate." README 476-478 to match. VERIFIED (lines quoted); the estimate is
JUDGMENT.

**Finding C2 (Veto). Three statements of provenance in one README.**
Where: `README.md:7-12`, `README.md:14-22`, `README.md:520-528`. The first and third say the same
thing (five months; most rules incident-traced; the 2026 additions reasoned; reports in
`docs/reviews/`) in nearly the same words. Resolve: cut lines 7-12 to "Distilled from five months
of production use in one system; what is incident-backed and what is reasoned is stated under
Provenance and limits." Keep 14-22 (it is the shape caveat, which earns its place) and 520-534.
Saves eight lines and one repetition the Skeptic will otherwise quote. VERIFIED.

**Finding C3 (Veto). Additions that do not earn their place, with lines.**
- `README.md:202-204` (evidence "at the start or the end of the prompt, not only in the middle"):
  a research-era heuristic, not from the incident record, stated as a MUST. Cut or move to 3.3 as
  advice: "Put the decisive evidence and the task where the model will not lose them; measure, do
  not assume."
- `README.md:302-304` repeats `README.md:110-112` (P4's last sentence) nearly verbatim. Keep the
  checklist box; shorten P4 to its first three sentences.
- `README.md:407-410` repeats `ADAPTING.md:272-277` and contains the contradiction in D2 below. Cut
  to one sentence (text under D2).
- `README.md:476-480` repeats `ADAPTING.md:6-12`. Keep one; README gives one line and points to
  ADAPTING.
- `README.md:510` (PR checklist: "Static prompt prefix unchanged, or the cache-hit drop is noted"):
  a reviewer cannot check this from a diff; `README.md:515` (hash baseline refreshed) already catches
  a changed prefix. Merge into 515: "...refreshed if the prompt changed; a changed static prefix
  notes the expected cache-hit drop; golden-set result linked."
- `README.md:321-323` (two separate budget bullets for batch and effort/cache) fold into the
  reductions bullet at 319-320 as conditions (text under A4 and A5).
VERIFIED (lines quoted); the cut decisions are JUDGMENT.

**Finding C4 (Veto, Skeptic). Checklist items that are not one yes/no question.**
Where: `README.md:38` promises "Each box is one yes/no question"; `README.md:272-275` (one door
bullet: four assertions, one box), `README.md:327-331` (log fields plus the class list),
`README.md:292-295` (tool allowlist, credentials, principal scope, filesystem, egress: five
assertions). Why: a box that bundles five controls is ticked when three are met. Resolve: split
272-275 into "one client module, every call site imports it" / "a guard test with a failing fixture
bans every other route" / "an inventory test lists every registered site and an unknown site
raises" / "a second vendor is a second transport behind the same door"; split 292-295 the same way.
VERIFIED.

**Skeptic: rules nobody will follow as written.**
- `README.md:372` and `evaluation.md:16`: "re-run on every prompt, model id, or effort change". It
  is followed only if the trigger is mechanical. The framework already has the mechanism: the
  prompt-template hash baseline test (`README.md:231-232`) fails on a prompt change. Say so: "The
  hash-baseline failure is the trigger; the PR that refreshes the baseline links the golden-set
  result, and the CI check in 3.10 requires the link." Until the CI check exists (and
  `LOCAL.template.md:46` allows `planned(by date)`), this rule is a request.
- `README.md:343-344`: daily human reading with no record that it happened. See E3.
- `README.md:296-297`: tool-definition hashes for third-party servers. See B4.
- `LOCAL.template.md:71`: "contracts whose 'last reviewed' is within 90 days" as a metric read once a
  year. Make the inventory test, which already parses by-dates, warn on a "Contract last reviewed"
  older than 180 days. One line in `ADAPTING.md:109-120`.

**Veto on `agent-rules.md` length:** 95 lines, about 1,100 words, injected into every agent
session. Acceptable; the B1 preamble fix matters more than the length.

## 1.5 Internal consistency (push-on D)

Checked by grep across all thirteen documents (README, ADAPTING, contract, evaluation, LOCAL
template, protocol, agent-rules, adapters/README, skill-header, four prompts). Results:

| Item | Result |
|---|---|
| Vocabulary: `doctrine`, `whitelist`, `guardrail` | none remain. VERIFIED (grep, also enforced by `tests/run.sh:287,290`) |
| `validator` vs `guard test` | glossary at `README.md:49-50` is clean; one leftover at `README.md:103`, P3 title "Instructions are requests; guards are controls", uses "guards" in the old sense (output controls). Resolve: "Instructions are requests; validators and structural controls are controls" or simply "...; controls are controls" reads badly, so: "Instructions are requests; code is the control." JUDGMENT |
| Outcome-class list (nine) | identical in `README.md:329-331`, `ADAPTING.md:140-141`, `agent-rules.md:65-66`. VERIFIED. Note: `tests/run.sh:293-295` only checks that `truncated` and `cap_hit` appear; it does not compare the lists. Suggest the drift test extract and compare the three lists |
| Four failure policies | identical in `README.md:152`, `README.md:282-283`, `agent-rules.md:47-48`, `call-site-contract.md:119`, `ADAPTING.md:122`. VERIFIED |
| Six framework files | `README.md:71`, `ADAPTING.md:49,56,320,328`, `adapters/README.md:3`; `adopt.sh:19` copies exactly those six plus LICENSE. VERIFIED |
| Eight door rules | `ADAPTING.md:98-145` numbers 1-8; `ADAPTING.md:155` says "eight rules"; `LOCAL.template.md:50-59` has eight rows in the same order. VERIFIED |
| Minimum panel | "two sessions" at `panel-protocol.md:64`, `README.md:392-393`, `ADAPTING.md:276-277`; Script scale "one session" at `agent-rules.md:6`, `panel-protocol.md:146,178`, `ADAPTING.md:23`. VERIFIED |
| Reproduction rule | `README.md:399-400`, `agent-rules.md:85-87`, `panel-protocol.md:128-141`, `adapters/claude-code/skill-header.md:43-45`: all say file-and-line findings are verified in place, judgment findings are reproduced in a fresh session, a non-reproducing blocker is demoted. The protocol alone adds "an approve that does not reproduce is treated as modify" and K-convergence; the summaries omit it, which is acceptable for a summary. VERIFIED |
| Audit-bias rule | `README.md:247-250`, `agent-rules.md:34-37`, `call-site-contract.md:105`: same two biases, same trigger set (third party, money, personal data). README adds "A reply to a customer is always the second kind"; the others do not, fine. VERIFIED |
| Shape list (four) | identical at `README.md:56-57,143`, `call-site-contract.md:20`, `ADAPTING.md:27-28`, `LOCAL.template.md:9`. VERIFIED |
| Veto seat singular/plural | `README.md:379` "convenes the veto seat"; everywhere else "veto seats" (one per irreversible resource). Resolve: "convenes the veto seats". VERIFIED |
| Generated skill | `make-skill.sh --check` passes inside `tests/run.sh`; SKILL.md carries the protocol body. VERIFIED |

**Finding D1 (Skeptic). The ladder contradicts the Script row.** See B2.

**Finding D2 (Skeptic). "Review level 1" contradicts the ladder's own cells.**
Where: `README.md:409-410` ("Until the check exists, the project is at Review level 1 on the ladder,
whatever the file says") versus `README.md:470` (level 1 = "Author self-review"; level 2 =
"Independent reviewers at one gate"; level 3 requires "verdict link required by CI"). A project
running real independent sessions without a CI check is level 2 by the table. Resolve: "Until the
check exists the project scores at most Review level 2, whatever the instructions file says."
VERIFIED.

**Finding D3 (ML Engineer). The agentic worked example fails the framework's own evaluation
checklist.**
Where: `README.md:369-372` requires a golden set (path, n, how labelled, held out) and its re-run;
`README.md:469` makes it a level-3 Evaluation item; `call-site-contract.md:151` lists it in the
evaluation file; the agentic example's evaluation (`call-site-contract.md:275-280`) names metric,
control, read date, kill, harm floor, control retention and no golden set, with no `n/a(reason)`.
By `call-site-contract.md:3-4` a blank field is a design gap. Why: the example is the floor the
README (`:19-21`) tells third-party-facing adopters to copy. Resolve: add to the example: "golden
set: 150 recorded sessions with their tool results, replayed against the recorded results (no live
tools), labelled by two support leads, held out from prompt iteration, refreshed quarterly;" and,
in README 3.9, one sentence on what a golden set is for an agentic shape: "for an agentic session
the golden set is recorded sessions replayed over their recorded tool results." VERIFIED (lines
quoted); the replay design is JUDGMENT.

## 1.6 Data pair: the new evaluation fields (push-on E)

**Finding E1 (ML Engineer). Held-out golden set re-run on every prompt change is a dev set with a
better name.**
Where: `evaluation.md:14` ("held out from prompt iteration"), `evaluation.md:16` and
`README.md:372` ("re-run on every prompt, model id, or effort change"), `README.md:228-229` ("A
prompt change is replayed on the golden set ... before it ships"). Why: if every prompt change is
scored on the same set and shipped when the number is good, the set is being selected against; the
"held out" label is false after the third iteration. Resolve: evaluation.md: "**Dev set.** `<path,
n>`: iterate prompts against this. **Golden set.** `<path, n, how labelled, refresh cadence>`:
scored once per candidate that passed the dev set, never read during iteration; refreshed or rotated
when it has been scored more than `<k>` times." README 3.3 and 3.9 to name the dev set for
iteration and the golden set for the ship decision. JUDGMENT (standard practice; no vendor source).

**Finding E2 (ML Engineer, Data Engineer). The ticket example's labels are contaminated by the
model once it is live.**
Where: `call-site-contract.md:217-219` (metric "agreement with the manual queue's final assignment";
golden set "300 labelled tickets"). Why: after launch, the final queue is downstream of the model's
route (a ticket the model sent to Billing is resolved by Billing); agreement rises because the model
anchors the label, not because it is right. The control "keyword map alone" has the same leak.
Resolve: "golden set 300 tickets routed before the model shipped, or blind re-labelled by a second
person who does not see the model's queue; refreshed with 50 blind labels per month." JUDGMENT.

**Finding E3 (Data Engineer). The daily content sample has an unstated selection and no evidence it
happened.**
Where: `call-site-contract.md:270-271` ("20 sent replies per day read by the support lead"),
`ADAPTING.md:301-303`, `README.md:343-344`. Three problems. (a) "Sent replies" excludes every draft
the audit held and every draft the agent discarded, so the sample measures the person-plus-model
system and cannot measure the model's own harm rate or the audit's recall; the held drafts are
where the model's worst outputs are. (b) "20 per day" does not say how chosen; the first 20 of the
day are the morning's tickets, from the morning's agents. (c) Nothing records that the read
happened; a missed week is invisible, which violates P6's own logic ("a green pipeline can be doing
nothing"). Resolve: contract line 136-137 placeholder: "Content sample: `<n>` outputs per `<period>`
drawn at random across the period, stratified by `<queue or hour>`, plus `<m>` of the drafts held
or discarded, read by `<role>` who is not the approver, looking for `<named outcomes>`; each read is
logged as a record with a count, and a period without a read record alerts like a liveness
failure." VERIFIED (sampling text quoted); the bias is JUDGMENT with arithmetic in E4.

**Finding E4 (ML Engineer). The harm floor as exemplified has no detection power.**
Where: `call-site-contract.md:278-279` ("any disclosure ... in the daily sample pauses the
feature") with n = 20 per day (`:270`); `evaluation.md:24`. Arithmetic: with a true harm rate of
1 per 100 sent replies, the chance that a random 20 contains one is 1 - 0.99^20 = 18 % per day and
63 % over a five-day week; a zero-in-20 floor excludes, at 95 % confidence, only harm rates above
about 14 % per day. The floor is honest only if the sample size is derived from the rate it must
exclude. Resolve: evaluation.md harm-floor placeholder add: "sample size `<n>` chosen so that a rate
of `<p>` would be seen with `<95> %` probability within `<period>` (n = ln(0.05)/ln(1-p))"; and in
the example "n = 300 per week" or state that 20 per day detects only gross failure and the floor is
read weekly on the pooled 100. JUDGMENT, with arithmetic shown.

**Finding E5 (Data Engineer). The drift baseline is the fixture set.**
Where: `README.md:340-342` ("distribution over the last N runs that differs from the fixture
baseline"); the ticket fixtures are 40 recorded outputs from one day (`call-site-contract.md:214`;
`ADAPTING.md:287` "Record for a day"). Why: a one-day, 40-item baseline has day-of-week and
volume bias; comparing production distributions to it alerts constantly or never. Resolve: "differs
from the first two weeks of production log by more than a stated amount; fixtures are for tests,
not for baselines." JUDGMENT.

**Finding E6 (Data Engineer). Judge "from a different family" can conflict with the data terms the
same contract relies on.**
Where: `README.md:373-375`, `evaluation.md:18` (different family) versus
`call-site-contract.md:169-170` and the agentic example `:284-285` (personal data sent under one
vendor's zero-data-retention agreement). Why: a different family usually means a second vendor and a
second data agreement; the evaluation template does not say so, and an adopter will send customer
text to a judge vendor they have no terms with. Resolve: evaluation.md judge placeholder: "a
different family from the candidate where the data terms in contract section 11 allow a second
vendor; otherwise a different model of the same vendor, and say so." JUDGMENT.

**Feasibility of re-run at the stated cadence (asked directly).** Ticket example: 300 small-model
calls per prompt change, minutes and cents; feasible even on every tweak once a mechanical trigger
exists (see Skeptic above). Agentic example: no golden set is named (D3); 150-300 recorded sessions
replayed over recorded tool results is feasible per candidate (tens of dollars), not per tweak;
live replays are neither reproducible nor affordable. The dev/golden split in E1 is what makes the
cadence realistic.

**Ladder "score per call site; lowest wins" (asked directly).** Workable for Inputs, Validators,
Actions, Failure handling, Testing and Evaluation, which are per call site. Not meaningful for
Routing (one door is project-wide), Budget (the scheduler is project-wide), Observability (half the
items are project-wide) and Review (project-wide); for those rows "lowest call site" has no
referent. And during a retrofit (`ADAPTING.md:147-165`) "lowest wins" pins the project at level 0-1
for months by design, which the retrofit section says is expected. Resolve `README.md:453`: "Score
the per-call-site rows per call site and report the lowest and the count at each level; Routing,
Budget and Review are scored once for the project. During a retrofit, call sites with an open
backlog by-date are reported separately, not hidden and not averaged." JUDGMENT.

**Sound (checked):** golden-set fields (path, n, labelling, hold-out, refresh) are the right five;
judge discipline (different family, both orders, consistent wins only, length control, human
agreement first) is the current standard and is correctly placed in the template with an
`n/a(deterministic metric)` escape; control retention as a named field, with removal convening the
veto seats, closes the "metric improved because the control was removed" hole in both the template
and the protocol's results-gate question (`panel-protocol.md:152`); the ticket example's harm floor
`n/a(a misroute is recoverable)` is a correct use of the convention.

## 1.7 Credibility (push-on F)

- "Reasoned rather than paid for" (`README.md:10`, `:528`): honest and clear; it names which rules
  are which, and "they will be marked paid for when an adopter's incident record says so" is a
  verifiable promise. The Veto seat likes it. The one weakness is repetition (C2).
- "Most rules trace to a specific incident or measurement there" (`README.md:7-8`): unverifiable
  because the record is not public, and the text says so (`:10`). Acceptable.
- Claims the README cannot back: none that are false. The vendor-coloured ones are A1-A5, and they
  are wording, not falsehoods. The two internal contradictions (B2/D1, D2) and the example that fails
  its own checklist (D3) are what a hostile reader will screenshot; those are the credibility risk.
- Padding: C2 and C3 list it. The Map table and the Terms paragraph are not padding; they are the
  cost of the vocabulary pass and they pay for themselves.
- `tests/run.sh` header (`:2`) says "three helper scripts" plus "the skill generator"; there are four
  scripts. Consistent once read, but "four scripts" would be plainer.

## 1.8 Scripts (shipped code), briefly

`tests/run.sh` ran in a temporary directory: 108 checks, 0 failed. Read-through of `adopt.sh`,
`panel-run.sh`, `make-skill.sh`, `install.sh` found no defect in scope for this session. One
observation for the Data Engineer: `panel-run.sh:108` takes the verdict from the last line that is
exactly one token, and the fake-model test at `tests/run.sh:196-203` covers both the correct case and
an inline mixed-case verdict. Sound.

## 1.9 Per-role independent positions

**LLM Production Engineer.** The revision is the framework I would hand a team shipping a
model-backed feature in 2026. The 2026 additions are right in substance and verified at two to
three vendors; five sentences carry one vendor's vocabulary (A1-A5) and two MUSTs need a condition
(A4 batch, B3 canary). The agentic example is good, and its missing golden set (D3) is the one
thing I would not let ship because it is the example people copy.

**Methodology Skeptic.** The revision over-corrected in one place that matters: `agent-rules.md`
now instructs every agent at every scale to build the Service-scale apparatus (B1), and the ladder
and the Script row disagree (B2). Those are how frameworks get cargo-culted: the small project
builds the registry because the file said so, then abandons the whole thing. Three rules are
unfollowable as written without the CI trigger (golden-set re-run, daily sample, tool hashes). The
3.10 "level 1" sentence (D2) and the triple provenance (C2) are the kind of thing that gets quoted
back at the author.

**ML Engineer.** The evaluation template is a large improvement (golden set, judge discipline,
harm floor, control retention). Its one methodological flaw is treating a re-run-on-every-change
set as held out (E1). The ticket example's label leak (E2) and the harm floor's power (E4) are
teaching-example problems: an adopter will copy n = 20 and a zero floor and believe they have a
floor.

**Data Engineer.** The content sample as specified (E3) has three pipeline faults: a biased
population, an unstated selector, and no record of execution; the framework's own P6 says the last
one is how pipelines fail silently. The drift baseline on 40 fixtures (E5) will not work. The
judge-family rule can breach the data terms the same contract relies on (E6).

**Adopter's Time and Credibility Advocate (veto).** I do not veto the merge. I would veto
publishing with the two internal contradictions (B2, D2), the example that fails its own checklist
(D3) and the time budgets (C1) in place, because each is a one-line fix and each is the kind of
defect that costs a public author more than the hours it saves. The honest contract-filling time
is five to six hours, not one; say so. Cut the repetitions in C2-C3; they add about 25 lines of
538 and nothing an adopter needs.

## 1.10 Peer challenge and reconciliation

- **Engineer vs Skeptic on B4 (tool hashes).** Engineer: hash pinning is the only control against
  tool-description injection and must stay a MUST for products. Skeptic: for a coding tool with
  third-party servers it will be downgraded to a warning within a month. Reconciled: agree, scope
  it to servers the project controls, version-pin the rest with review on bump (text under B4).
- **Engineer vs Veto on C1 (time).** Engineer: an experienced team fills the simple contract in two
  to three hours. Veto: the framework tells them to start with the hardest call site. Reconciled:
  agree on "half a day per further call site; a day for an agentic one".
- **ML Engineer vs Skeptic on E1 (dev/golden split).** Skeptic: a second set is another rule nobody
  follows. ML Engineer: without it the "held out" claim is false and the ship decision is
  overfitted. Reconciled: agree on the split, with the mechanical trigger (hash-baseline failure)
  running the dev set, and the golden set run once per candidate; this makes the cadence realistic
  rather than adding a rule.
- **Data Engineer vs Veto on E3/E4 (sample size, read record).** Veto: specifying n from a power
  formula adds a field to a template that already doubled. Data Engineer: a floor without power is
  theatre, and theatre on a public page is a credibility cost. Reconciled: agree; the formula goes
  in the evaluation template's placeholder text, not as a new field.
- **Engineer vs Data Engineer on E6 (judge family).** Engineer: same-vendor judges are correlated
  with the candidate. Data Engineer: a second vendor without data terms is a privacy incident.
  Reconciled: agree on "different family where section 11's data terms allow; otherwise a different
  model of the same vendor, stated".
- **All seats on the verdict class.** Veto argued that B2, D2, D3 and C1 should block publication.
  The others: each is a one-line, code-verified fix with the text supplied; by the protocol's own
  definitions (`panel-protocol.md:106-108`) that is MODIFY-BEFORE-BUILD, not BLOCKERS. Reconciled:
  MODIFY-BEFORE-BUILD, with B2, D2, D3, C1 and A1-A4 named as the modifications that must be folded
  in before the merge is published, and the rest as should-fold.

---

# Part 2. Closure of the first panel's findings (written after reading `0-consolidated.md` and `1-domain-veto.md`)

Marks: CLOSED (present in the revised text at the line given), PARTIAL (what is missing is stated),
NOT CLOSED. Line numbers are in the revised files at HEAD f0c0a9b.

## 2.1 Blockers B1-B7

| # | First panel's blocker | Mark | Where in the revision, and what is missing |
|---|---|---|---|
| B1 | "every rule paid for itself"; Provenance names no guide | CLOSED | `README.md:7-12` adopts the proposed text nearly verbatim; `:520-528` matches; "five months" at `:7` and `:522`; "named under Provenance" gone. New: the statement now appears three times (Part 1, C2). VERIFIED |
| B2 | `agent-rules.md` states shape/scale rules unconditionally | PARTIAL | Closed for the three rules named: `(ids)` at `agent-rules.md:17`, `(artifact)` at `:38`, "At Service scale and above" at `:81`, preamble at `:3-10` as proposed. Missing: the preamble exempts only the panel; the rest of the file still instructs a Script-scale agent to build the guard and inventory tests (`:43-44`), pin snapshots with retirement dates (`:45-46`), carry idempotency keys (`:48`), log nine classes and the served id (`:65-67`), and pre-register a golden set and harm floor (`:76-78`), all of which `ADAPTING.md:23` makes optional at Script scale; the scheduled-shape cost rules at `:60-61` carry no `(scheduled)` marker. Text to close it is under Part 1, B1. VERIFIED |
| B3 | Agentic example: money guarded by a prompt sentence and a keyword audit; existence not entitlement; send ambiguity; no field for irreversible actions | CLOSED | Policy sentence stays at `call-site-contract.md:243-245` but is now structurally enforced: `:259-261` ("no tool sends to the customer or moves money; a refund or credit is an `escalate` call with a reason code from a closed set of six, acted on by a person"); entitlement at `:240-242`; draft-not-send unambiguous at `:232-234, :268, :283`; keyword audit replaced by a recall-biased hold at `:257-259`; field at `:163`; checklist at `README.md:298-301`; rule at `agent-rules.md:55-57`. VERIFIED |
| B4 | Precision bias hard-coded for a trust surface | CLOSED | `README.md:246-250`; `agent-rules.md:34-37`; ladder `README.md:463` ("Audit biased by cost asymmetry"); contract `:105`. VERIFIED |
| B5 | Raw outputs committed as fixtures; no retention, redaction, vendor terms | CLOSED | `README.md:349-351`; `ADAPTING.md:283-288` (redact before writing, or write to a store with the source's access control; "raw transcripts never enter the repository"); contract `:143-144, :169-172`; examples `:214, :253-254, :285-286`. VERIFIED |
| B6 | No harm floor; metric rewards removing the human control; nothing keeps the control | CLOSED | `evaluation.md:24, :26`; `README.md:131-132, :378-379, :382-383`; example metric rewritten at `call-site-contract.md:275-277` to reject the old one explicitly; control retention `:279-280`. New: the floor's statistical power (Part 1, E4). VERIFIED |
| B7 | No field for acting principal, data scope, personal data, aggregate bounds; pre-filled "Secrets: none" | CLOSED | contract `:158-159` (principal), `:161` (reads scope), `:77-79` (aggregate bounds), `:169-172` (data); `:156` is now a placeholder naming the guard test and date; `README.md:156` maps Security and data to P2. VERIFIED |
| F6 (demoted) | Process rules enforced by instruction | CLOSED as modify | `README.md:407-410`, `ADAPTING.md:272-276`, `LOCAL.template.md:46`. New: the README sentence contradicts the ladder (Part 1, D2). VERIFIED |

## 2.2 Group A: shipped scripts

All CLOSED, verified by executing `tests/run.sh` (108 checks, 0 failed) and reading the scripts:
roster substitution in bash (`panel-run.sh:73-76`); verdict from the last one-token line (`:108`);
nonce fence (`:66, :81-82`) with the evidence sentence also in `skill-header.md:36-37` and
`panel-protocol.md:70-71`; pre-flight, size cap, timeout, environment allowlist, `PANEL_SEATS`,
`PANEL_BUILD_STAGE`, `PANEL_PUSH_ON`, `EXTRA_PAIR` sentence (`:36-65, :79-80, :91, :100`);
`adopt.sh` markers, remembered instructions file, `cd --`, legacy-block report, other-file note
(`adopt.sh:14-16, :20-22, :30-31, :44-52, :62-65, :70-86`); `install.sh` backup and symlink
refusal (`:15-18, :23-29`); Data-pair prompt (`1-domain-data-and-veto.md:8-11`); generated
SKILL.md with `make-skill.sh --check`. One item is closed by changing the documentation rather than
the code: the runner still does not read `LOCAL.md`; `ADAPTING.md:208, :247` and the runner's header
(`panel-run.sh:18-20`) now say the roster comes from a `.panel.env` beside `LOCAL.md`. Honest and
acceptable. VERIFIED.

## 2.3 Group B: new knowledge

| Item | Mark | Where | Note from this panel |
|---|---|---|---|
| Model lifecycle | CLOSED | contract `:64-66`; `README.md:276-278, :329`; `ADAPTING.md:132-137`; `LOCAL.template.md:58` | wording A2 ("dated snapshot"), A3 (retirement date assumed to exist) |
| Prompt caching | CLOSED | `README.md:116-117, :212-216, :231-232, :290-291, :319, :510`; contract `:73` | wording A1 ("breakpoint" is not universal) |
| Structured outputs, `truncated`, max_tokens | CLOSED | `README.md:217-219, :240-241, :330`; contract `:68, :89-90, :102` | verified at two vendors; no change |
| Effort | CLOSED | `README.md:225-227, :322-323`; contract `:67` | wording A5 |
| Agentic: P4 clause, `run()`, §11 cells, tool definitions as external text, ceiling, rule of two | CLOSED | `README.md:110-112, :200-201, :292-304`; `ADAPTING.md:88`; contract `:34-35, :54, :56, :160-168` | B4 scopes tool-hash pinning |
| Context engineering | CLOSED | `README.md:202-204, :263-264`; contract `:58` | C3: `:202-204` should be advice, not a MUST |
| P2 refinement; prior turns are context | CLOSED | `README.md:92-94, :206-208`; `agent-rules.md:24-26` | none |
| Evaluation: golden set, re-run, judge, panel as judge, adopted/refuted counts | CLOSED | `README.md:369-375, :404-405`; `evaluation.md:14-18`; `panel-protocol.md:162-164`; `LOCAL.template.md:71-72` | E1 (held-out set re-run on every change), E6 (judge family vs data terms), D3 (agentic example has no golden set) |
| Cost: batch tier; designed cascade | CLOSED | `README.md:283-285, :319-321`; contract `:69` | A4: batch needs the 24-hour-window condition and an outcome class for expiry |
| Retry on the same route; idempotency | CLOSED | `README.md:286-288`; `ADAPTING.md:122-125`; contract `:34-35, :120-121` | none |
| Hard caps with `cap_hit`; TTL expiry; streaming; rendering; URLs closed | CLOSED | `README.md:257-261, :266-268, :314-316`; contract `:96, :124-126` | none |
| Observability: session/trace id, parent id, served id, stop reason | CLOSED | `README.md:327-331`; `ADAPTING.md:138-142`; contract `:133` | OTel is not mentioned anywhere (grep 0); the first panel asked for "noted, not mandated"; omission is a defensible choice and is recorded here as one |
| Failure vocabulary: deterministic default; keep-last-good conditional; compensation | CLOSED | `README.md:152, :259-261, :282-283`; `agent-rules.md:38`; contract `:127-128` | none |
| Scope paragraph; one veto per resource; content sample; Shape line | CLOSED | `README.md:14-22, :343-344, :497`; `ADAPTING.md:223-231`; `panel-protocol.md:39-41`; contract `:20, :136-137` | E3: the sample needs a selector and a read record |

## 2.4 Group C: self-consistency and text

| Item | Mark | Where |
|---|---|---|
| Validator layers 6/5/4 | PARTIAL | `README.md:151` and `ADAPTING.md:179-180` now list six; P3 at `README.md:104-106` still lists five (schema, vocabulary, audit, suppression, removal; no numeric copy). Insert "a numeric copy check," after "a closed vocabulary," |
| Files copied six/five/four | CLOSED | grep; enforced by `tests/run.sh:289` |
| Door rules six vs seven rows | CLOSED | eight at `ADAPTING.md:98-145, :155` and eight rows at `LOCAL.template.md:50-59` |
| "POSIX shell" | CLOSED | `README.md:27`; `tests/run.sh:288` |
| whitelist; five vs several months | CLOSED | `tests/run.sh:287`; `README.md:7, :522` |
| "Four parts"; ladder section number | CLOSED | Map at `README.md:32-41` |
| Reproduction rule inverted in agent-rules | CLOSED | `agent-rules.md:85-87`; `README.md:399-400`; `skill-header.md:43-45` |
| Minimum panel 3 vs 2; verdict casing | CLOSED | `ADAPTING.md:276-277`; `README.md:392-393`; `panel-protocol.md:64`; no lowercase token in running text (grep) |
| Worked examples violate their own rules (TBD date, Build stage, read dates) | CLOSED, new gap | `call-site-contract.md:188, :218, :228-229, :249, :277`; new: agentic example has no golden set or `n/a(reason)` (Part 1, D3) |
| Adopted copy references; MIT notice | CLOSED | `README.md:28-30`; `adopt.sh:57` |
| Evaluation fields in three places | CLOSED | `evaluation.md` is canonical; `README.md:155` and contract `:151` are pointers; `README.md:369-371` and `agent-rules.md:76-77` name the same six |
| "commit" in branch-state rule; subprocess language; "arm" | CLOSED | `README.md:416-417`; `:279-281` ("If it is a subprocess"); grep "arm" none |
| §3.10 omits scoping | CLOSED | `README.md:391-393` |
| Checklist items not yes/no | PARTIAL | `README.md:272-275, :292-295, :327-331` still bundle three to five checks (Part 1, C4) |
| Ladder: Budget row; bundled L3; "level 3 everywhere" vs proportionality; scoring rule and scorer | PARTIAL | Budget row at `:466`; "3 (all of)" header at `:459` declares the bundling; scoring rule and reviewer-scorer at `:453-454`; but `:455-456` contradicts `ADAPTING.md:23` (Part 1, B2), and "per call site" has no referent for four rows (Part 1, E) |
| "guard" four senses; "gate" four; "stage" two; jargon before definition | PARTIAL | Terms at `README.md:47-58`; "trigger, not a gate" at `:51-52`; "Phase" at `:436`; one leftover: P3 "guards are controls" at `:103` |
| Re-run with no terminating condition | CLOSED | `README.md:401-402`; `panel-protocol.md:156-158`; `skill-header.md:48-49` |
| TBD expiry reds the whole suite; date-bumping | CLOSED | `ADAPTING.md:116-120, :364-365` |
| Time estimate README vs ADAPTING | PARTIAL | headline figures now match (`README.md:476-480`, `ADAPTING.md:6-12`), but `ADAPTING.md:6-7` budgets "steps 1 to 5" at an afternoon and step 3 at a day in the same sentence, and "an hour per further call site" is unchanged against a template that grew from 66 to 120 placeholders (Part 1, C1) |

## 2.5 Escalations and accepted limitations

| Item | Mark | Where |
|---|---|---|
| Framework's own P7/P8 record | CLOSED | `docs/reviews/2026-10-12-panel/`; `LOCAL.template.md:69-74` (framework read date, metrics, kill criteria per practice); `README.md:76` |
| Merge P1/P2; security claim with no principle | CLOSED | old P2 folded into P1 at `README.md:88-94`; new P2 (bounding) at `:96-101`; "bounded" replaces "guardrailed" at `:6`; §2 maps Security and data to P2 at `:156` |
| Rename "doctrine" | CLOSED | "stated policy" throughout; `tests/run.sh:290` |
| Accepted limitation: allowlist bounds doing, not saying | CLOSED | `README.md:532-534` |
| Accepted limitation: not a PIA, legal review, or safety case | CLOSED | `README.md:530-532` |
| Accepted limitation: liveness and keep-last-good are scheduled-shape; canary for the others | CLOSED | `README.md:332-334`; `ADAPTING.md:27-32, :143-145` |

## 2.6 Items from `1-domain-veto.md` not carried into the consolidated list

| Item | Mark | Where |
|---|---|---|
| L-1 ladder scoring rule and scorer | CLOSED | `README.md:453-454`; workability of "per call site" questioned in Part 1, E |
| L-2 Failure-handling L3 unreachable for interactive shapes | CLOSED | `README.md:465` ("TTL semantics or deterministic default") |
| L-4 user-facing disclosure that a model produced it | CLOSED | `README.md:337-338`; contract `:134` |
| L-5 streaming; L-6 citations; L-7 adversarial fixtures; L-8 "arm" | CLOSED | `README.md:257-258, :221-222, :352-353`; grep |
| "Contract last reviewed" rots because no test reads it | NOT CLOSED | `LOCAL.template.md:71` makes it a yearly metric only; the inventory test (`ADAPTING.md:109-120`) still reads placeholders and TBD dates only. One clause closes it (Part 1, Skeptic list) |
| Validators row 4 "say what it does not catch" can be left empty undetected | NOT CLOSED | the inventory test checks backticked `<...>` placeholders; an emptied cell passes. Minor; add "an empty table cell in sections 3 or 6 fails" to `ADAPTING.md:111` |
| What partial adoption buys (contract without the door) | NOT CLOSED | `ADAPTING.md:347-348` says only what it costs. One sentence after it: "Without the door, the contract still forces the consumer question and the validators-before-prompt order; keep those two even if the door waits a quarter." JUDGMENT |
| Veto's "afternoon" as blocker (recorded as modify by the first panel) | PARTIAL | see C1 |

---

# Part 3. Reconciled findings, in priority order

Each: what; where; why it matters; what resolves it; mark. The texts under "resolve" are in Part 1
at the finding named.

**Must fold in before the merge is published (one-line, code-verified fixes):**

1. **Ladder contradicts the Script row.** `README.md:455-456` vs `:461, :469` and `ADAPTING.md:23`.
   A reviewer following the ladder fails a Script project against the framework's own exemption.
   Resolve: Part 1, B2. VERIFIED.
2. **"Review level 1" contradicts the ladder's cells.** `README.md:409-410` vs `:470`. Resolve:
   Part 1, D2. VERIFIED.
3. **Agentic worked example has no golden set and no `n/a(reason)`.** `call-site-contract.md:275-280`
   vs `README.md:369-372, :469` and `call-site-contract.md:3-4`. The example adopters are told to
   copy fails the spec gate it is meant to pass. Resolve: Part 1, D3. VERIFIED (gap); replay
   design JUDGMENT.
4. **Time budgets contradict each other and the template's size.** `ADAPTING.md:6-7`,
   `README.md:476-478`; honest figure five to six hours per known call site. Resolve: Part 1, C1.
   VERIFIED (contradiction); JUDGMENT (estimate).
5. **`agent-rules.md` still applies Service-scale apparatus at Script scale.** `agent-rules.md:5-6`
   vs `:43-48, :65-67, :76-78` and `ADAPTING.md:23`. This is the first panel's B2, PARTIAL.
   Resolve: Part 1, B1. VERIFIED.
6. **Vendor-specific wording stated as universal.** "cache breakpoint" (`README.md:215-216`,
   contract `:73`, `:510`); "dated snapshot" (`ADAPTING.md:132-133`); retirement date assumed to
   exist (`README.md:276-278`, contract `:64-65`); batch as unconditional MUST with no expiry
   outcome (`README.md:321`); effort/cache slightly overstated (`:322-323`). Resolve: Part 1, A1-A5.
   VERIFIED against Anthropic, OpenAI and Google documentation fetched 2026-10-12.
7. **P3 still lists five of six validator layers.** `README.md:104-106`. Resolve: Part 2, 2.4.
   VERIFIED.

**Should fold in (methodology and pipeline):**

8. **Held-out golden set re-run on every change is a dev set.** `evaluation.md:14, :16`;
   `README.md:228-229, :372`. Resolve: Part 1, E1 (dev set for iteration, golden set once per
   candidate, refresh after k reads). JUDGMENT.
9. **Daily content sample: biased population, unstated selector, no read record.**
   `call-site-contract.md:136-137, :270-271`; `ADAPTING.md:301-303`; `README.md:343-344`.
   Resolve: Part 1, E3. VERIFIED (text) / JUDGMENT (bias).
10. **Harm floor has no detection power as exemplified.** `call-site-contract.md:270, :278-279`;
    `evaluation.md:24`. n = 20/day with a zero floor excludes only rates above about 14 %.
    Resolve: Part 1, E4. JUDGMENT with arithmetic.
11. **Ticket example's label is contaminated by the model once live.** `call-site-contract.md:217-219`.
    Resolve: Part 1, E2. JUDGMENT.
12. **Judge "different family" can breach the contract's own data terms.** `README.md:373-375`,
    `evaluation.md:18` vs contract `:169-170`. Resolve: Part 1, E6. JUDGMENT.
13. **Drift baseline is a one-day, 40-item fixture set.** `README.md:340-342`. Resolve: Part 1, E5.
    JUDGMENT.
14. **"Score per call site; lowest wins" has no referent for four rows and pins retrofits at 0-1.**
    `README.md:453`. Resolve: Part 1, E (ladder paragraph). JUDGMENT.
15. **Canary and daily sample stated without a scale or volume condition.** `README.md:332-334,
    :343-344`; `agent-rules.md:68-69`. Resolve: Part 1, B3. JUDGMENT.
16. **Tool-definition hash pinning will be bypassed by coding-tool adopters.** `README.md:296-297`.
    Resolve: Part 1, B4. JUDGMENT.

**Cuts and tidying (veto seat):**

17. Triple provenance (`README.md:7-12, :14-22, :520-528`): Part 1, C2. VERIFIED.
18. Repetitions and MUSTs that do not earn their place (`README.md:202-204, :302-304, :407-410,
    :476-480, :510, :321-323`): Part 1, C3. VERIFIED (lines) / JUDGMENT (cuts).
19. Bundled checklist boxes (`README.md:272-275, :292-295, :327-331`): Part 1, C4. VERIFIED.
20. "veto seat" singular at `README.md:379`; P3 "guards are controls" at `:103`; `tests/run.sh:2`
    "three helper scripts". VERIFIED.
21. Three small items the first panel's domain seat raised and the revision did not carry:
    "Contract last reviewed" unread by any test; empty validator cells pass the inventory test;
    nothing says what partial adoption buys (Part 2, 2.6). VERIFIED (absence) / JUDGMENT (value).

**Suggested test additions (shipped code, not blocking):** `tests/run.sh:293-295` checks only that
`truncated` and `cap_hit` appear; extract and compare the full nine-class list and the four-policy
list across `README.md`, `ADAPTING.md`, `agent-rules.md`, `call-site-contract.md` so the drift this
revision fixed cannot recur silently. JUDGMENT.

## Concerns the author did not already list

The consolidated verdict and the first domain report list none of: findings 1, 2, 3, 4 (as a
contradiction rather than a mismatch), 6 (vendor vocabulary; the first panel verified against one
vendor and asked for the additions), 7 (P3 count survived), 8, 9, 10, 11, 12, 13, 14, 15, 16.
Findings 5 and 17-21 are residues of items the first panel did list.

## What was checked and found sound, so a lenient read is visible

- All seven first-panel blockers are addressed in the text at the lines given; five are fully
  closed, B2 is partial as stated, F6 is closed as modify.
- Every Group-B knowledge item is present; the structured-output, retry, cap, TTL, streaming,
  rendering, P2-refinement, failure-vocabulary and scope items need no change.
- Vendor claims: structured-output residuals, effort defaults per model, batch at 50 %, served-id
  logging, "pinned snapshots, never aliases" (README and contract wording), effort-change cache
  miss: all verified at two vendors; three at Google where applicable.
- Internal consistency: outcome classes (nine, three places), failure policies (four, five places),
  six files, eight door rules, four shapes, two-session minimum, one-session Script rule,
  reproduction rule (four places), audit-bias rule (three places), verdict casing, `n/a(reason)`
  definition (five places), generated SKILL.md: all consistent.
- Scripts: 108 checks pass; the defects the first panel reproduced are fixed at the lines given in
  2.2, and each has a test.
- The agentic example's bounding design (draft-not-send, escalate with closed reason codes,
  principal-scoped reads, no money-moving tool) is the right floor; the `n/a(reason)` uses in both
  examples are correct; the evaluation template's control-retention and judge fields are the right
  fields; the provenance wording is honest.

## Verdict

MODIFY-BEFORE-BUILD

Findings 1-7 are the modifications that must be folded in before the merge is published; each is a
one-line to one-paragraph change with the text supplied above. Findings 8-16 should be folded in
at the same time or carried with a by-date in `LOCAL.md`'s backlog for the framework itself.
Findings 17-21 are cuts the veto seat requests. No blocker: nothing in the revision is harmful or
false as published; the two internal contradictions and the self-failing example are what a hostile
reader would quote, and they are each fixable in minutes.
