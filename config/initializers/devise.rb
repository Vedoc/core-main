Devise.setup do | config |
  config.secret_key = Rails.application.credentials.devise[:secret_key]
  config.mailer_sender = ENV[ 'APP_EMAIL' ]
end
