<p align="center">
  <a href="https://buymeacoffee.com/erespawn">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me a Coffee" width="217" height="60">
  </a>
</p>

# Discourse Crimson Community

A companion Discourse plugin for the **Crimson Channels** theme. It provides authenticated community services and a native Discourse community page without replacing Discourse's privacy or presence rules.

## Current Features

- Native `/community` page using the standard Discourse application shell, header, sidebar, theme variables, and responsive layout.
- Online-member presentation backed by Discourse presence/user activity data.
- Recent profile-visitor history backed by Discourse's existing `UserProfileView` records.
- Stable `crimson_profile_background_url` presentation contract for the Crimson Channels user-card experience.
- Community sidebar integration through supported Discourse plugin APIs.
- Core `DUserInfo` presentation for member rows instead of a standalone user-list implementation.
- English and Turkish client localization.
- Light/dark-mode compatibility through Discourse theme variables.

## Privacy Model

Privacy and visibility decisions remain server-authoritative:

- users with hidden presence are not exposed through the online-member contract;
- profile-visitor services are authenticated;
- the `/community` page consumes the existing authorized presence API rather than creating a second presence model;
- public serializer fields are intentionally limited to presentation data needed by the Crimson UI.

## Service Endpoints

- `GET /crimson-community/online.json`
- `GET /crimson-community/profile-visits/:username.json`
- `POST /crimson-community/profile-visits/:username.json`

The JSON service endpoints require an authenticated Discourse user.

## Recent Development Highlights

### Shipped on `main`

- Native first-party-style `/community` experience.
- Community sidebar entry.
- Responsive light/dark presentation.
- English/Turkish client locales.
- Reuse of the existing authorized online-presence contract.
- Official Discourse Plugin CI and token-efficient repository development guidance.

### In progress — not yet on `main`

PR #7, **Community runtime and profile privacy hardening**, is currently open. Its scope includes tighter profile-visibility checks for visit recording/history and cleaner client runtime behavior. These changes should not be treated as shipped until that PR is merged.

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

Crimson Community owns community-related server truth. Crimson Channels is a theme consumer of its public JSON/presentation seams. Authorization, profile visibility, and presence privacy must never be moved into theme-side JavaScript.

For repository-specific development rules, see [`AGENTS.md`](AGENTS.md).

## Support

If this plugin is useful to your community, you can support continued development through the Buy Me a Coffee banner at the top of this README.
