import { click, select, settled, visit } from "@ember/test-helpers";
import { test } from "qunit";
import {
  acceptance,
  updateCurrentUser,
} from "discourse/tests/helpers/qunit-helpers";

let onlineRequestCount = 0;
let visitorRequestCount = 0;
let failOnlineRefresh = false;
let failVisitorRefresh = false;

function initialOnlineUsers() {
  return [
    {
      id: 71,
      username: "zeta-user",
      name: "Zulu Member",
      avatar_template: "/letter_avatar_proxy/v4/letter/z/8491ac/{size}.png",
      last_seen_at: "2026-08-31T00:03:00.000Z",
    },
    {
      id: 72,
      username: "middle-user",
      name: "Alpha Member",
      avatar_template: "/letter_avatar_proxy/v4/letter/a/8491ac/{size}.png",
      last_seen_at: "2026-08-31T00:02:00.000Z",
    },
    {
      id: 73,
      username: "alpha-user",
      name: "Middle Member",
      avatar_template: "/letter_avatar_proxy/v4/letter/m/8491ac/{size}.png",
      last_seen_at: "2026-08-31T00:01:00.000Z",
    },
  ];
}

function onlineSnapshot(refreshed = false) {
  const users = refreshed
    ? [
        {
          id: 74,
          username: "dashboard-refreshed",
          name: "Dashboard Refreshed",
          avatar_template: "/letter_avatar_proxy/v4/letter/d/8491ac/{size}.png",
          last_seen_at: "2026-08-31T00:10:00.000Z",
        },
      ]
    : initialOnlineUsers();

  return {
    users,
    count: users.length,
    total_count: users.length,
    remaining_count: 0,
    limit: 24,
    window_minutes: 5,
    generated_at: refreshed
      ? "2026-08-31T00:10:00.000Z"
      : "2026-08-31T00:03:00.000Z",
  };
}

function visitorUser(id) {
  return {
    id: 80 + id,
    username: `dashboard-visitor-${id}`,
    name: `Dashboard Visitor ${id}`,
    avatar_template: "/letter_avatar_proxy/v4/letter/v/8491ac/{size}.png",
    last_seen_at: "2026-08-31T00:00:00.000Z",
    last_visited_at: `2026-08-31T00:0${Math.min(id, 9)}:00.000Z`,
  };
}

function visitorSnapshot(refreshed = false) {
  const users = refreshed
    ? [visitorUser(9)]
    : Array.from({ length: 8 }, (_, index) => visitorUser(index + 1));

  return {
    enabled: true,
    profile_username: "eviltrout",
    users,
    count: users.length,
    limit: 24,
    retention_days: 90,
    generated_at: refreshed
      ? "2026-08-31T00:10:00.000Z"
      : "2026-08-31T00:00:00.000Z",
  };
}

function resetRequests() {
  onlineRequestCount = 0;
  visitorRequestCount = 0;
  failOnlineRefresh = false;
  failVisitorRefresh = false;
}

