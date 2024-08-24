# core-main/lib/tasks/vehicles_seed.rake
require 'csv'

namespace :db do
  namespace :seed do
    task vehicles: :environment do
      begin
        # Open the CSV file for reading
        File.open(Rails.root.join('db/seeds/vehicles.csv'), 'r') do |file|
          csv = CSV.new(file, headers: true)

          # Loop through each row in the CSV file
          csv.each do |row|
            begin
              # Ensure correct capitalization for the CSV headers
              make_name  = row['Make'] || row['make']
              model_name = row['Model'] || row['model']
              year       = row['Year'] || row['year']

              # Skip rows with missing data
              if make_name.nil? || model_name.nil? || year.nil?
                puts "Skipped row with missing data: #{row.to_h}"
                next
              end

              # Get a random car category
              category = CarCategory.order('RANDOM()').first

              # Find or create car make
              make = CarMake.find_or_create_by!(name: make_name, car_category: category)

              # Find or create car model associated with the make
              model = CarModel.find_or_create_by!(name: model_name, car_make: make)

              # Find or create model year associated with the model
              ModelYear.find_or_create_by!(year: year, car_model: model)

              puts "Imported #{make_name} #{model_name} #{year}"

            rescue ActiveRecord::RecordInvalid => e
              puts "Failed to import row: #{row.to_h}. Error: #{e.message}"
            end
          end
        end

        puts "Import completed."

      rescue Errno::ENOENT => e
        puts "File not found: #{e.message}"
      end
    end
  end
end
