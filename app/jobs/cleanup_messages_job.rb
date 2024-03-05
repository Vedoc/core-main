class CleanupMessagesJob < ApplicationJob
  queue_as :default

  def perform( offer_id, service_request_id )
    Message.where( service_request_id: service_request_id )
           .where( :offer_id.ne => offer_id ).destroy_all
  end
end
