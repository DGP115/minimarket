class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      # precision refers to total #digits, scale refers to decimal places
      # So the below defines max price of 9999.99
      t.decimal :price, precision: 6, scale: 2,  default: 0
      # Buyers and sellers are both modelled as Users.  This tells rails to link
      # products table to users table with a column: seller_id
      t.references :seller, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
