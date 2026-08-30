import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";
import { i18n } from "discourse-i18n";

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
      ajax("/crimson-community/online.json"),
      this.loadProfileVisitors(),
    ]);

    return { ...presence, profile_visitors: profileVisitors };
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
