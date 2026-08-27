# Repository map

Use this to choose paths before searching. Source code remains authoritative if the map becomes stale.

- `plugin.rb` — plugin entrypoint and feature registration.
- `app/` — presence/profile-visit models/controllers/serializers; read `app/AGENTS.md`.
- `lib/` — presenter/helpers; read `lib/AGENTS.md`.
- `db/` — migrations/indexes/retention-sensitive schema; read `db/AGENTS.md`.
- `config/` — routes/settings/locales/configuration.
- `docs/` — AI state/workflow and stable docs; do not preload wholesale.

Fast read order: root `AGENTS.md` -> task packet -> nearest local `AGENTS.md` -> exact symbol/source -> exact test. Load privacy decisions and validation commands only when needed.
