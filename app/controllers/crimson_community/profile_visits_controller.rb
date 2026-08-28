# frozen_string_literal: true

module ::CrimsonCommunity
  class ProfileVisitsController < ::ApplicationController
    requires_plugin CrimsonCommunity::PLUGIN_NAME
    requires_login

    def index
      ensure_feature_enabled!
      profile_user = find_profile_user!
      # The read request is also the reliable visit signal for the theme. This
      # keeps visits working when a browser extension or an older Discourse
      # build strips the separate POST's CSRF header, and intentionally records
      # a member viewing their own profile as requested by the theme.
      record_visit!(profile_user)
      response.headers["Cache-Control"] = "no-store"
      render_visitor_list(profile_user)
    end

    def create
      ensure_feature_enabled!
      profile_user = find_profile_user!
      record_visit!(profile_user)

      response.headers["Cache-Control"] = "no-store"
      render json: success_json
    end

    private

    def ensure_feature_enabled!
      raise Discourse::NotFound unless SiteSetting.crimson_community_enabled
      raise Discourse::NotFound unless SiteSetting.crimson_profile_visitors_enabled
    end

    def find_profile_user!
      username = User.normalize_username(params[:username])
      user =
        User
          .real
          .activated
          .not_staged
          .not_suspended
          .find_by(username_lower: username)

      raise Discourse::NotFound unless user

      guardian.ensure_can_see_profile!(user)
      user
    end

    def record_visit!(profile_user)
      UserProfileView.add(
        profile_user.user_profile.id,
        request.remote_ip,
        current_user.id,
      )
    end

    def render_visitor_list(profile_user)
      limit = SiteSetting.crimson_profile_visitors_limit.to_i.clamp(4, 100)
      retention_days =
        SiteSetting.crimson_profile_visitors_retention_days.to_i.clamp(1, 365)
      visitor_rows =
        UserProfileView
          .where(user_profile_id: profile_user.user_profile.id)
          .where.not(user_id: nil)
          .where("viewed_at >= ?", retention_days.days.ago)
          .group(:user_id)
          .order(Arel.sql("MAX(viewed_at) DESC"))
          .limit(limit)
          .pluck(:user_id, Arel.sql("MAX(viewed_at)"))

      users_by_id =
        User
          .real
          .activated
          .not_staged
          .not_suspended
          .where(id: visitor_rows.map(&:first))
          .index_by(&:id)

      users =
        visitor_rows.filter_map do |visitor_id, last_visited_at|
          visitor = users_by_id[visitor_id]
          next unless visitor

          CrimsonCommunity::UserPresenter.serialize(
            visitor,
            last_visited_at: last_visited_at,
          )
        end

      render json: {
               profile_username: profile_user.username,
               users: users,
               retention_days: retention_days,
               generated_at: Time.zone.now,
             }
    end
  end
end
