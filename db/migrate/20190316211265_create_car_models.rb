class CreateCarModels < ActiveRecord::Migration[ 5.2 ]
  def change
    create_table :car_models do | t |
      t.string :name, null: false, default: ''
      t.references :car_make, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :car_models, %i[name car_make_id], unique: true
  end
end
