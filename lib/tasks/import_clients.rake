require 'csv'

namespace :db do
  namespace :seed do
    desc "Import clients from CSV"
    task clients: :environment do
      file_path = Rails.root.join('db/seeds/clients.csv')
      unless File.exist?(file_path)
        puts "File not found: #{file_path}"
        exit
      end

      def read_csv(file_path)
        puts "Reading file: #{file_path}"
        
        # Try different encodings
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
          # Print progress every 100 records
          if (index + 1) % 100 == 0
            puts "Processed #{index + 1}/#{total} clients..."
          end
          
          # Parse location data
          location_str = row['Location']&.gsub('POINT (', '')&.gsub(')', '')
          longitude, latitude = location_str&.split(' ')&.map(&:to_f)
          
          # Find existing client
          client = Client.find_by(id: row['Id']) || Client.find_by(phone: row['Phone'])
          
          attributes = {
            name: row['Name'].presence || '',
            location: longitude && latitude ? "POINT(#{longitude} #{latitude})" : nil,
            address: row['Address'],
            phone: row['Phone'],
            avatar: row['Avatar'],
            created_at: row['Created at'],
            updated_at: row['Updated at']
          }

          if client
            client.update!(attributes)
          else
            Client.create!(attributes.merge(id: row['Id']))
          end

          puts "Imported client #{row['Name']} (ID: #{row['Id']})"

        rescue ActiveRecord::RecordInvalid => e
          puts "Failed to import row #{index + 1}: #{row.to_h}. Error: #{e.message}"
        end
      end

      puts "Client import completed successfully."
    end
  end
end 