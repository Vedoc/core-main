require 'rails_helper'

RSpec.describe Client, type: :model do
  subject { build :client }

  describe 'validations' do
    context 'when phone present' do
      it { should validate_uniqueness_of( :phone ).case_insensitive }
    end

    context 'when phone is not present' do
      before { allow( subject ).to receive( :phone ).and_return nil }

      it { should_not validate_uniqueness_of( :phone ).case_insensitive }
    end

    it_behaves_like 'address_presence'
  end

  describe 'associations' do
    it { should have_one( :account ).dependent :destroy }
    it { should have_many( :vehicles ).dependent :destroy }
    it { should have_many( :service_requests ).through( :vehicles ).dependent :destroy }
    it { should have_many( :offers ).through( :service_requests ).dependent :destroy }
    it { should have_many( :ratings ).dependent :nullify }
  end
end
