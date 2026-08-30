import { click, fillIn, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

let onlineRequestCount = 0;
let failRefresh = false;

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
  });

  test("renders the native community snapshot", async function (assert) {
    onlineRequestCount = 0;
    failRefresh = false;

    await visit("/community");

    assert.dom(".crimson-community-page").exists();
    assert.dom(".crimson-community-summary__item").exists({ count: 3 });
    assert.dom(".crimson-community-member-row").exists({ count: 2 });
    assert.dom(".crimson-community-privacy-note").exists();
    assert.dom(".crimson-community-members__more").exists();
    assert.dom("[data-test-community-search]").exists();
    assert.dom("[data-test-community-refresh]").exists();
  });

  test("filters online members by name and username", async function (assert) {
    onlineRequestCount = 0;
    failRefresh = false;

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
    onlineRequestCount = 0;
    failRefresh = false;

    await visit("/community");
    await click("[data-test-community-refresh]");

    assert.strictEqual(onlineRequestCount, 2, "requests a fresh snapshot once");
    assert.dom(".crimson-community-member-row").exists({ count: 1 });
    assert.dom(".crimson-community-member-row").includesText("Refreshed Member");
    assert.dom(".crimson-community-summary__item:first-child strong").hasText("1");
    assert.dom(".crimson-community-members__more").doesNotExist();
  });

  test("preserves the previous snapshot when refresh fails", async function (assert) {
    onlineRequestCount = 0;
    failRefresh = true;

    await visit("/community");
    await click("[data-test-community-refresh]");

    assert.strictEqual(onlineRequestCount, 2, "attempts one refresh request");
    assert.dom(".crimson-community-member-row").exists({ count: 2 });
    assert.dom("[data-test-community-refresh-error]").exists();
  });
});
