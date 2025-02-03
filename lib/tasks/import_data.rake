require 'csv'
require 'json'

namespace :db do
  namespace :seed do
    desc "Import all data from CSV files"
    task all: :environment do
      Rake::Task["db:seed:clients"].invoke
      Rake::Task["db:seed:accounts"].invoke
      Rake::Task["db:seed:shops"].invoke
      Rake::Task["db:seed:vehicles"].invoke
    end

    def read_csv(file_path)
      # Try different encodings if UTF-8 fails
      encodings = ['UTF-8', 'ISO-8859-1', 'Windows-1252']
      
      encodings.each do |encoding|
        begin
          content = File.read(file_path, encoding: encoding)
          # Remove BOM if present
          content = content.force_encoding('UTF-8')
          content = content.sub("\xEF\xBB\xBF", '')
          return CSV.parse(content, headers: true)
        rescue CSV::MalformedCSVError, Encoding::InvalidByteSequenceError => e
          puts "Failed with encoding #{encoding}: #{e.message}"
          next
        end
      end
      
      raise "Failed to read CSV with any known encoding"
    end

    desc "Import clients from CSV"
    task clients: :environment do
      file_path = Rails.root.join('db/seeds/clients.csv')
      if File.exist?(file_path)
        read_csv(file_path).each do |row|
          Client.find_or_create_by!(
            id: row['Id'],
            name: row['Name'],
            location: row['Location'],
            address: row['Address'],
            phone: row['Phone'],
            avatar: row['Avatar'],
            created_at: row['Created at'],
            updated_at: row['Updated at']
          )
        end
        puts "Clients imported successfully"
      else
        puts "File not found: #{file_path}"
      end
    end

    desc "Import accounts from CSV"
    task accounts: :environment do
      file_path = Rails.root.join('db/seeds/accounts.csv')
      if File.exist?(file_path)
        read_csv(file_path).each do |row|
          # Parse tokens string to hash, default to empty hash if invalid
          tokens = begin
                    JSON.parse(row['Tokens'] || '{}')
                  rescue JSON::ParserError
                    {}
                  end

          # Find or create the accountable record (Shop or Client)
          accountable_type = row['Accountable type']
          accountable = accountable_type.constantize.find_or_create_by!(
            name: row['Email'].split('@').first # Use email username as name
          )

          account = Account.new(
            id: row['Id'],
            provider: row['Provider'],
            uid: row['Uid'],
            password: 'password123', # Set a default password
            password_confirmation: 'password123',
            email: row['Email'],
            employee: row['Employee'] == 'true',
            accountable: accountable,
            accountable_type: accountable_type,
            tokens: tokens,
            created_at: row['Created at'],
            updated_at: row['Updated at']
          )
          
          # Skip validation to keep the encrypted password from CSV
          account.encrypted_password = row['Encrypted password']
          account.save!(validate: false)
          
          puts "Created account for #{row['Email']}"
        end
        puts "Accounts imported successfully"
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
        read_csv(file_path).each do |row|
          Vehicle.find_or_create_by!(
            year: row['Year'],
            make: row['Make'],
            model: row['Model'],
            category: row['Category'],
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