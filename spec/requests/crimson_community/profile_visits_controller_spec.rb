# frozen_string_literal: true

describe CrimsonCommunity::ProfileVisitsController do
  fab!(:viewer, :user)
  fab!(:profile_user, :user)

  before do
    SiteSetting.crimson_community_enabled = true
    SiteSetting.crimson_profile_visitors_enabled = true
    sign_in(viewer)
  end

  describe "GET /crimson-community/profile-visits/:username.json" do
    it "returns the visitor list for a visible profile" do
      get "/crimson-community/profile-visits/#{profile_user.username}.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["profile_username"]).to eq(profile_user.username)
    end

    it "does not expose or record visits for a profile the viewer cannot see" do
      SiteSetting.allow_users_to_hide_profile = true
      profile_user.user_option.update!(hide_profile: true)

      expect do
        get "/crimson-community/profile-visits/#{profile_user.username}.json"
      end.not_to change {
        UserProfileView.where(user_profile_id: profile_user.user_profile.id).count
      }

      expect(response.status).to eq(403)
    end

    it "returns not found when profile visitors are disabled" do
      SiteSetting.crimson_profile_visitors_enabled = false

      get "/crimson-community/profile-visits/#{profile_user.username}.json"

      expect(response.status).to eq(404)
    end
  end

  describe "POST /crimson-community/profile-visits/:username.json" do
    it "does not record a hidden profile visit" do
      SiteSetting.allow_users_to_hide_profile = true
      profile_user.user_option.update!(hide_profile: true)

      expect do
        post "/crimson-community/profile-visits/#{profile_user.username}.json"
      end.not_to change {
        UserProfileView.where(user_profile_id: profile_user.user_profile.id).count
      }

      expect(response.status).to eq(403)
    end
  end
end
