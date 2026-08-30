<p align="center">
  <a href="https://buymeacoffee.com/erespawn">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me a Coffee" width="217" height="60">
  </a>
</p>

# Discourse Crimson Community

A companion Discourse plugin for the **Crimson Channels** theme. It provides authenticated community services and a native Discourse community page while keeping privacy, profile visibility, and presence authorization server-authoritative.

## Current Features

- Native `/community` dashboard using the standard Discourse application shell, header, sidebar, theme variables, viewport helpers, and responsive layout.
- Responsive dashboard composition: online members remain the primary panel while the signed-in user's profile visitors become a compact secondary panel on wider screens and stack naturally on mobile.
- Online-member presentation backed by Discourse PresenceChannel data with an additional privacy-safe snapshot filter before output.
- Separate total-online, displayed-member, and activity-window summaries without changing the existing `users`, `count`, or `window_minutes` contract.
- Client-side name/username search across the already-authorized online snapshot.
- Independent online and visitor refresh controls plus a single dashboard-wide refresh action that refreshes both existing authorized data sources.
- Freshness metadata for both presence and profile-visitor snapshots using each endpoint's existing `generated_at` timestamp.
- Native Community profile-visitor panel for the signed-in user's own history, including visit timestamps, retention context, disabled/unavailable states, and independent refresh.
- Compact visitor preview showing the first six authorized visitors with an explicit show-all/show-fewer control for longer histories.
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
- the `/community` dashboard only composes the existing authorized presence and current-user visitor responses and does not create a new member discovery or activity API;
- Community search only filters the authorized snapshot already returned by the server and cannot discover hidden members;
- visitor preview expansion is client-side only and never requests or reveals accounts beyond the already-authorized visitor response;
- public serializer fields remain intentionally limited to presentation data required by Crimson UI integrations.

## Service Endpoints

- `GET /crimson-community/online.json`
- `GET /crimson-community/profile-visits.json` — read-only visitor history for the signed-in user
- `GET /crimson-community/profile-visits/:username.json`
- `POST /crimson-community/profile-visits/:username.json`

All JSON service endpoints require an authenticated Discourse user. Username-targeted profile-visit endpoints apply Discourse Guardian profile visibility before persistence or serialization. The current-user read endpoint derives its target from `current_user` and never records a visit while loading Community history.

The online response keeps the established `users`, `count`, `window_minutes`, and `generated_at` fields and adds `total_count`, `remaining_count`, and `limit` so clients can distinguish the complete eligible presence snapshot from the configured list cap.

## Version 1.5.0 Highlights

- Reworked `/community` into a responsive personal dashboard without adding a new backend data source or privacy surface.
- Added a dashboard-wide refresh action that refreshes online presence and the signed-in user's visitor history together while preserving each panel's independent refresh and failure handling.
- Added visible snapshot freshness metadata using the existing server-provided `generated_at` fields.
- Added a six-member compact visitor preview with explicit show-all/show-fewer controls for longer authorized histories.
- Added a two-column desktop/tablet composition with a primary online-member panel and secondary profile-visitor panel; mobile remains single-column.
- Kept all 1.4.0 Guardian, presence, visitor-tracking, endpoint, persistence, and server-only setting contracts unchanged.
- Added dedicated acceptance coverage for dashboard refresh, freshness metadata, and visitor preview expansion.

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
