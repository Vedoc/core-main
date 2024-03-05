class CreateRatings < ActiveRecord::Migration[ 5.2 ]
  def change
    create_table :ratings do | t |
      t.integer :score, null: false, default: 0
      t.references :offer, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.references :client, foreign_key: { on_delete: :nullify }

      t.timestamps
    end
  end
end
