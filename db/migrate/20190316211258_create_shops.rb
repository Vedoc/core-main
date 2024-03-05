class CreateShops < ActiveRecord::Migration[ 5.2 ]
  def change
    create_table :shops do | t |
      t.string   :name, default: '', null: false, index: { unique: true }
      t.string   :owner_name, null: false, default: ''
      t.string   :hours_of_operation, default: '', null: false
      t.integer  :techs_per_shift, default: 0, null: false
      t.boolean  :certified, default: false
      t.boolean  :lounge_area, default: false, null: false
      t.boolean  :supervisor_permanently, default: false, null: false
      t.text     :languages, array: true, default: []
      t.boolean  :tow_track, default: false
      t.boolean  :complimentary_inspection, default: false, null: false
      t.boolean  :vehicle_diesel, default: false
      t.boolean  :vehicle_electric, default: false
      t.boolean  :vehicle_warranties, default: false, null: false
      t.integer  :categories, array: true, null: false, default: []
      t.st_point :location, geographic: true, null: false
      t.string   :address, null: false, default: ''
      t.string   :phone, null: false, default: ''
      t.boolean  :approved, default: false, null: false
      t.string   :avatar
      t.text     :additional_info
      t.decimal  :average_rating, precision: 3, scale: 2, null: false, default: 0

      t.timestamps
    end

    add_index :shops, :location, using: :gist
    add_index :shops, :approved
    add_index :shops, :categories, using: :gin
  end
end
