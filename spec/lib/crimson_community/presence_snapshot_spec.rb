# frozen_string_literal: true

describe CrimsonCommunity::PresenceSnapshot do
  fab!(:visible_user, :user)
  fab!(:hidden_user, :user)

  let(:channel) { instance_double(PresenceChannel, state: Object.new) }
  let(:serialized_state) do
    {
      count: 2,
      last_message_id: 42,
      users: [{ id: visible_user.id }, { id: hidden_user.id }],
    }
  end

  before do
    hidden_user.user_option.update!(hide_presence: true)
    serializer = instance_double(PresenceChannelStateSerializer, as_json: serialized_state)
    allow(PresenceChannelStateSerializer).to receive(:new).and_return(serializer)
  end

  it "removes users who hide presence from stale channel state" do
    snapshot = described_class.new(channel)

    expect(snapshot.total_count).to eq(1)
    expect(snapshot.filtered_state).to eq(
      count: 1,
      last_message_id: 42,
      users: [{ id: visible_user.id }],
    )
  end
end
