require 'rails_helper'

RSpec.describe AdminMailer do
  describe '#service_payment_notification' do
    let!( :account ) { create :account }
    let( :mail ) { AdminMailer.service_payment_notification account }

    it 'renders the headers' do
      expect( mail.subject ).to eq 'Payment Confirmation | Vedoc'
      expect( mail.bcc ).to eq AdminUser.pluck( :email )
      expect( mail.from ).to eq [ ENV[ 'APP_EMAIL' ] ]
    end

    it 'contains a reset password code' do
      expect( mail.body.encoded ).to include account.name
      expect( mail.body.encoded ).to include account.email
    end
  end
end
