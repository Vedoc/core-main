node :errors do
  locals[ :resource ].errors.to_hash.map do | k, v |
    attribute = k.to_s.split( '.' ).last

    {
      key: attribute,
      messages: v.map do | error |
        "#{ locals[ :resource ].class.human_attribute_name( attribute ) } #{ error }".capitalize
      end
    }
  end
end
