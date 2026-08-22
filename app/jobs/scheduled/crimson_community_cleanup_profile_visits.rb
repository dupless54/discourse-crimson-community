# frozen_string_literal: true

module ::Jobs
  class CrimsonCommunityCleanupProfileVisits < ::Jobs::Scheduled
    every 1.day

    def execute(_args)
      return unless SiteSetting.crimson_community_enabled

      retention_days =
        SiteSetting.crimson_profile_visitors_retention_days.to_i.clamp(1, 365)

      CrimsonCommunity::ProfileVisit
        .where("last_visited_at < ?", retention_days.days.ago)
        .delete_all
    end
  end
end
