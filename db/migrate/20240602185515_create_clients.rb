class CreateClients < ActiveRecord::Migration[ 7.1 ]
  def change
    create_table :clients do | t |
      t.string   :name, default: ''
      t.st_point :location, geographic: true
      t.string   :address
      t.string   :phone, default: ''
      t.string   :avatar

      t.timestamps
    end

    add_index :clients, :location, using: :gist
  end
end
