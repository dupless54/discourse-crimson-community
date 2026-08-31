import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";
import { i18n } from "discourse-i18n";

const UNAVAILABLE_PRESENCE = {
  users: [],
  count: 0,
  total_count: 0,
  remaining_count: 0,
  window_minutes: 0,
  unavailable: true,
};

export default class CrimsonCommunityRoute extends DiscourseRoute {
  @service currentUser;

  beforeModel(transition) {
    if (!this.currentUser) {
      transition.send("showLogin");
      return;
    }
  }

  async model() {
    const [presence, profileVisitors] = await Promise.all([
      this.loadPresence(),
      this.loadProfileVisitors(),
    ]);

    return { ...presence, profile_visitors: profileVisitors };
  }

  async loadPresence() {
    try {
      return await ajax("/crimson-community/online.json");
    } catch {
      // Presence is an enhancement to the Community page. A transient 429 or
      // service failure must not reject the whole route and make native forum
      // navigation unusable; the page can render an empty snapshot and retry
      // through its existing refresh action.
      return { ...UNAVAILABLE_PRESENCE };
    }
  }

  async loadProfileVisitors() {
    try {
      return await ajax("/crimson-community/profile-visits.json");
    } catch {
      return {
        enabled: null,
        unavailable: true,
        users: [],
        count: 0,
      };
    }
  }

  titleToken() {
    return i18n("crimson_community.page.title");
  }
}
