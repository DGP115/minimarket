class AddOrderindexToProductCategories < ActiveRecord::Migration[8.0]
  def change
    add_column :product_categories, :orderindex, :integer, default: 1
  end
end
