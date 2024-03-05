require 'rails_helper'

RSpec.describe ServiceRequest, type: :model do
  subject { build :service_request }

  describe 'validations' do
    it { should validate_presence_of :summary }
    it { should validate_presence_of :title }
    it { should validate_presence_of :location }
    it { should validate_presence_of :status }
    it { should_not allow_value( nil ).for :evacuation }
    it { should_not allow_value( nil ).for :repair_parts }
    it { should validate_presence_of :category }

    context 'when estimated budget present' do
      it do
        should validate_numericality_of( :estimated_budget ).is_greater_than_or_equal_to 0
      end
    end

    context 'when estimated budget is not present' do
      it do
        allow( subject ).to receive( :estimated_budget ).and_return nil

        should_not validate_numericality_of( :estimated_budget ).is_greater_than_or_equal_to 0
      end
    end

    it do
      should define_enum_for( :status ).with_values %i[pending in_repair done]
    end

    it_behaves_like 'address_presence'
  end

  describe 'associations' do
    it { should belong_to :vehicle }
    it { should have_many( :pictures ).dependent :destroy }
    it { should have_many( :offers ).dependent :destroy }
  end
end
