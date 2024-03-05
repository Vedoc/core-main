require 'rails_helper'

RSpec.describe Account, type: :model do
  subject { build :account }

  describe 'validations' do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of( :email ).scoped_to( :provider ).case_insensitive }
  end

  describe 'associations' do
    it { should belong_to( :accountable ).autosave true }
    it { should have_many( :devices ).dependent :destroy }
  end
end
