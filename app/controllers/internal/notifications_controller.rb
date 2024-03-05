module Internal
  class NotificationsController < ApplicationController
    def new_message
      @accounts = Account.where( recepient_params ).pluck :id

      return render json: { status: :error }, status: :not_found if @accounts.blank?

      PushNotification::NewMessageJob.perform_later message_params, @accounts

      render json: { status: :success }
    end

    private

    def recepient_params
      params.require( :recepient ).permit :accountable_id, :accountable_type
    end

    def message_params
      params.require( :message ).permit(
        :read, :message, :offer_id, :to_type, :to_id,
        :from_type, :from_id, :_id, :created_at, :service_request_id
      )
    end
  end
end
