# discourse-crimson-community

Companion plugin for the **senin.me Crimson Channels** Discourse theme.

It adds two authenticated JSON services used by the theme's right community rail:

- recently active members, based on Discourse's `last_seen_at` heartbeat;
- recent visitors for the profile currently being viewed.

It also exposes the member's uploaded profile-cover URL to the theme's user-card
serializer, allowing the compact card to use the real profile cover instead of
the fallback gradient.

Profile visits are stored once per visitor/profile pair and refreshed at most once
per minute. Self-visits are ignored. A daily job removes records older than the
configured retention period.

## Installation

Install the plugin in the normal Discourse `plugins` directory, rebuild the app,
then install or update the matching Crimson Channels theme. Settings are available
under Admin → Settings → Plugins by searching for `crimson_community`.

The theme keeps a page-local fallback if this plugin is unavailable, but true
cross-user online and profile-visitor lists require this plugin.

## Endpoints

- `GET /crimson-community/online.json`
- `GET /crimson-community/profile-visits/:username.json`
- `POST /crimson-community/profile-visits/:username.json`

All endpoints require a signed-in Discourse user.
