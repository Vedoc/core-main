module PushNotification
  class NewMessageJob < ApplicationJob
    queue_as :default

    def perform( message, account_ids )
      return if message.blank? || account_ids.blank?

      FirebaseMessaging::UserNotificationSender.new(
        user_device_ids: Device.where( account_id: account_ids ).pluck( :device_token ),
        message: I18n.t( 'notifications.new_message' ),
        payload: { type: 'new_message', message: message }
      ).call
    end
  end
end
