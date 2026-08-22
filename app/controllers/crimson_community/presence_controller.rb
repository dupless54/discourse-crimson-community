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

      serialized_state =
        PresenceChannelStateSerializer.new(channel.state, root: nil).as_json
      state_users = serialized_state[:users] || serialized_state["users"] || []
      online_user_ids =
        state_users
          .filter_map { |user| (user[:id] || user["id"]).to_i.presence }
          .uniq

      users_by_id =
        User
          .real
          .activated
          .not_staged
          .not_suspended
          .where(id: online_user_ids)
          .index_by(&:id)
      users =
        online_user_ids
          .filter_map { |user_id| users_by_id[user_id] }
          .sort_by { |user| user.last_seen_at || Time.at(0) }
          .reverse
          .first(limit)

      response.headers["Cache-Control"] = "no-store"
      render json: {
               users: users.map { |user| CrimsonCommunity::UserPresenter.serialize(user) },
               count: users.length,
               window_minutes: window_minutes,
               generated_at: Time.zone.now,
             }
    rescue PresenceChannel::InvalidAccess
      raise Discourse::NotFound
    end
  end
end
