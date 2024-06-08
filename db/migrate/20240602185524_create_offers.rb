class CreateOffers < ActiveRecord::Migration[ 7.1 ]
  def change
    create_table :offers do | t |
      t.belongs_to :service_request, index: true, null: false
      t.belongs_to :shop, index: true, null: false
      t.decimal    :budget, null: false, precision: 10, scale: 2
      t.string     :description
      t.boolean    :accepted, null: false, default: false

      t.timestamps
    end

    add_index :offers, %i[service_request_id shop_id], unique: true
  end
end
