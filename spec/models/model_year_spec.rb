require 'rails_helper'

RSpec.describe ModelYear, type: :model do
  subject { build :model_year }

  describe 'validations' do
    it { should validate_presence_of :car_model_id }

    it { should validate_presence_of :year }
    it { should validate_uniqueness_of( :year ).case_insensitive.scoped_to :car_model_id }
  end

  describe 'associations' do
    it { should belong_to :car_model }
  end
end
