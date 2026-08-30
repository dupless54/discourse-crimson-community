<p align="center">
  <a href="https://buymeacoffee.com/erespawn">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me a Coffee" width="217" height="60">
  </a>
</p>

# Discourse Crimson Community

A companion Discourse plugin for the **Crimson Channels** theme. It provides authenticated community services and a native Discourse community page while keeping privacy, profile visibility, and presence authorization server-authoritative.

## Current Features

- Native `/community` page using the standard Discourse application shell, header, sidebar, theme variables, viewport helpers, and responsive layout.
- Online-member presentation backed by Discourse PresenceChannel data with an additional privacy-safe snapshot filter before output.
- Separate total-online, displayed-member, and activity-window summaries without changing the existing `users`, `count`, or `window_minutes` contract.
- Client-side name/username search across the already-authorized online snapshot.
- Manual Community snapshot refresh with loading feedback and failure recovery that keeps the previous authorized list visible.
- Native Community profile-visitor panel for the signed-in user's own history, including visit timestamps, retention context, disabled/unavailable states, and independent refresh.
- Recent profile-visitor history backed by Discourse's existing `UserProfileView` records.
- Guardian-based profile visibility for both visitor targets and members returned in visitor history.
- Stable `crimson_profile_background_url` presentation contract for the Crimson Channels user-card experience.
- Privacy-filtered `crimson_online_state` site serializer for theme integrations.
- Community sidebar integration through the supported Discourse plugin API.
- Core `DUserInfo` presentation for online-member and profile-visitor rows.
- English and Turkish client localization.
- Light/dark-mode compatibility through Discourse theme variables.

## Privacy Model

Privacy and visibility decisions remain on the server:

- users with `hide_presence` enabled are removed from online output even when an older PresenceChannel state still contains them;
- profile-visitor services require authentication;
- a hidden/private target profile returns not found before a visit is persisted;
- visitor history does not expose members whose profiles the current viewer cannot see;
- the Community visitor panel uses a current-user-only read endpoint whose target is derived from the authenticated session, avoiding username/IDOR selection and avoiding synthetic self-visits;
- the existing username profile-visit endpoint keeps its visit-recording behavior for profile/theme integrations;
- the `/community` page consumes the authorized presence API rather than creating a second presence model;
- Community search only filters the authorized snapshot already returned by the server and cannot discover hidden members;
- public serializer fields remain intentionally limited to presentation data required by Crimson UI integrations.

## Service Endpoints

- `GET /crimson-community/online.json`
- `GET /crimson-community/profile-visits.json` — read-only visitor history for the signed-in user
- `GET /crimson-community/profile-visits/:username.json`
- `POST /crimson-community/profile-visits/:username.json`

All JSON service endpoints require an authenticated Discourse user. Username-targeted profile-visit endpoints apply Discourse Guardian profile visibility before persistence or serialization. The current-user read endpoint derives its target from `current_user` and never records a visit while loading Community history.

The online response keeps the established `users`, `count`, `window_minutes`, and `generated_at` fields and adds `total_count`, `remaining_count`, and `limit` so clients can distinguish the complete eligible presence snapshot from the configured list cap.

## Version 1.4.0 Highlights

- Added a native "Your profile visitors" panel to `/community` with core `DUserInfo`, `DButton`, and current Discourse date formatting.
- Added a read-only, current-user-only visitor-history endpoint so Community page loads never create synthetic self-visits.
- Kept the existing username-targeted GET/POST tracking contract unchanged for profile/theme integrations.
- Added independent visitor refresh with loading state, failure recovery, disabled state, and an initial-load fallback that does not break online Community features.
- Kept Guardian filtering server-authoritative for every visitor returned to the client.
- Expanded request and frontend acceptance coverage for current-user targeting, hidden visitors, disabled visitor history, refresh success/failure, and degraded loading.
- No database migration or new persistence model was introduced.

## Installation

Add the plugin to your Discourse container configuration:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/dupless54/discourse-crimson-community.git
```

Rebuild Discourse:

```bash
cd /var/discourse
./launcher rebuild app
```

Then enable the Crimson Community plugin in site settings. Install the matching [`discourse-crimson-channels`](https://github.com/dupless54/discourse-crimson-channels) theme if you want the full Crimson visual experience.

## Architecture

Crimson Community owns community-related server truth. Crimson Channels is a theme consumer of its public JSON and serializer seams. Authorization, profile visibility, and presence privacy must never be moved into theme-side JavaScript.

The plugin intentionally continues to use Discourse's `UserProfileView` records for active profile-visitor behavior. The historical plugin-specific profile-visit table is not migrated or repurposed by this release.

For repository-specific development rules, see [`AGENTS.md`](AGENTS.md).

## Support

If this plugin is useful to your community, you can support continued development through the Buy Me a Coffee banner at the top of this README.
