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

      user
    end

    def record_visit!(profile_user)
      now = Time.zone.now
      visit =
        CrimsonCommunity::ProfileVisit.find_or_initialize_by(
          profile_user_id: profile_user.id,
          visitor_user_id: current_user.id,
        )

      return if visit.persisted? && visit.last_visited_at >= 1.minute.ago

      visit.last_visited_at = now
      visit.save!
    rescue ActiveRecord::RecordNotUnique
      CrimsonCommunity::ProfileVisit
        .where(profile_user_id: profile_user.id, visitor_user_id: current_user.id)
        .update_all(last_visited_at: now, updated_at: now)
    end

    def render_visitor_list(profile_user)
      limit = SiteSetting.crimson_profile_visitors_limit.to_i.clamp(4, 100)
      retention_days =
        SiteSetting.crimson_profile_visitors_retention_days.to_i.clamp(1, 365)
      visits =
        CrimsonCommunity::ProfileVisit
          .where(profile_user_id: profile_user.id)
          .where("last_visited_at >= ?", retention_days.days.ago)
          .joins(:visitor)
          .merge(User.real.activated.not_staged.not_suspended)
          .includes(:visitor)
          .order(last_visited_at: :desc)
          .limit(limit)

      users =
        visits.map do |visit|
          CrimsonCommunity::UserPresenter.serialize(
            visit.visitor,
            last_visited_at: visit.last_visited_at,
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
