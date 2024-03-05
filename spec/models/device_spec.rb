require 'rails_helper'

RSpec.describe Device, type: :model do
  subject { build :device }

  describe 'validations' do
    it { should validate_presence_of :device_id }
    it { should validate_uniqueness_of( :device_id ).scoped_to %i[platform account_id] }
    context 'when device_token present' do
      it { should validate_uniqueness_of( :device_token ).scoped_to :device_id }
    end

    context 'when device_token is not present' do
      before { allow( subject ).to receive( :device_token ).and_return nil }

      it { should_not validate_uniqueness_of( :device_token ).scoped_to :device_id }
    end

    it { should validate_presence_of :platform }
    it do
      should define_enum_for( :platform ).with_values %i[android ios]
    end
  end

  describe 'associations' do
    it { should belong_to :account }
  end
end
