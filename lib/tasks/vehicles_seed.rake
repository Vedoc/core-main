require 'csv'

namespace :db do
  namespace :seed do
    task vehicles: :environment do
      File.open( Rails.root.join( 'db/seeds/vehicles.csv' ), 'r' ) do | file |
        csv = CSV.new file, headers: true

        while ( row = csv.shift )
          category = CarCategory.order( 'RANDOM()' ).first
          make  = CarMake.find_or_create_by name: row[ 'make' ], car_category: category
          model = CarModel.find_or_create_by name: row[ 'model' ], car_make: make
          ModelYear.find_or_create_by year: row[ 'year' ], car_model: model
        end
      end
    end
  end
end
