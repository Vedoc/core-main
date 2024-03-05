require 'rails_helper'

RSpec.shared_examples 'address_presence' do
  context 'when location present' do
    before { allow( subject ).to receive( :location ).and_return true }

    it { should validate_presence_of :address }
  end

  context 'when location is not present' do
    before { allow( subject ).to receive( :location ).and_return( {} ) }

    it { should_not validate_presence_of :address }
  end
end
