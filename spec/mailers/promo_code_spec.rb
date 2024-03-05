require 'rails_helper'

RSpec.describe PromoCodeMailer do
  describe '#reset_password_instructions' do
    let!( :account ) { create :business_account }
    let( :token ) { 'foobar123' }
    let( :receiver ) { 'test@mail.com' }
    let( :mail ) { PromoCodeMailer.invitation email: receiver, code: token, shop: account.accountable }

    it 'renders the headers' do
      expect( mail.subject ).to eq 'Vedoc Registration Promo Code'
      expect( mail.to ).to eq [ receiver ]
      expect( mail.from ).to eq [ ENV[ 'APP_EMAIL' ] ]
    end

    it 'contains a reset password code' do
      expect( mail.body.encoded ).to include account.name
      expect( mail.body.encoded ).to include token
    end
  end
end
