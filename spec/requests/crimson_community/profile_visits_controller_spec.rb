# frozen_string_literal: true

describe CrimsonCommunity::ProfileVisitsController do
  fab!(:viewer, :user)
  fab!(:profile_user, :user)
  fab!(:hidden_visitor, :user)

  before do
    SiteSetting.crimson_community_enabled = true
    SiteSetting.crimson_profile_visitors_enabled = true
    SiteSetting.hide_new_user_profiles = false
    sign_in(viewer)
  end

  describe "GET /crimson-community/profile-visits.json" do
    it "returns the current user's visitor history without recording a self visit" do
      UserProfileView.add(
        viewer.user_profile.id,
        "127.0.0.2",
        profile_user.id,
      )

      expect do
        get "/crimson-community/profile-visits.json"
      end.not_to change {
        UserProfileView.where(user_profile_id: viewer.user_profile.id).count
      }

      expect(response.status).to eq(200)
      expect(response.parsed_body["enabled"]).to eq(true)
      expect(response.parsed_body["profile_username"]).to eq(viewer.username)
      expect(response.parsed_body["users"].map { |user| user["username"] }).to include(
        profile_user.username,
      )
    end

    it "does not expose hidden visitors in the current user's history" do
      SiteSetting.allow_users_to_hide_profile = true
      UserProfileView.add(
        viewer.user_profile.id,
        "127.0.0.2",
        profile_user.id,
      )
      UserProfileView.add(
        viewer.user_profile.id,
        "127.0.0.3",
        hidden_visitor.id,
      )
      hidden_visitor.user_option.update!(hide_profile: true)

      get "/crimson-community/profile-visits.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["users"].map { |user| user["username"] }).to include(
        profile_user.username,
      )
      expect(response.parsed_body["users"].map { |user| user["username"] }).not_to include(
        hidden_visitor.username,
      )
    end

    it "returns a disabled state without visitor data when profile visitors are disabled" do
      SiteSetting.crimson_profile_visitors_enabled = false

      expect do
        get "/crimson-community/profile-visits.json"
      end.not_to change {
        UserProfileView.where(user_profile_id: viewer.user_profile.id).count
      }

      expect(response.status).to eq(200)
      expect(response.parsed_body["enabled"]).to eq(false)
      expect(response.parsed_body["profile_username"]).to eq(viewer.username)
      expect(response.parsed_body["users"]).to eq([])
      expect(response.parsed_body["count"]).to eq(0)
    end

    it "returns not found when Crimson Community is disabled" do
      SiteSetting.crimson_community_enabled = false

      get "/crimson-community/profile-visits.json"

      expect(response.status).to eq(404)
    end
  end

  describe "GET /crimson-community/profile-visits/:username.json" do
    it "returns the visitor list for a visible profile" do
      get "/crimson-community/profile-visits/#{profile_user.username}.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["profile_username"]).to eq(profile_user.username)
      expect(response.parsed_body["count"]).to eq(response.parsed_body["users"].length)
    end

    it "does not expose or record visits for a profile the viewer cannot see" do
      SiteSetting.allow_users_to_hide_profile = true
      profile_user.user_option.update!(hide_profile: true)

      expect do
        get "/crimson-community/profile-visits/#{profile_user.username}.json"
      end.not_to change {
        UserProfileView.where(user_profile_id: profile_user.user_profile.id).count
      }

      expect(response.status).to eq(404)
    end

    it "does not expose visitors whose profiles the viewer cannot see" do
      SiteSetting.allow_users_to_hide_profile = true
      UserProfileView.add(
        profile_user.user_profile.id,
        "127.0.0.2",
        hidden_visitor.id,
      )
      hidden_visitor.user_option.update!(hide_profile: true)

      get "/crimson-community/profile-visits/#{profile_user.username}.json"

      expect(response.status).to eq(200)
      expect(response.parsed_body["users"].map { |user| user["username"] }).not_to include(
        hidden_visitor.username,
      )
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

      expect(response.status).to eq(404)
    end
  end
end
