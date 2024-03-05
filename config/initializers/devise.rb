Devise.setup do | config |
  config.mailer_sender = ENV[ 'APP_EMAIL' ]
end
