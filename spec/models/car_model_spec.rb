require 'rails_helper'

RSpec.describe CarModel, type: :model do
  subject { build :car_model }

  describe 'validations' do
    it { should validate_presence_of :car_make_id }

    it { should validate_presence_of :name }
    it { should validate_uniqueness_of( :name ).case_insensitive.scoped_to :car_make_id }
  end

  describe 'associations' do
    it { should belong_to :car_make }
    it { should have_many( :model_years ).dependent :destroy }
  end
end
