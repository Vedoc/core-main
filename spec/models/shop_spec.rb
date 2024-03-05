require 'rails_helper'

RSpec.describe Shop, type: :model do
  subject { build :shop }

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of( :name ).case_insensitive }

    it { should validate_presence_of :techs_per_shift }
    it do
      should validate_numericality_of( :techs_per_shift )
        .only_integer.is_greater_than_or_equal_to 0
    end

    it { should validate_presence_of :hours_of_operation }
    it { should validate_presence_of :location }
    it { should validate_presence_of :owner_name }

    it { should validate_presence_of :phone }

    it { should_not allow_value( nil ).for :lounge_area }
    it { should_not allow_value( nil ).for :supervisor_permanently }
    it { should_not allow_value( nil ).for :vehicle_warranties }
    it { should_not allow_value( nil ).for :complimentary_inspection }

    it { should validate_presence_of :categories }
    it 'allows only array for category field' do
      subject.categories = 0

      expect( subject.valid? ).to eq false
    end
    it 'allows only non empty array of categories' do
      subject.categories = []

      expect( subject.valid? ).to eq false
    end
    it 'allows only specific values for categories' do
      subject.categories = [ Shop::CATEGORIES.values.last + 1 ]

      expect( subject.valid? ).to eq false
    end

    context 'when address present' do
      it { should validate_uniqueness_of( :address ).case_insensitive }
    end

    context 'when address is not present' do
      before { allow( subject ).to receive( :address ).and_return nil }

      it { should_not validate_uniqueness_of( :address ).case_insensitive }
    end

    context 'when mechanic shop' do
      before { allow( subject ).to receive( :mechanic_shop? ).and_return true }

      it { should_not allow_value( nil ).for :certified }
    end

    context 'when not mechanic shop' do
      before { allow( subject ).to receive( :mechanic_shop? ).and_return false }

      it { should allow_value( nil ).for :certified }
    end

    it_behaves_like 'address_presence'
  end

  describe 'associations' do
    it { should have_many( :accounts ).dependent :destroy }
    it { should have_many( :pictures ).dependent :destroy }
    it { should have_many( :promo_codes ).dependent :destroy }
    it { should have_many( :offers ).dependent :destroy }
    it { should have_many( :ratings ).through( :offers ).dependent :destroy }
    it { should have_many( :service_requests ).through :offers }
  end
end
