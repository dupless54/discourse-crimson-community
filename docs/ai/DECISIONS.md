# Durable decisions

Load only when privacy or architecture behavior is relevant.

- `hide_presence` is authoritative; hidden users must not appear through presence APIs/serializers.
- Profile-visit access follows authenticated viewer/target/profile visibility and must not create IDOR/enumeration paths.
- `GET /crimson-community/profile-visits.json` is a current-user-only, read-only history contract: derive the target from `current_user`, apply Guardian filtering to returned visitors, and never record a visit from this endpoint.
- Username-targeted profile-visit GET/POST endpoints retain their tracking semantics for profile/theme integrations; Community must not use them for background history reads because that would create synthetic self-visits.
- Theme-facing serializer fields stay minimal public presentation contracts.
- Visitor history is bounded/paginated and stores only feature-required data.
- Presence/event handling must fail safely through setting changes or transient channel failure without leaking hidden state.

Do not record temporary PR/CI state here; use `CURRENT_STATE.md` for volatile facts.
