# frozen_string_literal: true

module ::CrimsonCommunity
  class PresenceSnapshot
    def initialize(channel)
      @channel = channel
    end

    def ordered_users
      @ordered_users ||=
        users.sort_by { |user| [user.last_seen_at || Time.at(0), user.id] }.reverse
    end

    def total_count
      users.length
    end

    def filtered_state
      state_users = serialized_users
      visible_user_ids = users.index_by(&:id)
      filtered_users =
        state_users.select do |user|
          visible_user_ids.key?((user[:id] || user["id"]).to_i)
        end

      {
        count: filtered_users.length,
        last_message_id:
          serialized_state[:last_message_id] || serialized_state["last_message_id"],
        users: filtered_users,
      }
    end

    private

    def users
      @users ||=
        begin
          users_by_id =
            User
              .real
              .activated
              .not_staged
              .not_suspended
              .where(id: online_user_ids)
              .index_by(&:id)

          online_user_ids
            .filter_map { |user_id| users_by_id[user_id] }
            .select { |user| CrimsonCommunity.visible_in_presence?(user) }
        end
    end

    def online_user_ids
      @online_user_ids ||=
        serialized_users
          .filter_map { |user| (user[:id] || user["id"]).to_i.presence }
          .uniq
    end

    def serialized_users
      @serialized_users ||= Array(serialized_state[:users] || serialized_state["users"])
    end

    def serialized_state
      @serialized_state ||=
        PresenceChannelStateSerializer.new(@channel.state, root: nil).as_json
    end
  end
end
