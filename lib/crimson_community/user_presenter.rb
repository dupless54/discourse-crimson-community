# frozen_string_literal: true

module ::CrimsonCommunity
  class UserPresenter
    def self.serialize(user, extra = {})
      {
        id: user.id,
        username: user.username,
        name: user.name,
        avatar_template: user.avatar_template,
        last_seen_at: user.last_seen_at,
      }.merge(extra)
    end
  end
end
