module V1
  class SessionsController < DeviseTokenAuth::SessionsController
    after_action :custom_render_destroy_success, only: :destroy

    def create
      Rails.logger.debug("Attempting login for email: #{params[:email]}")
    
      super do |resource|
        if resource && resource.persisted?
          Rails.logger.debug("Resource persisted for email: #{resource.email}")
    
          device_params = params.dig(:device) || {}
          if create_or_update_device(device_params)
            Rails.logger.debug("Device successfully updated for resource ##{resource.id}")
          else
            Rails.logger.error("Device update failed for resource ##{resource.id}")
          end
    
          token_data = resource.create_new_auth_token
          Rails.logger.debug("Token data created: #{token_data}")
    
          response.headers.merge!(token_data)
    
          render json: {
            auth: {
              'access-token': token_data['access-token'],
              client: token_data['client'],
              'token-type': token_data['token-type'],
              uid: token_data['uid']
            },
            account: resource_data(resource),
            status: 'success'
          }
          return
        else
          Rails.logger.error("Login failed for email: #{params[:email]}")
        end
      end
    end
    
    

    private

    def resource_data(resource)
      if resource.is_a?(Account)
        {
          email: resource.email,
          employee: resource.employee,
          client: resource.client? ? client_data(resource.accountable) : nil,
          business_owner: resource.business_owner? ? shop_data(resource.accountable) : nil
        }
      else
        # Handle cases where resource is not an Account
        {
          email: nil,
          employee: false,
          client: nil,
          business_owner: nil
        }
      end
    end

    def client_data(client)
      {
        name: client.name,
        phone: client.phone,
        address: client.address,
        vehicles: client.vehicles.map { |v| {
          id: v.id,
          make: v.make,
          model: v.model,
          year: v.year,
          category: v.category,
          photo: v.photo.try(:url) || ""
        }},
        avatar: client.avatar_url,
        location: client.location,
        card_token: client.card_token || ""
      }
    end

    def shop_data(shop)
      {
        name: shop.name,
        phone: shop.phone,
        address: shop.address,
        hours_of_operation: shop.hours_of_operation,
        techs_per_shift: shop.techs_per_shift,
        vehicle_diesel: shop.vehicle_diesel,
        certified: shop.certified,
        lounge_area: shop.lounge_area,
        supervisor_permanently: shop.supervisor_permanently,
        tow_track: shop.tow_track,
        owner_name: shop.owner_name,
        complimentary_inspection: shop.complimentary_inspection,
        vehicle_warranties: shop.vehicle_warranties,
        vehicle_electric: shop.vehicle_electric,
        avatar: shop.avatar_url,
        additional_info: shop.additional_info,
        categories: shop.categories,
        languages: shop.languages,
        pictures_attributes: shop.pictures_attributes,
        location: shop.location
      }
    end

    def custom_render_destroy_success
      render json: { success: true }, status: :ok if response.status == 204
    end

    def render_create_error_bad_credentials
      render_errors(
        errors: [I18n.t('devise_token_auth.sessions.bad_credentials')],
        status: :unauthorized
      )
    end

    def render_destroy_success
      render json: { status: 'success' }
    end

    def render_create_error_not_confirmed
      render_errors(
        errors: [I18n.t('devise_token_auth.sessions.not_confirmed')],
        status: :unauthorized
      )
    end

    def render_destroy_error
      render_errors(
        errors: [I18n.t('devise_token_auth.sessions.user_not_found')],
        status: :not_found
      )
    end
  end
end
