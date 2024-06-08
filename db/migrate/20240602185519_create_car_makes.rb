class CreateCarMakes < ActiveRecord::Migration[ 7.1 ]
  def change
    create_table :car_makes do | t |
      t.string :name, null: false, default: ''

      t.timestamps
    end

    add_index :car_makes, :name, unique: true
  end
end
