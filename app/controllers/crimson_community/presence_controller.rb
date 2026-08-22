# frozen_string_literal: true

module ::CrimsonCommunity
  class PresenceController < ::ApplicationController
    requires_plugin CrimsonCommunity::PLUGIN_NAME
    requires_login

    def index
      raise Discourse::NotFound unless SiteSetting.crimson_community_enabled

      window_minutes = SiteSetting.crimson_online_window_minutes.to_i.clamp(1, 30)
      limit = SiteSetting.crimson_online_members_limit.to_i.clamp(4, 100)
      users =
        User
          .real
          .activated
          .not_staged
          .not_suspended
          .where("last_seen_at >= ?", window_minutes.minutes.ago)
          .order(last_seen_at: :desc)
          .limit(limit)

      render json: {
               users: users.map { |user| CrimsonCommunity::UserPresenter.serialize(user) },
               window_minutes: window_minutes,
               generated_at: Time.zone.now,
             }
    end
  end
end
