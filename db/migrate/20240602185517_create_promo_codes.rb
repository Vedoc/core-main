class CreatePromoCodes < ActiveRecord::Migration[ 7.1 ]
  def change
    create_table :promo_codes do | t |
      t.references :shop, index: true, null: false
      t.string :email, null: false
      t.string :code_token
      t.datetime :activated_at
      t.datetime :sent_at

      t.timestamps
    end
  end
end
