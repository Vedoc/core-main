require 'rails_helper'

RSpec.describe Rating, type: :model do
  subject { build :rating }

  describe 'validations' do
    it { should validate_presence_of :score }
    it do
      should validate_numericality_of( :score )
        .only_integer.is_greater_than( 0 ).is_less_than( 6 )
    end

    it { should validate_presence_of :offer }
    it { should validate_uniqueness_of :offer_id }
  end

  describe 'callbacks' do
    describe '#update_average_rating' do
      it 'update shops average rating' do
        ratings = subject.offer.shop.ratings.pluck( :score ) << subject.score
        new_average = ratings.sum.fdiv ratings.size

        expect { subject.save }.to change { subject.offer.shop.average_rating }
          .from( 0 ).to new_average
      end
    end
  end

  describe 'associations' do
    it { should belong_to :offer }
    it { should belong_to :client }
  end
end
