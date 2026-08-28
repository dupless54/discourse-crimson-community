# CI-first delivery workflow

Any model may act as Builder. Independent ChatGPT/Codex review, Claude review, and Gemini final verification are optional tools, not default merge gates.

## Mandatory delivery gate
- keep task scope locked
- validate exact changed paths
- run relevant targeted checks when available
- require the official `Discourse Plugin` check to be GREEN for the latest exact PR head SHA
- require any separately configured required Discourse-owned `Discourse CI` check to be GREEN for that same exact head SHA
- never reuse CI evidence from an older head SHA
- missing, stale, skipped, cancelled, or absent required CI is not GREEN

## CI failure remediation
If CI fails, inspect the failing job, find the first actionable root cause, classify it as code/test-fixture/dependency/infrastructure, make the smallest justified repair, run targeted validation, then evaluate CI again for the resulting new exact head SHA when an authorized Git/GitHub step creates one. Never weaken tests or expand product/architecture scope merely to make CI green.

Maximum automatic remediation: 3 repair rounds. After 3 unresolved rounds, or if a material architecture/security/schema/product decision is required, stop with `NEEDS_HUMAN` and report the current head, remaining failure, root cause, attempted repairs, and recommended next action.

If required CI is not configured or does not run, report `NO_CI`/`NOT_RUN`; do not call it GREEN. AI reviewer approval never substitutes for required CI. Merge also requires explicit task-level user authorization.
