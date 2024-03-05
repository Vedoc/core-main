class PromoCodeMailer < ApplicationMailer
  def invitation( email:, code:, shop: )
    @code = code
    @shop = shop

    mail to: email, subject: 'Vedoc Registration Promo Code'
  end
end
