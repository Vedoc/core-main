class AdminMailer < ApplicationMailer
  def service_payment_notification( account )
    @account = account

    mail bcc: AdminUser.pluck( :email ), subject: 'Payment Confirmation | Vedoc'
  end
end
