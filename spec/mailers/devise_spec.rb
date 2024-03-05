require 'rails_helper'

RSpec.describe Devise::Mailer do
  describe '#reset_password_instructions' do
    let!( :account ) { create :account }
    let( :token ) { 'foobar123' }
    let( :mail ) { Devise::Mailer.reset_password_instructions account, token }

    it 'renders the headers' do
      expect( mail.subject ).to eq 'Reset password instructions'
      expect( mail.to ).to eq [ account.email ]
      expect( mail.from ).to eq [ ENV[ 'APP_EMAIL' ] ]
    end

    it 'contains a reset password code' do
      expect( mail.body.encoded ).to include token
    end
  end
end
