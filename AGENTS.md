# Discourse Crimson Community Agent Router

Canonical instructions for ChatGPT/Codex, Claude, and Gemini.

## Context routing
Current source/tests > `docs/ai/CURRENT_STATE.md` > nearest local `AGENTS.md` > stable docs > plans/history. Always read this file, then only local rules for touched areas:
- presence/profile-visit HTTP + models -> `app/AGENTS.md`
- presenter/helpers -> `lib/AGENTS.md`
- schema/migrations -> `db/AGENTS.md`
Use the minimal three-file `docs/ai/work/<feature>/` packet only for real multi-session work.

## Fast task path
For non-trivial work, use `.agents/skills/task-packet/SKILL.md` before broad reads. Use `docs/ai/REPO_MAP.md` to locate code, `COMMANDS.md` only for validation, and `DECISIONS.md` only for privacy/architecture choices. Skip the formal packet for trivial one-file edits.

## Privacy and product invariants
This plugin supplies Crimson theme-facing online presence, profile-visitor history, and a stable profile-background serializer field.

- `hide_presence` is authoritative: hidden users must not appear in online presence.
- Presence APIs/serializers must not reveal users who should be hidden under current Discourse/privacy rules.
- Profile-visit read/write behavior must respect authenticated viewer/target/profile visibility and avoid IDOR/enumeration.
- Visitor history stores/returns only data needed by the feature; avoid sensitive profile/account fields.
- Theme-facing serializer fields (`crimson_profile_background_url`, online state) are public integration contracts; keep shapes minimal and intentional.
- Presence/event handling should tolerate setting changes and transient channel unavailability without leaking state.
- Profile-visit retention/query paths need bounded pagination/limits and appropriate indexes as data grows.

## Implementation and tests
Follow current Discourse PresenceChannel, Guardian, serializer, route, and plugin APIs verified from source. Keep authorization server-side and changes small. Test visible/hidden presence, unauthorized/private profile access, target/user edge cases, and query behavior relevant to the change. Never claim unrun tests passed.

Stop for unresolved privacy/product/schema/security decisions. Preserve unrelated work and `.claude/settings.local.json`; no destructive Git/deploy/DB actions. Remote writes only when explicitly authorized. Prefer targeted source ranges/diffs over broad scans.

Task procedures live under `.agents/skills/` and load on demand; use `task-packet` for non-trivial work.

## Adaptive model / effort routing
Classify execution risk with `docs/ai/EFFORT_ROUTER.md` before broad reads. Start at the lowest sufficient tier: T0 mechanical, T1 routine, T2 high-risk, T3 exceptional. Escalate for risk/ambiguity rather than task size, and de-escalate when the risky phase ends. Use platform-native workers under `.claude/agents/` or `.codex/agents/` when supported; never trade away correctness, privacy, security, or validation to save tokens.
