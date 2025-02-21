require 'csv'

namespace :db do
  namespace :seed do
    desc "Import vehicles from CSV"
    task vehicles: :environment do
      file_path = Rails.root.join('db/seeds/vehicles.csv')
      unless File.exist?(file_path)
        puts "File not found: #{file_path}"
        exit
      end

      # Find or create default client without uniqueness validation
      default_client = Client.find_by(
        phone: '+1 (000) 000-0000'
      ) || Client.create!(
        name: 'Seed Client',
        phone: "+1 (000) 000-0000-#{Time.now.to_i}", # Make phone unique
        address: 'Default Address',
        location: 'POINT(-95.3698 29.7604)' # Default to Houston coordinates
      )
      
      puts "Using default client with ID: #{default_client.id}"

      CSV.foreach(file_path, headers: true).with_index(1) do |row, index|
        begin
          vehicle = Vehicle.find_or_create_by!(
            year: row['Year'],
            make: row['Make'],
            model: row['Model'],
            category: row['Category'],
            client: default_client,
            created_at: row['createdAt'] || Time.current,
            updated_at: row['updatedAt'] || Time.current
          )
          
          puts "Imported vehicle: #{vehicle.year} #{vehicle.make} #{vehicle.model}"
        rescue StandardError => e
          puts "Error importing row #{index}: #{e.message}"
          puts "Row data: #{row.inspect}"
        end
      end

      puts "Vehicle import completed successfully"
    end
  end
end 