require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  describe 'validations' do
    it { should validate_presence_of :make }
    it { should validate_presence_of :model }
    it { should validate_presence_of :category }

    it { should validate_presence_of :year }
    it { should validate_numericality_of( :year ).only_integer.is_greater_than_or_equal_to 0 }
  end

  describe 'associations' do
    it { should belong_to :client }
    it { should have_many( :service_requests ).dependent :destroy }
  end
end
