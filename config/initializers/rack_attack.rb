module Rack
  class Attack
    ### Configure Cache ###

    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    ### Throttle Spammy Clients ###

    throttle('req/ip', limit: 300, period: 5.minutes) { |req| req.ip }

    ### Prevent Brute-Force Login Attacks ###

    throttle('logins/ip', limit: 5, period: 20.seconds) do |req|
      req.ip if req.path.end_with?('/auth/sign_in') && req.post?
    end

    throttle('password_resets/ip', limit: 5, period: 20.seconds) do |req|
      req.ip if req.path.end_with?('/auth/password_resets') && req.post?
    end

    throttle('logins/email', limit: 5, period: 20.seconds) do |req|
      if req.path.end_with?('/auth/sign_in') && req.post?
        body = JSON.parse(req.body.string)
        req.params['email'].presence || body['email'].presence
      end
    rescue JSON::ParserError
      nil
    end

    throttle('password_resets/email', limit: 5, period: 20.seconds) do |req|
      if req.path.end_with?('/auth/password_resets') && req.post?
        body = JSON.parse(req.body.string)
        req.params['email'].presence || body['email'].presence
      end
    rescue JSON::ParserError
      nil
    end

    ### Custom Throttle Responder ###

    self.throttled_responder = lambda do |env|
      [
        503,   # status
        {},    # headers
        ['']   # body
      ]
    end
  end
end
