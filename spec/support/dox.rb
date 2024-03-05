RSpec.configure do | config |
  config.after( :each, :dox ) do | example |
    example.metadata[ :request ] = request
    example.metadata[ :response ] = response

    request&.headers&.merge! 'Accept' => 'application/json',
                             'Content-Type' => 'application/json'
  end
end
