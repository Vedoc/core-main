module PushNotification
  class NewServiceRequestJob < ApplicationJob
    queue_as :default

    def perform( service_request_id )
      service_request = ServiceRequest.find_by id: service_request_id

      return unless service_request

      device_tokens = Device.where(
        account_id: Shop.approved.where(
          ':category = ANY(categories)', category: service_request.category_before_type_cast
        ).within_distance( service_request.location ).joins( :accounts ).pluck( 'accounts.id' )
      ).pluck( :device_token )

      return if device_tokens.blank?

      FirebaseMessaging::UserNotificationSender.new(
        user_device_ids: device_tokens,
        message: I18n.t( 'notifications.new_service_request' ),
        payload: { type: 'new_service_request', service_request_id: service_request.id }
      ).call
    end
  end
end
