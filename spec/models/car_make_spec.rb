require 'rails_helper'

RSpec.describe CarMake, type: :model do
  subject { build :car_make }

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of( :name ).case_insensitive.scoped_to :car_category_id }

    it { should validate_presence_of :car_category_id }
  end

  describe 'associations' do
    it { should have_many( :car_models ).dependent :destroy }
    it { should belong_to :car_category }
  end
end
