# Discourse Crimson Community Agent Router

Canonical instructions for ChatGPT/Codex, Claude, and Gemini.

## Context routing
Current source/tests > `docs/ai/CURRENT_STATE.md` > nearest local `AGENTS.md` > stable docs > plans/history. Always read this file, then only local rules for touched areas:
- presence/profile-visit HTTP + models -> `app/AGENTS.md`
- presenter/helpers -> `lib/AGENTS.md`
- schema/migrations -> `db/AGENTS.md`
- `/community` frontend, routes, templates, styles, sidebar integration -> `docs/ai/scopes/frontend/AGENTS.md`
Use the minimal three-file `docs/ai/work/<feature>/` packet only for real multi-session work.

## Fast task path
For non-trivial work, use `.agents/skills/task-packet/SKILL.md` before broad reads. Use `docs/ai/REPO_MAP.md` to locate code, `COMMANDS.md` only for validation, and `DECISIONS.md` only for privacy/architecture choices. Skip the formal packet for trivial one-file edits.

## Privacy and product invariants
This plugin supplies Crimson theme-facing online presence, profile-visitor history, a stable profile-background serializer field, and a native Discourse `/community` view of the existing online-presence contract.

- `hide_presence` is authoritative: hidden users must not appear in online presence.
- Presence APIs/serializers must not reveal users who should be hidden under current Discourse/privacy rules.
- Profile-visit read/write behavior must respect authenticated viewer/target/profile visibility and avoid IDOR/enumeration.
- Visitor history stores/returns only data needed by the feature; avoid sensitive profile/account fields.
- Theme-facing serializer fields (`crimson_profile_background_url`, online state) are public integration contracts; keep shapes minimal and intentional.
- The `/community` client consumes existing authorized presence data; never move privacy or authorization decisions into Ember.
- Presence/event handling should tolerate setting changes and transient channel unavailability without leaking state.
- Profile-visit retention/query paths need bounded pagination/limits and appropriate indexes as data grows.

## Native Discourse UI invariant
The plugin page must feel like part of Discourse: use the standard `wrap` shell, core UI primitives where practical, Discourse theme variables, normal header/sidebar behavior, accessible semantics, responsive layout, and current Glimmer/Ember patterns. Do not ship route-specific full-screen resets, hard-coded standalone palettes, or core template overrides when a plugin API/native primitive exists.

## Implementation and tests
Follow current Discourse PresenceChannel, Guardian, serializer, route, frontend, and plugin APIs verified from source. Keep authorization server-side and changes small. Test visible/hidden presence, unauthorized/private profile access, target/user edge cases, and query behavior relevant to the change. Never claim unrun tests passed.

## CI-only delivery gate
Claude/Gemini/Codex reviewer or verifier approval is not required and must never block merge. Do not request or wait for AI approvals as a merge condition.

For a PR, require the latest exact PR head to have the official `Discourse Plugin` CI GREEN and any separately configured required Discourse-owned CI/check context GREEN. Missing, stale, skipped, pending, cancelled, or older-head CI is not GREEN. A new commit invalidates prior CI evidence. Exact changed paths must remain within task scope.

When the latest exact head is GREEN and no unresolved privacy/security/schema/product/architecture blocker remains, the agent is authorized to merge without another user confirmation. Prefer squash merge with `expected_head_sha` when supported. Never weaken tests or broaden scope just to obtain GREEN.

Stop for unresolved privacy/product/schema/security decisions. Preserve unrelated work and `.claude/settings.local.json`; no destructive Git/deploy/DB actions. Prefer targeted source ranges/diffs over broad scans.

Task procedures live under `.agents/skills/` and load on demand; use `task-packet` for non-trivial work.

## Adaptive model / effort routing
Classify execution risk with `docs/ai/EFFORT_ROUTER.md` before broad reads. Start at the lowest sufficient tier: T0 mechanical, T1 routine, T2 high-risk, T3 exceptional. Escalate for risk/ambiguity rather than task size, and de-escalate when the risky phase ends. Use platform-native workers under `.claude/agents/` or `.codex/agents/` when supported; never trade away correctness, privacy, security, or validation to save tokens.

## Live Discourse developer source gate

Canonical live upstream index: https://meta.discourse.org/t/developer-guides-index/308036?tl=en

For any Discourse-version-sensitive implementation, refactor, review, or compatibility decision:
- start at the live Developer Guides Index and open only the task-relevant official topic(s);
- for plugin work prioritize **Code & Internals + Plugins**; for theme work prioritize **Code & Internals + Themes & Components / Theme Developer Tutorial**; use environment/general guides only when relevant;
- verify version-sensitive APIs and deprecations against current `discourse/discourse` core or the current official plugin/theme skeleton before coding when needed;
- current official docs/core beat remembered examples, old snippets, and copied local guidance unless the repo deliberately targets an older validated release via `.discourse-compatibility` / d-compat;
- do not preload the full index: read the nearest local rules and target source/tests first, then fetch only the upstream guide(s) needed for the current choice.
