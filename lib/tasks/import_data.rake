require 'csv'
require 'json'

namespace :db do
  namespace :seed do
    desc "Import all data from CSV files"
    task all: :environment do
      # Import in the correct order based on dependencies
      %w[clients accounts shops vehicles].each do |task_name|
        Rake::Task["db:seed:#{task_name}"].invoke
      end
    end

    def read_csv(file_path)
      # Get the file encoding using file command
      encoding = `file -i #{file_path}`.split('charset=').last.strip
      
      # Map file command charset to Ruby encoding names
      encoding_map = {
        'iso-8859-1' => 'ISO-8859-1',
        'binary' => 'ISO-8859-1', # Treat binary as ISO-8859-1
        'us-ascii' => 'US-ASCII',
        'utf-8' => 'UTF-8'
      }
      
      ruby_encoding = encoding_map[encoding.downcase] || 'UTF-8'
      
      begin
        content = File.read(file_path, encoding: ruby_encoding)
        # Force to UTF-8 and replace invalid characters
        content = content.encode('UTF-8', 
                               invalid: :replace, 
                               undef: :replace, 
                               replace: '?')
        # Remove BOM if present
        content = content.sub("\xEF\xBB\xBF", '')
        CSV.parse(content, headers: true)
      rescue => e
        puts "Error reading file #{file_path} with encoding #{ruby_encoding}: #{e.message}"
        raise
      end
    end

    desc "Import clients from CSV"
    task clients: :environment do
      file_path = Rails.root.join('db/seeds/clients.csv')
      if File.exist?(file_path)
        read_csv(file_path).each do |row|
          begin
            location_str = row['Location']&.gsub('POINT (', '')&.gsub(')', '')
            longitude, latitude = location_str&.split(' ')&.map(&:to_f)
            
            # Find existing client by ID or phone
            client = Client.find_by(id: row['Id']) || Client.find_by(phone: row['Phone'])
            
            if client
              # Update existing client
              client.update!(
                name: row['Name'].presence || client.name,
                location: longitude && latitude ? "POINT(#{longitude} #{latitude})" : client.location,
                address: row['Address'].presence || client.address,
                avatar: row['Avatar'].presence || client.avatar,
                created_at: row['Created at'] || client.created_at,
                updated_at: row['Updated at'] || client.updated_at
              )
            else
              # Create new client
              client = Client.create!(
                id: row['Id'],
                name: row['Name'].presence || '',
                location: longitude && latitude ? "POINT(#{longitude} #{latitude})" : nil,
                address: row['Address'],
                phone: row['Phone'],
                avatar: row['Avatar'],
                created_at: row['Created at'],
                updated_at: row['Updated at']
              )
            end

            puts "Processed client #{client.id}: #{client.name}"
          rescue StandardError => e
            puts "Error processing client #{row['Id']}: #{e.message}"
            puts "Row data: #{row.to_h}"
          end
        end
        puts "Clients import completed"
      else
        puts "File not found: #{file_path}"
      end
    end

    desc "Import accounts from CSV"
    task accounts: :environment do
      file_path = Rails.root.join('db/seeds/accounts.csv')
      if File.exist?(file_path)
        read_csv(file_path).each do |row|
          begin
            # Parse tokens string to hash, default to empty hash if invalid
            tokens = begin
                      JSON.parse(row['Tokens'] || '{}')
                    rescue JSON::ParserError
                      {}
                    end

            # Find or create the accountable record (Shop or Client)
            accountable_type = row['Accountable type']
            
            if accountable_type == 'Shop'
              # First try to find existing shop
              shop_name = row['Email'].split('@').first
              accountable = Shop.find_by(name: shop_name)
              
              unless accountable
                # Create new shop with required fields
                accountable = Shop.create!(
                  name: shop_name,
                  owner_name: 'Default Owner',
                  hours_of_operation: '9:00 AM - 5:00 PM',
                  categories: [1], # Using integer array as per schema
                  phone: '+1 (000) 000-0000',
                  location: 'POINT(-95.3698 29.7604)',
                  techs_per_shift: 1,
                  address: 'Default Address',
                  pictures: ['default.jpg'], # Add at least one picture
                  approved: true # Set to true for seed data
                )
              end
            else
              accountable = Client.find_or_create_by!(
                name: row['Email'].split('@').first,
                phone: row['Phone'].presence || '+1 (000) 000-0000'
              )
            end

            # Create or update account
            account = Account.find_or_initialize_by(id: row['Id'])
            account.assign_attributes(
              provider: row['Provider'],
              uid: row['Uid'],
              email: row['Email'],
              employee: row['Employee'] == 'true',
              accountable: accountable,
              accountable_type: accountable_type,
              tokens: tokens,
              created_at: row['Created at'],
              updated_at: row['Updated at']
            )
            
            account.encrypted_password = row['Encrypted password']
            account.save!(validate: false)
            
            puts "Processed account for #{row['Email']}"
          rescue StandardError => e
            puts "Error processing account #{row['Id']}: #{e.message}"
            puts "Row data: #{row.to_h}"
          end
        end
        puts "Accounts import completed"
      else
        puts "File not found: #{file_path}"
      end
    end

    desc "Import shops from CSV"
    task shops: :environment do
      file_path = Rails.root.join('db/seeds/shops.csv')
      if File.exist?(file_path)
        read_csv(file_path).each do |row|
          begin
            # Convert location string to PostGIS point
            location_str = row['Location']&.gsub('POINT (', '')&.gsub(')', '')
            longitude, latitude = location_str&.split(' ')&.map(&:to_f)
            
            # Set default location if coordinates are missing
            unless longitude && latitude
              longitude = -95.3698 # Default to Houston coordinates
              latitude = 29.7604
            end

            Shop.find_or_create_by!(
              id: row['Id'],
              name: row['Name'].presence || "Shop #{row['Id']}",  # Ensure name is not blank
              owner_name: row['Owner name'].presence || '',
              hours_of_operation: row['Hours of operation'].presence || '9:00 AM - 5:00 PM',
              techs_per_shift: row['Techs per shift'].presence || 1,
              certified: row['Certified'] == 'true',
              lounge_area: row['Lounge area'] == 'true',
              supervisor_permanently: row['Supervisor permanently'] == 'true',
              languages: eval(row['Languages'] || '[]'),
              tow_track: row['Tow track'] == 'true',
              complimentary_inspection: row['Complimentary inspection'] == 'true',
              vehicle_diesel: row['Vehicle diesel'] == 'true',
              vehicle_electric: row['Vehicle electric'] == 'true',
              vehicle_warranties: row['Vehicle warranties'] == 'true',
              categories: eval(row['Categories'] || '[]'),
              location: "POINT(#{longitude} #{latitude})",
              address: row['Address'].presence || 'Address pending',
              phone: row['Phone'].presence || '+1 (000) 000-0000',
              approved: row['Approved'] == 'true',
              avatar: row['Avatar'],
              additional_info: row['Additional info'],
              average_rating: row['Average rating'].presence || 0.0,
              created_at: row['Created at'],
              updated_at: row['Updated at']
            )
          rescue StandardError => e
            puts "Error importing shop #{row['Id']}: #{e.message}"
          end
        end
        puts "Shops imported successfully"
      else
        puts "File not found: #{file_path}"
      end
    end

    desc "Import vehicles from CSV"
    task vehicles: :environment do
      file_path = Rails.root.join('db/seeds/vehicles.csv')
      if File.exist?(file_path)
        # Create a default client for seed data if none exists
        default_client = Client.find_or_create_by!(
          name: 'Seed Client',
          phone: '+1 (000) 000-0000',
          address: 'Default Address'
        )

        read_csv(file_path).each do |row|
          Vehicle.find_or_create_by!(
            year: row['Year'],
            make: row['Make'],
            model: row['Model'],
            category: row['Category'],
            client: default_client, # Associate with default client
            created_at: row['createdAt'],
            updated_at: row['updatedAt']
          )
        end
        puts "Vehicles imported successfully"
      else
        puts "File not found: #{file_path}"
      end
    end
  end
