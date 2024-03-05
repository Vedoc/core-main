module PushNotification
  class ReminderJob < ApplicationJob
    queue_as :default

    def perform( *_args )
      FirebaseMessaging::UserNotificationSender.new(
        user_device_ids: Device.pluck( :device_token ),
        message: I18n.t( 'notifications.friendly_reminder' ),
        payload: { type: 'reminder' }
      ).call
    end
  end
end
