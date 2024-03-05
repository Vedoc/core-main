class CreateCarCategories < ActiveRecord::Migration[ 5.2 ]
  def change
    create_table :car_categories do | t |
      t.string :name, null: false, default: '', index: { unique: true }

      t.timestamps
    end

    remove_index :car_makes, :name
    add_reference :car_makes, :car_category, foreign_key: { on_delete: :cascade }
    add_index :car_makes, %i[name car_category_id], unique: true
  end
end
