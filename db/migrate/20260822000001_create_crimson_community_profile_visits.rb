# frozen_string_literal: true

class CreateCrimsonCommunityProfileVisits < ActiveRecord::Migration[7.0]
  def change
    create_table :crimson_community_profile_visits do |table|
      table.integer :profile_user_id, null: false
      table.integer :visitor_user_id, null: false
      table.datetime :last_visited_at, null: false
      table.timestamps null: false
    end

    add_index :crimson_community_profile_visits,
              %i[profile_user_id visitor_user_id],
              unique: true,
              name: "idx_crimson_profile_visits_unique"
    add_index :crimson_community_profile_visits,
              %i[profile_user_id last_visited_at],
              name: "idx_crimson_profile_visits_recent"
    add_index :crimson_community_profile_visits,
              :visitor_user_id,
              name: "idx_crimson_profile_visits_visitor"
  end
end
