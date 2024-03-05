require 'rails_helper'

RSpec.describe CarCategory, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of( :name ).case_insensitive }
  end

  describe 'associations' do
    it { should have_many( :car_makes ).dependent :destroy }
  end
end
