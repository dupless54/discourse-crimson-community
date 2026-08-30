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
- Recent profile-visitor history backed by Discourse's existing `UserProfileView` records.
- Guardian-based profile visibility for both visitor targets and members returned in visitor history.
- Stable `crimson_profile_background_url` presentation contract for the Crimson Channels user-card experience.
- Privacy-filtered `crimson_online_state` site serializer for theme integrations.
- Community sidebar integration through the supported Discourse plugin API.
- Core `DUserInfo` presentation for member rows instead of a standalone user-list implementation.
- English and Turkish client localization.
- Light/dark-mode compatibility through Discourse theme variables.

## Privacy Model

Privacy and visibility decisions remain on the server:

- users with `hide_presence` enabled are removed from online output even when an older PresenceChannel state still contains them;
- profile-visitor services require authentication;
- a hidden/private target profile returns not found before a visit is persisted;
- visitor history does not expose members whose profiles the current viewer cannot see;
- the `/community` page consumes the authorized presence API rather than creating a second presence model;
- public serializer fields remain intentionally limited to presentation data required by Crimson UI integrations.

## Service Endpoints

- `GET /crimson-community/online.json`
- `GET /crimson-community/profile-visits/:username.json`
- `POST /crimson-community/profile-visits/:username.json`

All JSON service endpoints require an authenticated Discourse user. Profile-visit endpoints also apply Discourse Guardian profile visibility before persistence or serialization.

The online response keeps the established `users`, `count`, `window_minutes`, and `generated_at` fields and adds `total_count`, `remaining_count`, and `limit` so clients can distinguish the complete eligible presence snapshot from the configured list cap.

## Version 1.2.0 Highlights

- Refreshed the full native Community page information hierarchy and responsive styling.
- Switched Community responsive rules to Discourse's current viewport helper approach.
- Fixed the Community sidebar enable setting so the client receives only the boolean it needs.
- Hardened stale presence-state filtering for both the endpoint and site serializer.
- Hardened profile-visitor target visibility and visitor-list privacy.
- Added bounded visitor candidate filtering and explicit response metadata.
- Added request/unit coverage for hidden profiles and stale hidden presence.
- Preserved the existing Crimson Channels endpoint and serializer integration seams.

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

The plugin intentionally continues to use Discourse's `UserProfileView` records for active profile-visitor behavior. The historical plugin-specific profile-visit table is not migrated or repurposed by the 1.2.0 refresh.

For repository-specific development rules, see [`AGENTS.md`](AGENTS.md).

## Support

If this plugin is useful to your community, you can support continued development through the Buy Me a Coffee banner at the top of this README.
