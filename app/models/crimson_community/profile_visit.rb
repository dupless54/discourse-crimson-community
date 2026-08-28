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

# == Schema Information
#
# Table name: crimson_community_profile_visits
#
#  id              :bigint           not null, primary key
#  last_visited_at :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  profile_user_id :integer          not null
#  visitor_user_id :integer          not null
#
# Indexes
#
#  idx_crimson_profile_visits_recent   (profile_user_id,last_visited_at)
#  idx_crimson_profile_visits_unique   (profile_user_id,visitor_user_id) UNIQUE
#  idx_crimson_profile_visits_visitor  (visitor_user_id)
#
