import { click, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

let onlineRequestCount = 0;
let visitorRequestCount = 0;

function onlineSnapshot(refreshed = false) {
  return {
    users: [
      {
        id: refreshed ? 72 : 71,
        username: refreshed ? "dashboard-refreshed" : "dashboard-member",
        name: refreshed ? "Dashboard Refreshed" : "Dashboard Member",
        avatar_template: "/letter_avatar_proxy/v4/letter/d/8491ac/{size}.png",
        last_seen_at: refreshed
          ? "2026-08-31T00:10:00.000Z"
          : "2026-08-31T00:00:00.000Z",
      },
    ],
    count: 1,
    total_count: 1,
    remaining_count: 0,
    limit: 24,
    window_minutes: 5,
    generated_at: refreshed
      ? "2026-08-31T00:10:00.000Z"
      : "2026-08-31T00:00:00.000Z",
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
  const users = refreshed ? [visitorUser(9)] : Array.from({ length: 8 }, (_, index) => visitorUser(index + 1));

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

acceptance("Crimson Community dashboard", function (needs) {
  needs.user();
  needs.settings({ crimson_community_enabled: true });
  needs.pretender((server, helper) => {
    server.get("/crimson-community/online.json", () => {
      onlineRequestCount += 1;
      return helper.response(onlineSnapshot(onlineRequestCount > 1));
    });

    server.get("/crimson-community/profile-visits.json", () => {
      visitorRequestCount += 1;
      return helper.response(visitorSnapshot(visitorRequestCount > 1));
    });
  });

  test("renders freshness metadata and a compact visitor preview", async function (assert) {
    onlineRequestCount = 0;
    visitorRequestCount = 0;

    await visit("/community");

    assert.dom("[data-test-community-dashboard]").exists();
    assert.dom("[data-test-community-online-updated]").exists();
    assert.dom("[data-test-community-visitors-updated]").exists();
    assert.dom(".crimson-community-visitor-row").exists({ count: 6 });
    assert.dom("[data-test-community-visitors-toggle]").exists();

    await click("[data-test-community-visitors-toggle]");

    assert.dom(".crimson-community-visitor-row").exists({ count: 8 });

    await click("[data-test-community-visitors-toggle]");

    assert.dom(".crimson-community-visitor-row").exists({ count: 6 });
  });

  test("refreshes presence and visitor history together", async function (assert) {
    onlineRequestCount = 0;
    visitorRequestCount = 0;

    await visit("/community");
    await click("[data-test-community-refresh-all]");

    assert.strictEqual(onlineRequestCount, 2, "refreshes online presence once");
    assert.strictEqual(visitorRequestCount, 2, "refreshes profile visitors once");
    assert.dom(".crimson-community-member-row").includesText("Dashboard Refreshed");
    assert.dom(".crimson-community-visitor-row").exists({ count: 1 });
    assert.dom(".crimson-community-visitor-row").includesText("Dashboard Visitor 9");
  });
});