end

module CsvImporter
  def self.process_csv(file_path, model_class, mapping)
    return puts "File not found: #{file_path}" unless File.exist?(file_path)

    encodings = ['UTF-8', 'ISO-8859-1', 'Windows-1252']
    
    encodings.each do |encoding|
      begin
        content = File.read(file_path, encoding: encoding)
        content = content.force_encoding('UTF-8')
        content = content.sub("\xEF\xBB\xBF", '') # Remove BOM
        
        CSV.parse(content, headers: true) do |row|
          attributes = {}
          mapping.each do |target_key, source_key|
            value = row[source_key]
            attributes[target_key] = value unless value.nil?
          end
          
          # Try to find existing record first
          existing = model_class.find_by(attributes.slice(:id)) if attributes[:id]
          
          if existing
            existing.update!(attributes)
          else
            model_class.create!(attributes)
          end
        end
        
        puts "Successfully imported #{model_class} data"
        return true
      rescue CSV::MalformedCSVError, Encoding::InvalidByteSequenceError => e
        puts "Failed with encoding #{encoding}: #{e.message}"
        next
      rescue ActiveRecord::RecordInvalid => e
        puts "Error processing row: #{e.message}"
        next
      end
    end
    
    puts "Failed to process CSV with any known encoding"
    false
  end
end 