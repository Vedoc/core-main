class CreateDevices < ActiveRecord::Migration[ 7.1 ]
  def change
    create_table :devices do | t |
      t.string :device_token
      t.string :device_id, null: false
      t.integer :platform, null: false, default: 0
      t.references :account, foreign_key: { on_delete: :cascade }

      t.timestamps
    end

    add_index :devices, %i[device_id platform account_id], unique: true
    add_index :devices, %i[device_token device_id],
              unique: true,
              where: 'device_token IS NOT NULL'
  end
end
