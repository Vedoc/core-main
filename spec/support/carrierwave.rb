uploads_test_path = Rails.root.join( 'spec/support/uploads' )

CarrierWave.configure do | config |
  config.root = uploads_test_path
end

RSpec.configure do | config |
  config.after( :suite ) do
    FileUtils.rm_rf( Dir[ uploads_test_path ] )
  end
end
