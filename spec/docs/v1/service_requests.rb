module Docs
  module V1
    module ServiceRequests
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Service Request' do
          endpoint '/service_requests'
          group 'Service Requests'
        end
      end

      # Action Data
      document :create do
        action 'Create a service request'
      end

      index_params = {
        title: {
          type: :string,
          value: 'Test',
          description: 'Title',
          required: :optional
        },
        status: {
          type: :integer,
          value: 0,
          description: 'For clients only: 0 - pending, 1 - in repair, 2 - done',
          required: :optional
        }
      }

      document :index do
        action 'List service requests' do
          params index_params
        end
      end

      document :jobs do
        action 'List jobs (accepted service requests)'
      end

      document :show do
        action 'Show a service request'
      end

      document :destroy do
        action 'Destroy a service request'
      end

      document :pay do
        action "Pay for a service (set status to 'done')"
      end
    end
  end
end
