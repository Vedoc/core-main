require 'csv'

namespace :db do
  namespace :seed do
    desc "Import shops from CSV"
    task shops: :environment do
      file_path = Rails.root.join('db/seeds/shops.csv')
      unless File.exist?(file_path)
        puts "File not found: #{file_path}"
        exit
      end

      def read_csv(file_path)
        puts "Reading file: #{file_path}"
        ['UTF-8', 'ISO-8859-1', 'Windows-1252'].each do |encoding|
          begin
            content = File.read(file_path, encoding: encoding)
            content = content.encode('UTF-8', invalid: :replace, undef: :replace, replace: '?')
            content = content.sub("\xEF\xBB\xBF", '') # Remove BOM if present
            return CSV.parse(content, headers: true)
          rescue CSV::MalformedCSVError, Encoding::InvalidByteSequenceError => e
            puts "Failed with encoding #{encoding}: #{e.message}"
            next
          end
        end
        raise "Failed to process CSV with any known encoding"
      end

      csv = read_csv(file_path)
      total = csv.count
      puts "Found #{total} records to process"

      csv.each_with_index do |row, index|
        begin
          # Parse location data
          location_str = row['Location']&.gsub('POINT (', '')&.gsub(')', '')
          longitude, latitude = location_str&.split(' ')&.map(&:to_f)
          
          # Set default location if coordinates are missing
          unless longitude && latitude
            longitude = -95.3698 # Default to Houston coordinates
            latitude = 29.7604
          end

          # Ensure categories are valid integers
          categories = begin
            cats = eval(row['Categories'] || '[]')
            cats.map(&:to_i).select { |c| c >= 0 && c <= 21 }
          rescue
            [1] # Default category if parsing fails
          end

          shop = Shop.find_or_create_by!(
            id: row['Id'],
            name: row['Name'].presence || "Shop #{row['Id']}",
            owner_name: row['Owner name'].presence || '',
            hours_of_operation: row['Hours of operation'].presence || '9:00 AM - 5:00 PM',
            techs_per_shift: row['Techs per shift'].presence || 1,
            certified: row['Certified'] == 'true',
            lounge_area: row['Lounge area'] == 'true',
            supervisor_permanently: row['Supervisor permanently'] == 'true',
            languages: eval(row['Languages'] || '[]'),
            categories: categories,
            location: "POINT(#{longitude} #{latitude})",
            address: row['Address'].presence || 'Address pending',
            phone: row['Phone'].presence || '+1 (000) 000-0000',
            approved: row['Approved'] == 'true',
            avatar: row['Avatar'],
            pictures: ['default.jpg'], # Add default picture
            additional_info: row['Additional info'],
            average_rating: row['Average rating'].presence || 0.0,
            created_at: row['Created at'],
            updated_at: row['Updated at']
          )

          puts "Imported shop #{shop.name} (ID: #{shop.id})"

        rescue StandardError => e
          puts "Error importing shop #{row['Id']}: #{e.message}"
          puts "Row data: #{row.inspect}"
        end
      end

      puts "Shops import completed successfully"
    end
  end
end 