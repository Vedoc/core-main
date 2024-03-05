module PushNotification
  class HireJob < ApplicationJob
    queue_as :default

    def perform( offer_id )
      offer = Offer.find_by id: offer_id

      return unless offer

      FirebaseMessaging::UserNotificationSender.new(
        user_device_ids: Device.where( account: offer.shop.accounts ).pluck( :device_token ),
        message: I18n.t( 'notifications.hire' ),
        payload: { type: 'hire', service_request_id: offer.service_request_id }
      ).call
    end
  end
end
