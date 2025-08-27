class BackfillProductCategoryProductsCount < ActiveRecord::Migration[8.0]
  disable_ddl_transaction! # optional, avoids long locks for large tables

  def up
    # Efficient SQL-based backfill
    say_with_time "Backfilling product_categories.products_count" do
      ProductCategory.find_each do |category|
        ProductCategory.reset_counters(category.id, :products)
      end
    end
  end

  def down
    # nothing to do
  end
end
