class RemoveProductsDescription < ActiveRecord::Migration[8.0]
  def change
    remove_column :products, :description, :text
  end
end
