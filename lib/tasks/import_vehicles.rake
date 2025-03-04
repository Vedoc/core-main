require 'csv'
require_relative '../csv_importer'

namespace :db do
  namespace :seed do
    desc "Import vehicles from CSV"
    task vehicles: :environment do
      file_path = Rails.root.join('db/seeds/vehicles.csv')
      
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
      
      # Define mapping between CSV columns and model attributes
      mapping = {
        year: 'Year',
        make: 'Make',
        model: 'Model',
        category: 'Category',
        created_at: 'createdAt',
        updated_at: 'updatedAt'
      }
      
      # Process the CSV with our improved importer
      CsvImporter.process_csv(file_path, Vehicle, mapping, batch_size: 200) do |attributes, row|
        # Set client ID for each vehicle
        attributes[:client_id] = default_client.id
      end
    end
  end
end 