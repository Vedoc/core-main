require 'rails_helper'

RSpec.describe PromoCode, type: :model do
  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_presence_of :shop }
  end

  describe 'associations' do
    it { should belong_to :shop }
  end
end
