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

  model() {
    return ajax("/crimson-community/online.json");
  }

  titleToken() {
    return i18n("crimson_community.page.title");
  }
}
