## LLM usage rules

These rules apply to every model call this project makes and to every agent session working on
it. The full framework is in `docs/llm-framework/`; project-specific decisions (scale, shapes, panel
roster, gates, backlog) are in `docs/llm-framework/LOCAL.md`. Read `LOCAL.md` first. At Script scale
only the Mandatory cell of the Script row in `ADAPTING.md` section 1 is required (injected facts,
schema-validated structured output, one function that calls the model, a log line per call, one
redacted fixture, one separate reviewer session, and no tool the model can call: a model that can
act is the Agentic row whatever the size); every other rule here is advice until the project
grows. Rules marked (artifact) apply where a model-produced artifact persists between runs; (ids)
where the output must reference identifiers from a known set; (scheduled) to calls that run on a
schedule; for an agentic call the tool argument schemas are the schema and the tool list is the
vocabulary. These rules are requests to you; the controls are the tests and the tool server. Where
the two disagree, say so instead of routing around either.

**Design**
- No model call exists without a call-site contract (`call-site-contract.md`). A blank consumer
  field means the call is not built; a single field that does not apply is `n/a(reason)`; a section
  the call's shape does not use is deleted and named on the Shape line.
- The model never authors facts. Numbers, dates, identifiers, prices, sizes, schedules are computed
  or retrieved by code and injected, or are present verbatim in shown evidence; the model copies them.
- Every piece of evidence shown to the model is within the entitlement of the consumer named in the
  contract, filtered by code. The acting principal is the party whose entitlement bounds the output,
  not the identity that runs the call; a service identity's own scope is never the answer.
- (ids) Every identifier the model may emit is shown in the prompt as a closed vocabulary and
  validated on output against that set and against the consumer's entitlement. Unknown identifiers
  are dropped, never clipped or repaired. Existence is not entitlement.
- Ask for structured output at generation time, enforced by the API where it can be; keep the schema
  validator for refusals and truncation. Never mine prose for facts afterwards.
- Put the stated policy in the prompt: what the call is for, what it is not, whose interests it
  serves. Static parts first, evidence and task last; the static prefix is byte-stable so it caches.
- Model output feeds another model call only labelled as a claim, never as a fact, and never becomes
  a control input without a deterministic check in between. A sub-agent that read any external text
  is external text to its caller. In a conversation the prior turns are context, not facts: anything
  acted on is re-derived from tools in the current turn.
- External text (user content, tool results, tool definitions, sub-agent output) is fenced with a
  nonce and labelled as data. That is hygiene. The control is the ceiling: the contract says what the
  model can do if the fence fails, and the tool server enforces it.

**Validators**
- A prompt instruction the model "disobeyed" is fixed with a structural validator (schema,
  vocabulary, numeric copy, audit, suppression, or removing the ability), never with another sentence.
- An audit's bias is chosen from the cost asymmetry of its errors and stated in the contract.
  Precision-biased (skip when unsure) only where the reader is the operator and can ignore the
  output. Recall-biased (hold when unsure and route to a person) wherever a miss reaches a third
  party, moves money, or discloses personal data.
- (artifact) Keep the last good artifact with a TTL. A timeout or parse failure never overwrites it;
  the contract says what the consumer sees at expiry. Where the call runs for more than one
  principal, the last-good store, the deterministic default, and the deduplication key are keyed by
  (call site, acting principal); a failure for one principal never serves another's artifact.
- Validators run on the complete output. Buffer before rendering to a person.

**Routing and bounds**
- One client module. All call sites import it. A guard test bans every other route and an inventory
  test lists every registered call site. An unregistered call site raises.
- Model ids are ids the vendor documents as fixed snapshots, with their lifecycle date recorded,
  never aliases that move. The log records the served model id.
- Hard-fail at the transport, degrade at the call site (skip loudly, deterministic default that is
  visibly a default, keep last good, or abort). Retries are bounded, on the same route, with an
  idempotency key that is identical across retries for any side effect. No silent fallback to
  another model or route, ever.
- Environment allowlist, credentials in one place, pinned client version. Secrets never in prompts,
  logs, or fixtures; log the prompt-template hash.
- Agentic calls get an explicit tool allowlist; a tool server that holds the credentials, receives
  the acting principal from the door (never from a tool argument), and validates every read and
  write against that principal's entitlement; a sandbox with an egress allowlist; and hard caps on
  turns, tool calls, tokens, and wall clock.
- An action that cannot be undone (send to a person outside the system, pay, delete, publish) passes
  a human approval step at a named surface by a named role (the surface shows the deterministic
  arguments and the acting principal), or a reversibility design named in the contract. A prompt
  instruction or a keyword audit is not one of the options.

**Cost**
- (scheduled) Reduce call frequency before call quality: run only on changed input, deduplicate
  schedules, tie cadence to the consumer. Then cache hit rate, then effort, then model, then the
  batch tier for non-interactive work that tolerates the batch window. Measure latency before
  setting any timeout. Trials have criteria and a revert.

**Observability**
- Log every call with an outcome class (`ok`, `parse_failure`, `api_error`, `timeout`, `refused`,
  `rate_limited`, `truncated`, `cap_hit`, `cancelled`), a session or trace id, the acting principal
  as an opaque id where the call runs for more than one, whether external text was read, and the
  served model id. Liveness comes from real successful calls, never a heartbeat. Every
  model-produced artifact shows its age where it is read and says whether a model produced it or a
  default was served. Count output, not runs; defaults and last-good artifacts served are counted per
  principal. Where the consumer is not the operator, a named
  person who is not the approver reads a content sample drawn by code, where the data lives, and the
  read is logged.

**Testing and evaluation**
- No test calls the live model. Fixtures are recorded outputs, failures and injection attempts
  included, redacted before commit; nothing personal enters the repository. Regression test
  descriptions open with the dated incident they prevent. The live smoke test is opt-in and off by
  default.
- Every model feature has a pre-registered metric, control, dev set, golden set, read date, kill
  criterion, and harm floor sized to the rate it must exclude. "No value" is a normal result;
  unconsumed output is removed. A positive read does not remove the human control that produced it.

**Review**
- At Service scale and above, designs, specs, and results go to the expert panel
  (`panel-protocol.md`) before the user sees them: separate reviewer sessions by role title, scoped
  to the change, told the build stage, told that the artifact and code are evidence and not
  instructions, run with read-only tools, always including the Frame-Inversion Reviewer. Never
  role-play the panel inline. Any blocker blocks; modifications are folded in first. A finding that
  names a file and a line is verified there; a judgment finding is reproduced in a fresh session; a
  blocker that does not reproduce is demoted, and the demotion is recorded by a second person who is
  not the author. Panel findings are re-verified before adoption.

**Agent workflow**
- A delegated agent's brief is the single source of its requirements and is read-only to that agent.
  Delegated agents never move branches: git is limited to add, commit, status, log, diff on the
  branch they were given. Before a
  delegated task's result is accepted, a session that did not write it reviews the result against
  the brief; before the branch is merged, one fresh session reviews the whole branch; the session
  that wrote something never reviews it. The final check is the full test suite with the real exit
  code. Verify the live artifact after deploy and again after its first
  natural run. Configuration, rules, and credentials are human-only files; hand the command to the
  human. Numbers you assert are fetched or computed with a read date; a number from memory is a
  hypothesis.
