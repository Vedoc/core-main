class CreateModelYears < ActiveRecord::Migration[ 7.1 ]
  def change
    create_table :model_years do | t |
      t.integer :year, null: false, default: ''
      t.references :car_model, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :model_years, %i[year car_model_id], unique: true
  end
end
