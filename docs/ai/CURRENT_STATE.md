# Current state

Crimson Community provides authenticated online-presence and profile-visitor services plus the stable profile-background serializer contract used by Crimson Channels.

The native `/community` route is a first-party-style Discourse view over the existing authorized online-presence endpoint. It uses the standard `wrap` shell, core `DUserInfo`, the Community sidebar plugin API, Discourse theme variables, responsive layout, and client locales. It does not change profile-visitor behavior, schema, presence authorization, or the JSON response contract.

Minimum Token Context v3 is integrated with frontend scoped rules under `docs/ai/scopes/frontend/`. AI reviewer approvals are advisory only; delivery requires latest exact-head official Discourse CI per `WORKFLOW.md` plus explicit task-level merge authorization.