acceptance("Crimson Community dashboard", function (needs) {
  needs.user({
    all_unread_notifications_count: 7,
    new_personal_messages_notifications_count: 3,
    draft_count: 2,
  });
  needs.settings({ crimson_community_enabled: true });
  needs.pretender((server, helper) => {
    server.get("/crimson-community/online.json", () => {
      onlineRequestCount += 1;

      if (failOnlineRefresh && onlineRequestCount > 1) {
        return helper.response(500, {});
      }

      return helper.response(onlineSnapshot(onlineRequestCount > 1));
    });

    server.get("/crimson-community/profile-visits.json", () => {
      visitorRequestCount += 1;

      if (failVisitorRefresh && visitorRequestCount > 1) {
        return helper.response(500, {});
      }

      return helper.response(visitorSnapshot(visitorRequestCount > 1));
    });
  });

  test("renders freshness metadata and a compact visitor preview", async function (assert) {
    resetRequests();

    await visit("/community");

    assert.dom("[data-test-community-dashboard]").exists();
    assert.dom("[data-test-community-dashboard]").hasAttribute("data-density", "comfortable");
    assert.dom("[data-test-community-online-updated]").exists();
    assert.dom("[data-test-community-visitors-updated]").exists();
    assert.dom(".crimson-community-visitor-row").exists({ count: 6 });
    assert.dom("[data-test-community-visitors-toggle]").exists();

    await click("[data-test-community-visitors-toggle]");

    assert.dom(".crimson-community-visitor-row").exists({ count: 8 });

    await click("[data-test-community-visitors-toggle]");

    assert.dom(".crimson-community-visitor-row").exists({ count: 6 });
  });

  test("renders attention-aware personal shortcuts without another request", async function (assert) {
    resetRequests();

    await visit("/community");

    assert.dom("[data-test-community-actions]").exists();
    assert.dom("[data-test-community-action-profile]").hasAttribute("href", "/u/eviltrout");
    assert.dom("[data-test-community-action-posts]").hasAttribute("href", "/my/activity");
    assert.dom("[data-test-community-action-messages]").hasAttribute("href", "/my/messages");
    assert.dom("[data-test-community-action-notifications]").hasAttribute("href", "/u/eviltrout/notifications");
    assert
      .dom("[data-test-community-action-bookmarks]")
      .hasAttribute("href", "/u/eviltrout/activity/bookmarks");
    assert.dom("[data-test-community-action-drafts]").hasAttribute("href", "/u/eviltrout/activity/drafts");
    assert.dom("[data-test-community-action-messages-badge]").hasText("3");
    assert.dom("[data-test-community-action-notifications-badge]").hasText("7");
    assert.dom("[data-test-community-action-drafts-badge]").hasText("2");
    assert.strictEqual(onlineRequestCount, 1, "personal shortcuts do not reload presence");
    assert.strictEqual(visitorRequestCount, 1, "personal shortcuts do not reload visitors");
  });

  test("updates attention badges from current-user state without Community requests", async function (assert) {
    resetRequests();

    await visit("/community");

    updateCurrentUser({
      all_unread_notifications_count: 9,
      new_personal_messages_notifications_count: 4,
      draft_count: 5,
    });
    await settled();

    assert.dom("[data-test-community-action-messages-badge]").hasText("4");
    assert.dom("[data-test-community-action-notifications-badge]").hasText("9");
    assert.dom("[data-test-community-action-drafts-badge]").hasText("5");
    assert.strictEqual(onlineRequestCount, 1, "attention changes do not reload presence");
    assert.strictEqual(visitorRequestCount, 1, "attention changes do not reload visitors");

    updateCurrentUser({
      all_unread_notifications_count: 0,
      new_personal_messages_notifications_count: 0,
      draft_count: 0,
    });
    await settled();

    assert.dom("[data-test-community-action-messages-badge]").doesNotExist();
    assert.dom("[data-test-community-action-notifications-badge]").doesNotExist();
    assert.dom("[data-test-community-action-drafts-badge]").doesNotExist();
  });

  test("sorts the authorized online snapshot without another request", async function (assert) {
    resetRequests();

    await visit("/community");

    assert.dom(".crimson-community-member-row:first-child").includesText("Zulu Member");

    await select("[data-test-community-sort]", "name");

    assert.dom(".crimson-community-member-row:first-child").includesText("Alpha Member");
    assert.strictEqual(onlineRequestCount, 1, "name sorting stays client-side");

    await select("[data-test-community-sort]", "username");

    assert.dom(".crimson-community-member-row:first-child").includesText("Middle Member");
    assert.strictEqual(onlineRequestCount, 1, "username sorting stays client-side");
  });

  test("switches dashboard density without loading new data", async function (assert) {
    resetRequests();

    await visit("/community");
    await click("[data-test-community-density-compact]");

    assert.dom("[data-test-community-dashboard]").hasAttribute("data-density", "compact");
    assert.dom("[data-test-community-density-compact]").hasAttribute("aria-pressed", "true");
    assert.strictEqual(onlineRequestCount, 1, "density does not reload presence");
    assert.strictEqual(visitorRequestCount, 1, "density does not reload visitors");

    await click("[data-test-community-density-comfortable]");

    assert.dom("[data-test-community-dashboard]").hasAttribute("data-density", "comfortable");
  });

  test("refreshes presence and visitor history together", async function (assert) {
    resetRequests();

    await visit("/community");
    await click("[data-test-community-refresh-all]");

    assert.strictEqual(onlineRequestCount, 2, "refreshes online presence once");
    assert.strictEqual(visitorRequestCount, 2, "refreshes profile visitors once");
    assert.dom(".crimson-community-member-row").includesText("Dashboard Refreshed");
    assert.dom(".crimson-community-visitor-row").exists({ count: 1 });
    assert.dom(".crimson-community-visitor-row").includesText("Dashboard Visitor 9");
    assert.dom("[data-test-community-refresh-partial]").doesNotExist();
  });

  test("reports a partial dashboard refresh and preserves failed panel data", async function (assert) {
    resetRequests();
    failVisitorRefresh = true;

    await visit("/community");
    await click("[data-test-community-refresh-all]");

    assert.strictEqual(onlineRequestCount, 2, "refreshes online presence");
    assert.strictEqual(visitorRequestCount, 2, "attempts visitor refresh");
    assert.dom("[data-test-community-refresh-partial]").exists();
    assert.dom(".crimson-community-member-row").includesText("Dashboard Refreshed");
    assert.dom(".crimson-community-visitor-row").exists({ count: 6 });
    assert.dom(".crimson-community-visitor-row:first-child").includesText("Dashboard Visitor 1");
    assert.dom("[data-test-community-visitors-refresh-error]").exists();
  });
});
