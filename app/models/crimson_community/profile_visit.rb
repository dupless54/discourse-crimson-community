# frozen_string_literal: true

module ::CrimsonCommunity
  class ProfileVisit < ::ActiveRecord::Base
    self.table_name = "crimson_community_profile_visits"

    belongs_to :profile_user, class_name: "::User"
    belongs_to :visitor, class_name: "::User"

    validates :profile_user_id, presence: true
    validates :visitor_user_id, presence: true, uniqueness: { scope: :profile_user_id }
    validates :last_visited_at, presence: true
  end
end
