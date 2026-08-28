# discourse-crimson-community

Companion plugin for the **senin.me Crimson Channels** Discourse theme.

It adds authenticated community services and a native Discourse community page:

- `/community` — first-party-style, responsive online-member view using Discourse's normal header/sidebar, theme variables, core user UI, and Community sidebar integration;
- live members, based on Discourse's `user_seen` event and PresenceChannel;
- recent visitors for the profile currently being viewed;
- a stable profile-cover serializer field used by the Crimson Channels user card.

The `/community` page intentionally reuses the existing authorized presence endpoint instead of creating a second privacy or presence model. Hidden-presence rules remain server-authoritative, and the page links to Discourse's built-in member directory for full member discovery.

Profile visits use Discourse's own `UserProfileView` records instead of a plugin-specific database table. The profile owner's own visits are retained as well. The endpoint groups repeated views by member, returns the latest visit, and applies the configured retention period while reading the list.

## 1.1.0

- Added the native `/community` page and Community sidebar entry.
- Reused core `DUserInfo`, `wrap`, theme variables, and current plugin route/sidebar APIs instead of standalone page chrome.
- Added English and Turkish client locales and responsive light/dark-compatible styling.
- Integrated Minimum Token Context v3 handoff/frontend scope and CI-first reviewer policy.
- Added the official reusable Discourse Plugin CI workflow and Discourse RuboCop scaffold.

## Installation

Install the plugin in the normal Discourse `plugins` directory, rebuild the app, then install or update the matching Crimson Channels theme. Settings are available under Admin → Settings → Plugins by searching for `crimson_community`.

The theme does not label page-local guesses as live data. Cross-user online and profile-visitor lists therefore require this plugin.

## Endpoints

- `GET /crimson-community/online.json`
- `GET /crimson-community/profile-visits/:username.json`
- `POST /crimson-community/profile-visits/:username.json`

All JSON service endpoints require a signed-in Discourse user. The `/community` client route prompts anonymous visitors to sign in before loading presence data.
