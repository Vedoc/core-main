require 'rails_helper'

RSpec.describe Picture, type: :model do
  describe 'validations' do
    it { should validate_presence_of :imageable }
  end

  describe 'associations' do
    it { should belong_to :imageable }
  end
end
