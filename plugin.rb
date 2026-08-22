# frozen_string_literal: true

# name: discourse-crimson-community
# about: Provides live online members and profile-visitor history for the senin.me Crimson Channels theme.
# version: 1.0.2
# authors: TSKEliteForces
# url: https://github.com/TSKEliteForces/discourse-crimson-community
# required_version: 3.3.0

enabled_site_setting :crimson_community_enabled

module ::CrimsonCommunity
  PLUGIN_NAME = "discourse-crimson-community"
  ONLINE_CHANNEL = "/crimson-community/online"

  def self.visible_in_presence?(user)
    return false if user.blank? || user.id.to_i < 1

    option = user.user_option
    hidden = option.respond_to?(:hide_presence) && option.hide_presence
    !hidden
  end
end

after_initialize do
  require_relative "lib/crimson_community/user_presenter"
  require_relative "app/controllers/crimson_community/presence_controller"
  require_relative "app/controllers/crimson_community/profile_visits_controller"

  register_presence_channel_prefix("crimson-community") do |channel_name|
    next unless channel_name == CrimsonCommunity::ONLINE_CHANNEL

    config =
      PresenceChannel::Config.new(
        timeout: SiteSetting.crimson_online_window_minutes.to_i.clamp(1, 30) * 60,
      )
    config.allowed_group_ids = [::Group::AUTO_GROUPS[:trust_level_0]]
    config.count_only = false
    config
  end

  on(:user_seen) do |user|
    next unless SiteSetting.crimson_community_enabled
    next unless CrimsonCommunity.visible_in_presence?(user)

    PresenceChannel.new(CrimsonCommunity::ONLINE_CHANNEL).present(
      user_id: user.id,
      client_id: "seen",
    )
  rescue PresenceChannel::InvalidAccess
    # The channel can be unavailable briefly while a setting is being changed.
  end

  Discourse::Application.routes.append do
    defaults format: :json do
      get "/crimson-community/online" => "crimson_community/presence#index"
      get "/crimson-community/profile-visits/:username" => "crimson_community/profile_visits#index"
      post "/crimson-community/profile-visits/:username" => "crimson_community/profile_visits#create"
    end
  end

  # Discourse's profile page and user-card payloads can differ between core
  # versions. Expose one stable, plugin-owned field so the theme can always
  # reuse the member's uploaded profile cover in the compact user card.
  %i[user user_card].each do |serializer_name|
    add_to_serializer(serializer_name, :crimson_profile_background_url) do
      object.user_profile&.profile_background_upload&.url
    end
  end

  add_to_serializer(
    :site,
    :crimson_online_state,
    include_condition: -> do
      @crimson_online_channel ||=
        PresenceChannel.new(CrimsonCommunity::ONLINE_CHANNEL)
      @crimson_online_channel.can_view?(user_id: scope.user&.id)
    end,
  ) do
    @crimson_online_channel ||=
      PresenceChannel.new(CrimsonCommunity::ONLINE_CHANNEL)
    PresenceChannelStateSerializer.new(@crimson_online_channel.state, root: nil)
  end
end
