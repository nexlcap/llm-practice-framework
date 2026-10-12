# Evaluation: `<call site or feature id>` (pre-registered `<YYYY-MM-DD>`)

Written before the feature ships. Filled in on the read date. A feature without this file is
permanent by default, whether or not it works.

**Question.** `<one sentence: what would have to be true for this to be worth keeping>`

**Metric (primary).** `<what is measured, how, on what sample, by whom; it measures the output, not the reviewer's effort>`

**Metric (secondary).** `<cost per unit of value; anything the primary metric could hide>`

**Control.** `<what it is compared against; how confounders are held constant; order of runs>`

**Dev set.** `<path, n>`: prompts are iterated against this set.

**Golden set.** `<path, n, how labelled (before launch, or blind to the model's output), refresh cadence>`: scored once per candidate that passed the dev set, never read during iteration, rotated after `<k>` reads. For an agentic session: recorded sessions replayed over their recorded tool results, no live tools.

**Re-run on.** a prompt-template hash change (the baseline test failing is the trigger), a model snapshot change, an effort change: `<who runs it, where the result goes; the change that refreshes the baseline links it>`

**Judge (if a model scores outputs).** `<a different family from the candidate where the data terms in the contract allow a second vendor, otherwise a different model of the same vendor, said so; pairwise runs in both orders and only consistent wins count; length controlled; agreement with a human sample of <n> measured before the judge is trusted>` or `n/a(deterministic metric)`

**Read date.** `<YYYY-MM-DD>`; put it in a calendar and in the contract, so the inventory test expires it.

**Kill criterion.** `<the number below which the feature is removed or reduced, decided now>`

**Harm floor.** `<the named harmful outcome (disclosure to the wrong party, unauthorised action, false commitment); the rate above which the feature is paused regardless of the primary metric; measured on a sample of <n> per <period> drawn at random by code, including held and discarded outputs, read by <role>; n chosen so that a rate of <p> would be seen with 95 % probability within the period (n = ln(0.05) / ln(1 - p)); rates below what the sample can see are caught by <deterministic check>>` or `n/a(reason: the reader is the operator and the output is recoverable)`

**Control retention.** `<which human control remains after a positive read; what evidence would justify removing it; removing it is a decision-logic change that convenes the veto seats>`

**Approvals (if an approval step exists).** `<approvals per hour, reversals after approval; an approval step that is approved more than it is read is not a control>`

**Consumption check.** `<how you confirm something reads the output>`

**Result.** (filled in on the read date; the harm floor is read the same day; keep the file after removal as the record of why)
