RSpec.configure do | config |
  config.before( :suite ) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation, except: [ 'spatial_ref_sys' ]

    Redis.current.del Redis.current.keys if Redis.current.keys.any?
  end

  config.around( :each ) do | example |
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
