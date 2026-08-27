# Crimson Community app layer

- `visible_in_presence?` and current Discourse privacy settings remain authoritative for presence inclusion.
- Presence controller output must not bypass PresenceChannel access or expose hidden users.
- Profile-visit endpoints derive current viewer/target server-side, enforce profile access, and avoid existence/private-state leakage.
- `ProfileVisit` persistence should support bounded history and duplicate/noise policy already defined by code; do not invent new tracking semantics silently.
