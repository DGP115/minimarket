class AddUniqueConstraintToProductsIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :products, :stripe_id
    add_index :products, :stripe_id, unique: true
  end
end
