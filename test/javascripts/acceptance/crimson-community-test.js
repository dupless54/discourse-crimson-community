import { click, fillIn, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

let onlineRequestCount = 0;
let visitorRequestCount = 0;
let failRefresh = false;
let failVisitorRefresh = false;
let failVisitorInitialLoad = false;
let visitorsDisabled = false;

function initialSnapshot() {
  return {
    users: [
      {
        id: 42,
        username: "community-member",
        name: "Community Member",
        avatar_template: "/letter_avatar_proxy/v4/letter/c/8491ac/{size}.png",
        last_seen_at: "2026-08-31T00:00:00.000Z",
      },
      {
        id: 43,
        username: "second-member",
        name: "Second Person",
        avatar_template: "/letter_avatar_proxy/v4/letter/s/8491ac/{size}.png",
        last_seen_at: "2026-08-31T00:01:00.000Z",
      },
    ],
    count: 2,
    total_count: 3,
    remaining_count: 1,
    limit: 2,
    window_minutes: 5,
    generated_at: "2026-08-31T00:01:00.000Z",
  };
}

function refreshedSnapshot() {
  return {
    users: [
      {
        id: 44,
        username: "refreshed-member",
        name: "Refreshed Member",
        avatar_template: "/letter_avatar_proxy/v4/letter/r/8491ac/{size}.png",
        last_seen_at: "2026-08-31T00:02:00.000Z",
      },
    ],
    count: 1,
    total_count: 1,
    remaining_count: 0,
    limit: 2,
    window_minutes: 5,
    generated_at: "2026-08-31T00:02:00.000Z",
  };
}

function initialVisitors() {
  return {
    enabled: true,
    profile_username: "eviltrout",
    users: [
      {
        id: 51,
        username: "first-visitor",
        name: "First Visitor",
        avatar_template: "/letter_avatar_proxy/v4/letter/f/8491ac/{size}.png",
        last_seen_at: "2026-08-31T00:00:00.000Z",
        last_visited_at: "2026-08-31T00:01:00.000Z",
      },
      {
        id: 52,
        username: "second-visitor",
        name: "Second Visitor",
        avatar_template: "/letter_avatar_proxy/v4/letter/s/8491ac/{size}.png",
        last_seen_at: "2026-08-31T00:00:00.000Z",
        last_visited_at: "2026-08-31T00:00:00.000Z",
      },
    ],
    count: 2,
    limit: 24,
    retention_days: 90,
    generated_at: "2026-08-31T00:01:00.000Z",
  };
}

function refreshedVisitors() {
  return {
    enabled: true,
    profile_username: "eviltrout",
    users: [
      {
        id: 53,
        username: "new-visitor",
        name: "New Visitor",
        avatar_template: "/letter_avatar_proxy/v4/letter/n/8491ac/{size}.png",
        last_seen_at: "2026-08-31T00:02:00.000Z",
        last_visited_at: "2026-08-31T00:02:00.000Z",
      },
    ],
    count: 1,
    limit: 24,
    retention_days: 90,
    generated_at: "2026-08-31T00:02:00.000Z",
  };
}

function resetRequests() {
  onlineRequestCount = 0;
  visitorRequestCount = 0;
  failRefresh = false;
  failVisitorRefresh = false;
  failVisitorInitialLoad = false;
  visitorsDisabled = false;
}

acceptance("Crimson Community", function (needs) {
  needs.user();
  needs.settings({ crimson_community_enabled: true });
  needs.pretender((server, helper) => {
    server.get("/crimson-community/online.json", () => {
      onlineRequestCount += 1;

      if (failRefresh && onlineRequestCount > 1) {
        return helper.response(500, {});
      }

      return helper.response(
        onlineRequestCount > 1 ? refreshedSnapshot() : initialSnapshot()
      );
    });

    server.get("/crimson-community/profile-visits.json", () => {
      visitorRequestCount += 1;

      if (failVisitorInitialLoad && visitorRequestCount === 1) {
        return helper.response(500, {});
      }

      if (failVisitorRefresh && visitorRequestCount > 1) {
        return helper.response(500, {});
      }

      if (visitorsDisabled) {
        return helper.response({
          enabled: false,
          profile_username: "eviltrout",
          users: [],
          count: 0,
          generated_at: "2026-08-31T00:01:00.000Z",
        });
      }

      return helper.response(
        visitorRequestCount > 1 ? refreshedVisitors() : initialVisitors()
      );
    });
  });

  test("renders the native community snapshot and visitor history", async function (assert) {
    resetRequests();

    await visit("/community");

    assert.dom(".crimson-community-page").exists();
    assert.dom(".crimson-community-summary__item").exists({ count: 3 });
    assert.dom(".crimson-community-member-row").exists({ count: 2 });
    assert.dom(".crimson-community-privacy-note").exists();
    assert.dom(".crimson-community-members__more").exists();
    assert.dom("[data-test-community-search]").exists();
    assert.dom("[data-test-community-refresh]").exists();
    assert.dom("[data-test-community-visitors]").exists();
    assert.dom(".crimson-community-visitor-row").exists({ count: 2 });
    assert.dom(".crimson-community-visitor-row").includesText("First Visitor");
    assert.dom("[data-test-community-visitors-refresh]").exists();
  });

  test("filters online members by name and username", async function (assert) {
    resetRequests();

    await visit("/community");
    await fillIn("[data-test-community-search]", "second");

    assert.dom(".crimson-community-member-row").exists({ count: 1 });
    assert.dom(".crimson-community-member-row").includesText("Second Person");

    await fillIn("[data-test-community-search]", "does-not-exist");

    assert.dom(".crimson-community-member-row").doesNotExist();
    assert.dom("[data-test-community-search-empty]").exists();

    await click("[data-test-community-search-clear]");

    assert.dom("[data-test-community-search]").hasValue("");
    assert.dom(".crimson-community-member-row").exists({ count: 2 });
  });

  test("refreshes the authorized online snapshot", async function (assert) {
    resetRequests();

    await visit("/community");
    await click("[data-test-community-refresh]");

    assert.strictEqual(onlineRequestCount, 2, "requests a fresh snapshot once");
    assert.strictEqual(visitorRequestCount, 1, "does not refresh visitor history implicitly");
    assert.dom(".crimson-community-member-row").exists({ count: 1 });
    assert.dom(".crimson-community-member-row").includesText("Refreshed Member");
    assert.dom(".crimson-community-summary__item:first-child strong").hasText("1");
    assert.dom(".crimson-community-members__more").doesNotExist();
  });

  test("preserves the previous snapshot when online refresh fails", async function (assert) {
    resetRequests();
    failRefresh = true;

    await visit("/community");
    await click("[data-test-community-refresh]");

    assert.strictEqual(onlineRequestCount, 2, "attempts one refresh request");
    assert.dom(".crimson-community-member-row").exists({ count: 2 });
    assert.dom("[data-test-community-refresh-error]").exists();
  });

  test("refreshes profile visitors independently", async function (assert) {
    resetRequests();

    await visit("/community");
    await click("[data-test-community-visitors-refresh]");

    assert.strictEqual(visitorRequestCount, 2, "requests fresh visitor history once");
    assert.strictEqual(onlineRequestCount, 1, "does not refresh online presence implicitly");
    assert.dom(".crimson-community-visitor-row").exists({ count: 1 });
    assert.dom(".crimson-community-visitor-row").includesText("New Visitor");
    assert.dom(".crimson-community-visitors__count").hasText("1");
  });

  test("preserves previous visitor history when visitor refresh fails", async function (assert) {
    resetRequests();
    failVisitorRefresh = true;

    await visit("/community");
    await click("[data-test-community-visitors-refresh]");

    assert.strictEqual(visitorRequestCount, 2, "attempts one visitor refresh");
    assert.dom(".crimson-community-visitor-row").exists({ count: 2 });
    assert.dom("[data-test-community-visitors-refresh-error]").exists();
  });

  test("shows the disabled profile visitor state", async function (assert) {
    resetRequests();
    visitorsDisabled = true;

    await visit("/community");

    assert.dom("[data-test-community-visitors-disabled]").exists();
    assert.dom(".crimson-community-visitor-row").doesNotExist();
    assert.dom("[data-test-community-visitors-refresh]").doesNotExist();
  });

  test("keeps Community usable when visitor history fails to load", async function (assert) {
    resetRequests();
    failVisitorInitialLoad = true;

    await visit("/community");

    assert.dom("[data-test-community-visitors-unavailable]").exists();
    assert.dom("[data-test-community-visitors-retry]").exists();
    assert.dom(".crimson-community-member-row").exists({ count: 2 });
  });
});
