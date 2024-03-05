FactoryBot.define do
  factory :picture do
    data { Rack::Test::UploadedFile.new( Rails.root.join( 'spec/support/assets/test.jpg' ), 'image/jpeg' ) }

    factory :fake_picture do
      data { 'UploadedFile' }
    end
  end
end
