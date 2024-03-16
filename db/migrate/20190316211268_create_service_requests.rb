class CreateServiceRequests < ActiveRecord::Migration[ 7.1 ]
  def change
    create_table :service_requests do | t |
      t.text       :summary, null: false, default: ''
      t.string     :title, null: false, default: ''
      t.decimal    :estimated_budget, precision: 10, scale: 2
      t.integer    :category, null: false, default: 0
      t.references :vehicle, foreign_key: { on_delete: :cascade }
      t.st_point   :location, geographic: true, null: false
      t.string     :address, null: false, default: ''
      t.boolean    :evacuation, null: false, default: false
      t.boolean    :repair_parts, null: false, default: false
      t.datetime   :schedule_service
      t.string     :vin
      t.integer    :radius
      t.integer    :mileage
      t.integer    :status, null: false, default: 0

      t.timestamps
    end

    add_index :service_requests, :location, using: :gist
  end
end
