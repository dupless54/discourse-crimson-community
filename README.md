<p align="center">
  <a href="https://buymeacoffee.com/erespawn">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me a Coffee" width="217" height="60">
  </a>
</p>

# Discourse Crimson Community

A companion Discourse plugin for the **Crimson Channels** theme. It provides authenticated community services and a native Discourse community page while keeping privacy, profile visibility, and presence authorization server-authoritative.

## Current Features

- Native `/community` dashboard using the standard Discourse application shell, header, sidebar, theme variables, viewport helpers, and responsive layout.
- Personal **Your space** action center for the signed-in user with native links to profile, posts, messages, notifications, bookmarks, and drafts without duplicating those Discourse data sources inside the plugin.
- Live attention badges for new private-message notifications, unread notifications, and drafts using fields already present on Discourse's current-user payload; no Community request is added for these counts.
- Client-only **Needs your attention** summary that aggregates those existing message, notification, and draft counts, exposes only nonzero destinations, and switches to a caught-up state when nothing needs attention.
- Mobile/small-screen section navigation for jumping directly between **Your space**, **Online**, and **Visitors** without replacing Discourse navigation or loading another route.
- Responsive dashboard composition: online members remain the primary panel while the signed-in user's profile visitors become a compact secondary panel on wider screens and stack naturally on mobile.
- Online-member presentation backed by Discourse PresenceChannel data with an additional privacy-safe snapshot filter before output.
- Separate total-online, displayed-member, and activity-window summaries without changing the existing `users`, `count`, or `window_minutes` contract.
- Client-side name/username search across the already-authorized online snapshot.
- Client-side online-member sorting by server order, display name, or username without another member request.
- Comfortable and compact dashboard density modes that only change presentation of the already-loaded authorized data.
- Independent online and visitor refresh controls plus a single dashboard-wide refresh action that refreshes both existing authorized data sources.
- Dashboard-wide partial/full refresh feedback while each failed panel keeps its last successful data visible.
- Freshness metadata for both presence and profile-visitor snapshots using each endpoint's existing `generated_at` timestamp.
- Native Community profile-visitor panel for the signed-in user's own history, including visit timestamps, retention context, disabled/unavailable states, and independent refresh.
- Compact visitor preview showing the first six authorized visitors with an explicit show-all/show-fewer control for longer histories.
- Recent profile-visitor history backed by Discourse's existing `UserProfileView` records.
- Guardian-based profile visibility for both visitor targets and members returned in visitor history.
- Stable `crimson_profile_background_url` presentation contract for the Crimson Channels user-card experience.
- Privacy-filtered `crimson_online_state` site serializer for theme integrations.
- Community sidebar integration through the supported Discourse plugin API.
- Core `DUserInfo` presentation for online-member, profile-visitor, and signed-in-user identity rows.
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
- personal action links navigate to existing Discourse profile/activity/message/notification/bookmark/draft routes and do not copy or prefetch those datasets into Community;
- attention badges and the attention summary read only the signed-in user's existing current-user counts and do not introduce another serializer, endpoint, polling loop, or permission decision;
- the mobile section navigator uses in-page anchors only and never causes another Community data request;
- Community search and sorting only transform the authorized snapshot already returned by the server and cannot discover hidden members;
- density changes are presentation-only and perform no member/visitor request;
- visitor preview expansion is client-side only and never requests or reveals accounts beyond the already-authorized visitor response;
- public serializer fields remain intentionally limited to presentation data required by Crimson UI integrations.

## Service Endpoints

- `GET /crimson-community/online.json`
- `GET /crimson-community/profile-visits.json` — read-only visitor history for the signed-in user
- `GET /crimson-community/profile-visits/:username.json`
- `POST /crimson-community/profile-visits/:username.json`

All JSON service endpoints require an authenticated Discourse user. Username-targeted profile-visit endpoints apply Discourse Guardian profile visibility before persistence or serialization. The current-user read endpoint derives its target from `current_user` and never records a visit while loading Community history.

The online response keeps the established `users`, `count`, `window_minutes`, and `generated_at` fields and adds `total_count`, `remaining_count`, and `limit` so clients can distinguish the complete eligible presence snapshot from the configured list cap.

## Version 1.9.0 Highlights

- Added a reactive **Needs your attention** summary above the existing personal shortcut grid using only the already-loaded message, notification, and draft counts from Discourse current-user state.
- The summary renders direct links only for nonzero categories and switches to a translated caught-up state when all three counts reach zero.
- Added mobile/small-screen in-page section navigation for **Your space**, **Online**, and **Visitors**; the helper navigation disappears from medium widths upward and never replaces core Discourse navigation.
- Added stable section anchors and scroll offsets so mobile jumps land cleanly while preserving the existing responsive dashboard composition.
- Expanded acceptance coverage for attention aggregation, live current-user updates, caught-up behavior, exact section anchors, and the absence of extra Community presence/visitor requests.
- Added no controller, route, serializer, setting, migration, persistence, Guardian, PresenceChannel, authorization, polling, or tracking-contract change.

## Version 1.8.0 Highlights

- Expanded **Your space** from four to six native Discourse destinations by adding **Notifications** and **Drafts**.
- Added attention badges to Messages, Notifications, and Drafts using `new_personal_messages_notifications_count`, `all_unread_notifications_count`, and `draft_count` from the existing current-user payload.
- Badge values follow current-user state updates and disappear when their count reaches zero without reloading Community presence or visitor data.
- Rebalanced the responsive shortcut grid to one column on mobile, two columns from small widths, and three columns from medium widths for a stable six-card layout.
- Added acceptance coverage for exact authenticated-user routes, current-user badge updates, zero-count badge removal, and the absence of extra Community requests.
- Added no controller, route, serializer, setting, migration, persistence, Guardian, PresenceChannel, authorization, polling, or tracking-contract change.

## Version 1.7.0 Highlights

- Added a responsive **Your space** personal action center above the Community dashboard.
- Added native shortcuts to the signed-in user's profile, `/my/activity`, `/my/messages`, and the core user bookmark route.
- Uses Discourse's existing current-user service only to build user-specific profile/bookmark paths; rendering the action center performs no additional request.
- Keeps posts, messages, bookmarks, and profile data owned by core Discourse instead of creating duplicate Community APIs or state.
- Added mobile-first one/two/four-column action-card styling using Discourse theme variables and viewport helpers.
- Added acceptance coverage proving the shortcuts resolve to the authenticated user and do not trigger extra presence/visitor requests.
- Added no controller, route, serializer, setting, migration, persistence, Guardian, PresenceChannel, authorization, or tracking-contract change.

## Version 1.6.0 Highlights

- Added client-side online-member sorting with **Most recent**, **Name**, and **Username** modes; the default keeps the server-provided presence order unchanged.
- Added **Comfortable** and **Compact** density controls for the dashboard without introducing a preference API, persistence change, or extra data request.
- Added dashboard-wide partial/full refresh feedback so users can distinguish one-panel failure from a complete refresh failure while previous successful data remains visible.
- Added responsive styling for sorting and density controls using Discourse theme variables and viewport helpers.
- Expanded acceptance coverage to prove sorting and density stay client-side and to verify partial refresh recovery.
- Added no controller, route, serializer, setting, migration, persistence, Guardian, PresenceChannel, authorization, or tracking-contract change.

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
