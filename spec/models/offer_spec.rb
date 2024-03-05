require 'rails_helper'

RSpec.describe Offer, type: :model do
  subject { build :offer, shop: create( :shop ) }

  describe 'validations' do
    it { should validate_presence_of :service_request }
    it { should validate_presence_of :shop }

    it { should validate_presence_of :budget }
    it do
      should validate_numericality_of( :budget ).is_greater_than_or_equal_to 0
    end

    it { should validate_uniqueness_of( :service_request_id ).scoped_to :shop_id }

    it { should_not allow_value( nil ).for :accepted }
  end

  describe 'callbacks' do
    describe '#check_state' do
      before do
        subject.service_request = create :service_request
        subject.save!
      end

      context 'when accepted changed' do
        it 'update service request state' do
          expect { subject.update! accepted: true }.to change {
            subject.service_request.status
          }.from( 'pending' ).to 'in_repair'
        end
      end

      context 'when accepted does not changed' do
        it 'does not update service request state' do
          expect( subject.service_request.pending? ).to eq true
          expect { subject.update!( budget: subject.budget + 1 ) }.to_not(
            change { subject.service_request.status }
          )
        end
      end
    end

    describe '#set_default_budget' do
      it 'sets default value for budget' do
        subject.service_request = create :service_request
        subject.budget = nil

        subject.save

        expect( subject.budget ).to_not eq nil
        expect( subject.budget ).to eq subject.service_request.estimated_budget
      end
    end
  end

  describe 'associations' do
    it { should have_one( :rating ).dependent :destroy }
    it { should belong_to :service_request }
    it { should belong_to :shop }
    it 'allows access to client' do
      expect( subject ).to respond_to :client
    end
  end
end
