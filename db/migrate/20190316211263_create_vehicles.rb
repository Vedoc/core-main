class CreateVehicles < ActiveRecord::Migration[ 7.1 ]
  def change
    create_table :vehicles do | t |
      t.string :make, null: false, default: ''
      t.string :model, null: false, default: ''
      t.integer :year, null: false, default: 0
      t.string :category, :string, null: false, default: ''
      t.references :client, foreign_key: { on_delete: :cascade }
      t.string :photo

      t.timestamps
    end
  end
end
