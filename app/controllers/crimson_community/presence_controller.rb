# frozen_string_literal: true

module ::CrimsonCommunity
  class PresenceController < ::ApplicationController
    requires_plugin CrimsonCommunity::PLUGIN_NAME
    requires_login

    def index
      raise Discourse::NotFound unless SiteSetting.crimson_community_enabled

      window_minutes = SiteSetting.crimson_online_window_minutes.to_i.clamp(1, 30)
      limit = SiteSetting.crimson_online_members_limit.to_i.clamp(4, 100)
      channel = PresenceChannel.new(CrimsonCommunity::ONLINE_CHANNEL)
      raise Discourse::NotFound unless channel.can_view?(user_id: current_user.id)

      if CrimsonCommunity.visible_in_presence?(current_user)
        channel.present(user_id: current_user.id, client_id: "seen")
      end

      snapshot = CrimsonCommunity::PresenceSnapshot.new(channel)
      users = snapshot.ordered_users.first(limit)
      total_count = snapshot.total_count

      response.headers["Cache-Control"] = "no-store"
      render json: {
               users: users.map { |user| CrimsonCommunity::UserPresenter.serialize(user) },
               count: users.length,
               total_count: total_count,
               remaining_count: [total_count - users.length, 0].max,
               limit: limit,
               window_minutes: window_minutes,
               generated_at: Time.zone.now,
             }
    rescue PresenceChannel::InvalidAccess
      raise Discourse::NotFound
    end
  end
end
