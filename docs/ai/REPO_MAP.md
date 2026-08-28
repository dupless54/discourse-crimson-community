# Repository map

Use this to choose paths before searching. Source code remains authoritative if the map becomes stale.

- `plugin.rb` — plugin entrypoint, `/community` server fallback route, feature registration, serializer and presence wiring.
- `app/` — presence/profile-visit models/controllers; read `app/AGENTS.md`.
- `lib/` — presenter/helpers; read `lib/AGENTS.md`.
- `db/` — migrations/indexes/retention-sensitive schema; read `db/AGENTS.md`.
- `assets/javascripts/discourse/` — native `/community` route, route template, and sidebar integration; frontend rules live under `docs/ai/scopes/frontend/AGENTS.md`.
- `assets/stylesheets/` — theme-variable-based native page styling; never store AI context here.
- `config/` — settings and server/client locales.
- `.github/workflows/discourse-plugin.yml` — official reusable Discourse plugin CI.
- `docs/` — AI state/workflow and stable docs; do not preload wholesale.

Fast read order: root `AGENTS.md` -> task packet -> nearest scoped rules -> exact symbol/source -> exact test. Load privacy decisions and validation commands only when needed.
