import { visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Crimson Community", function (needs) {
  needs.user();
  needs.settings({ crimson_community_enabled: true });
  needs.pretender((server, helper) => {
    server.get("/crimson-community/online.json", () =>
      helper.response({
        users: [
          {
            id: 42,
            username: "community-member",
            name: "Community Member",
            avatar_template: "/letter_avatar_proxy/v4/letter/c/8491ac/{size}.png",
            last_seen_at: "2026-08-31T00:00:00.000Z",
          },
        ],
        count: 1,
        total_count: 2,
        remaining_count: 1,
        limit: 1,
        window_minutes: 5,
        generated_at: "2026-08-31T00:00:00.000Z",
      })
    );
  });

  test("renders the native community snapshot", async function (assert) {
    await visit("/community");

    assert.dom(".crimson-community-page").exists();
    assert.dom(".crimson-community-summary__item").exists({ count: 3 });
    assert.dom(".crimson-community-member-row").exists({ count: 1 });
    assert.dom(".crimson-community-privacy-note").exists();
    assert.dom(".crimson-community-members__more").exists();
  });
});
