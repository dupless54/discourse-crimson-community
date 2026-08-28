# Frontend Scoped Rules

- Follow current Discourse/Glimmer/Ember conventions verified from source.
- Prefer native Discourse primitives, route maps, UI kit components, sidebar plugin APIs, theme variables, and the standard `wrap` shell.
- Do not hide or replace the Discourse header/sidebar to make a plugin route look standalone.
- Client code is never the authorization authority; server permissions and privacy remain authoritative.
- Render user-controlled data through normal escaped Glimmer bindings and core user components.
- Preserve mobile/desktop behavior and light/dark themes without hard-coded page palettes.
- Keep AI metadata out of `assets/` and other runtime-compiled source paths; scoped context stays under `docs/ai/scopes/frontend/`.
