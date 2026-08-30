# Current state

Crimson Community provides authenticated online-presence and profile-visitor services plus the stable profile-background serializer contract used by Crimson Channels.

The native `/community` route is a first-party-style Discourse dashboard over two existing authorized data sources: the online-presence endpoint and the signed-in user's read-only profile-visitor history. It uses the standard `wrap` shell, core `DUserInfo`/`DButton` primitives, current Discourse date formatting, the Community sidebar plugin API, Discourse theme variables, responsive viewport helpers, and client locales.

Online members remain the primary dashboard panel. The signed-in user's profile visitors are a secondary panel on wider screens and stack below the online panel on mobile. Both panels expose the existing server-provided `generated_at` timestamps so users can see snapshot freshness. A dashboard-wide refresh action refreshes both existing services together while preserving each panel's independent refresh/failure behavior.

The visitor panel remains bounded by the server response and now shows a client-side six-member preview for longer histories. Expanding or collapsing that preview never performs another member query and cannot reveal users beyond the already-authorized visitor response.

Community supports local name/username filtering of the already-authorized presence snapshot. Search never queries hidden/global users: it only filters the `users` array already returned by `/crimson-community/online.json`. Manual presence refresh keeps the last successful snapshot visible if the request fails and exposes translated, accessible failure feedback.

Community presents the signed-in user's recent profile visitors through `GET /crimson-community/profile-visits.json`. That endpoint derives the target from `current_user`, never records a visit, and returns only Guardian-visible visitor accounts through the same bounded `UserProfileView` history query used by the existing profile integration. The username-targeted GET/POST endpoints retain their existing visit-recording semantics.

Profile visitor loading is independent from presence loading. A visitor-history failure does not break the online Community view; manual visitor refresh retains the last successful history on failure. When visitor tracking is disabled, the current-user endpoint returns an authenticated disabled state with no visitor data instead of exposing the server-only site setting to Ember.

Presence state is filtered again against active Discourse users and `hide_presence` before either the `/online.json` response or `crimson_online_state` site serializer is exposed. This prevents stale PresenceChannel entries from leaking a member after they hide presence. The existing response fields remain available; list metadata is additive.

Profile-visit reads and writes require the target profile to be visible to the current Guardian. Returned visitor history also filters visitors whose profiles the viewer cannot see, uses bounded candidate/result limits, and continues to store visits in Discourse's existing `UserProfileView` records. Hidden/private targets return not found before persistence, avoiding an existence/private-state distinction in username-targeted plugin endpoints.

Only `crimson_community_enabled` is client-visible so the native Community sidebar registration can follow the actual plugin setting. Limits, retention, presence privacy, visitor enablement, and visitor authorization remain server-side. Version 1.5.0 adds no backend route, serializer, setting, migration, persistence, or authorization change.

Minimum Token Context v3 remains integrated with frontend scoped rules under `docs/ai/scopes/frontend/`. Delivery uses latest exact-head official Discourse CI per the root `AGENTS.md`; AI reviewer approval is not a merge gate.
