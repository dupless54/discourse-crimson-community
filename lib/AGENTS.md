# Crimson Community library layer

- Presenter output is theme-facing public data; expose only intentionally public user fields.
- Keep user lookup/query helpers bounded and null-safe.
- Do not move privacy decisions into theme/client code; serializers/controllers remain authoritative.
