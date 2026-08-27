# Durable decisions

Load only when privacy or architecture behavior is relevant.

- `hide_presence` is authoritative; hidden users must not appear through presence APIs/serializers.
- Profile-visit access follows authenticated viewer/target/profile visibility and must not create IDOR/enumeration paths.
- Theme-facing serializer fields stay minimal public presentation contracts.
- Visitor history is bounded/paginated and stores only feature-required data.
- Presence/event handling must fail safely through setting changes or transient channel failure without leaking hidden state.

Do not record temporary PR/CI state here; use `CURRENT_STATE.md` for volatile facts.
