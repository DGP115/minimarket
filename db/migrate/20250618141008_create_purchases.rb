class CreatePurchases < ActiveRecord::Migration[8.0]
  def change
    create_table :purchases do |t|
      t.references :product

      # Buyers and sellers are both modelled as Users.  This tells rails to link
      # purchases table to the users table with a column: buyer_id
      t.references :buyer, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
