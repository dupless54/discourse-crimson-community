# frozen_string_literal: true

# name: discourse-crimson-community
# about: Provides recent online members and profile-visitor history for the senin.me Crimson Channels theme.
# version: 1.0.0
# authors: TSKEliteForces
# url: https://github.com/TSKEliteForces/discourse-crimson-community
# required_version: 3.3.0

enabled_site_setting :crimson_community_enabled

module ::CrimsonCommunity
  PLUGIN_NAME = "discourse-crimson-community"
end

after_initialize do
  require_relative "app/models/crimson_community/profile_visit"
  require_relative "lib/crimson_community/user_presenter"
  require_relative "app/controllers/crimson_community/presence_controller"
  require_relative "app/controllers/crimson_community/profile_visits_controller"
  require_relative "app/jobs/scheduled/crimson_community_cleanup_profile_visits"

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

  on(:user_destroyed) do |user|
    CrimsonCommunity::ProfileVisit
      .where(profile_user_id: user.id)
      .or(CrimsonCommunity::ProfileVisit.where(visitor_user_id: user.id))
      .delete_all
  end
end
