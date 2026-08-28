import { withPluginApi } from "discourse/lib/plugin-api";
import { i18n } from "discourse-i18n";

export default {
  name: "crimson-community-sidebar",

  initialize() {
    withPluginApi((api) => {
      const currentUser = api.getCurrentUser();
      const siteSettings = api.container.lookup("service:site-settings");

      if (!currentUser || !siteSettings.crimson_community_enabled) {
        return;
      }

      api.addCommunitySectionLink(
        {
          name: "crimson-community",
          route: "crimsonCommunity",
          title: i18n("crimson_community.page.title"),
          text: i18n("crimson_community.page.title"),
          icon: "users",
        },
        true
      );
    });
  },
};
