class AddStripeIdToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :stripe_id, :string, null: false, default: ""
    add_index :products, :stripe_id
  end
end
