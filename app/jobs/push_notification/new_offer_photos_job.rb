module PushNotification
  class NewOfferPhotosJob < ApplicationJob
    queue_as :default

    def perform( offer_id )
      offer = Offer.find_by id: offer_id

      return unless offer

      FirebaseMessaging::UserNotificationSender.new(
        user_device_ids: Device.where( account: offer.client.account ).pluck( :device_token ),
        message: I18n.t( 'notifications.new_offer_photos' ),
        payload: { type: 'new_offer_photos', service_request_id: offer.service_request_id, offer_id: offer.id }
      ).call
    end
  end
end
