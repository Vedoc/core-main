module Helpers
  module Request
    def json
      JSON.parse response.body
    end

    def post_json( url, params: {}, headers: {} )
      post url, params: params.to_json, headers: headers.merge( 'Content-Type' => 'application/json' )
    end

    def put_json( url, params: {}, headers: {} )
      put url, params: params.to_json, headers: headers.merge( 'Content-Type' => 'application/json' )
    end

    def shop_response( shop )
      {
        'name' => shop.name,
        'owner_name' => shop.owner_name,
        'phone' => shop.phone,
        'location' => shop.pretty_location,
        'address' => shop.address,
        'hours_of_operation' => shop.hours_of_operation,
        'techs_per_shift' => shop.techs_per_shift,
        'certified' => shop.certified,
        'lounge_area' => shop.lounge_area,
        'supervisor_permanently' => shop.supervisor_permanently,
        'languages' => shop.languages,
        'complimentary_inspection' => shop.complimentary_inspection,
        'tow_track' => shop.tow_track,
        'vehicle_diesel' => shop.vehicle_diesel,
        'vehicle_electric' => shop.vehicle_electric,
        'vehicle_warranties' => shop.vehicle_warranties,
        'categories' => shop.categories,
        'avatar' => shop.avatar.url,
        'additional_info' => shop.additional_info,
        'average_rating' => shop.average_rating.to_f,
        'pictures' => shop.pictures.map { | p | { 'url' => p.data.url, 'id' => p.id } }
      }
    end

    def client_response( client )
      {
        'name' => client.name,
        'phone' => client.phone,
        'location' => client.pretty_location,
        'address' => client.address,
        'avatar' => client.avatar.url,
        'vehicles' => client.vehicles.map { | vehicle | vehicle_response( vehicle ) }
      }
    end

    def vehicle_response( vehicle )
      {
        'id' => vehicle.id,
        'make' => vehicle.make,
        'model' => vehicle.model,
        'year' => vehicle.year,
        'category' => vehicle.category,
        'photo' => vehicle.photo.url
      }
    end

    def service_request_response( request )
      {
        'id' => request.id,
        'title' => request.title,
        'summary' => request.summary,
        'evacuation' => request.evacuation,
        'repair_parts' => request.repair_parts,
        'vin' => request.vin,
        'radius' => request.radius.to_i,
        'mileage' => request.mileage.to_i,
        'location' => request.pretty_location,
        'estimated_budget' => request.estimated_budget.to_s,
        'address' => request.address,
        'category' => request.category_before_type_cast,
        'schedule_service' => I18n.l( request.schedule_service ),
        'pictures' => request.pictures.map { | p | p.data.url },
        'vehicle' => vehicle_response( request.vehicle ),
        'status' => request.status_before_type_cast,
        'distance' => nil
      }
    end

    def service_request_list_response( request )
      {
        'id' => request.id,
        'title' => request.title,
        'summary' => request.summary,
        'address' => request.address,
        'location' => request.pretty_location,
        'estimated_budget' => request.estimated_budget.to_s,
        'pictures' => request.pictures.map { | p | p.data.url },
        'schedule_service' => I18n.l( request.schedule_service ),
        'vehicle' => vehicle_response( request.vehicle ),
        'category' => request.category_before_type_cast,
        'status' => request.status_before_type_cast,
        'distance' => nil
      }
    end

    def offer_response( offer )
      return nil unless offer

      {
        'id' => offer.id,
        'description' => offer.description,
        'budget' => offer.budget.to_s,
        'accepted' => offer.accepted,
        'pictures' => offer.pictures.map { | p | { 'url' => p.data.url, 'id' => p.id } }
      }
    end

    def offer_client_response( offer )
      return nil unless offer

      {
        'id' => offer.id,
        'shop_id' => offer.shop_id,
        'avatar' => offer.shop.avatar.url,
        'address' => offer.shop.address,
        'name' => offer.shop.name,
        'description' => offer.description,
        'budget' => offer.budget.to_s,
        'accepted' => offer.accepted,
        'pictures' => offer.pictures.map { | p | { 'url' => p.data.url, 'id' => p.id } }
      }
    end

    def resource_errors( resource )
      resource.errors.to_hash.map do | k, v |
        attribute = k.to_s.split( '.' ).last

        {
          'key' => attribute,
          'messages' => v.map do | error |
            "#{ resource.class.human_attribute_name( attribute ) } #{ error }".capitalize
          end
        }
      end
    end

    def rating_response( rating )
      return nil unless rating

      {
        'score' => rating.score,
        'offer_id' => rating.offer_id
      }
    end

    def device_response( device )
      return nil unless device

      {
        'device_id' => device.device_id,
        'device_token' => device.device_token,
        'platform' => device.platform
      }
    end

    def fake_pictures_for( klass )
      allow_any_instance_of( Picture ).to receive( :valid? ).and_return true
      allow_any_instance_of( klass ).to receive( :pictures ).and_return build_list( :picture, 2 )
    end
  end
end
