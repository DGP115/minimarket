class ProductCategory < ApplicationRecord
  has_ancestry orphan_strategy: :destroy,
               cache_depth: true,
               counter_cache: "children_count"

  validates :name, presence: true, uniqueness: true, length: { minimum: 1, maximum: 100 }

  # When a product category is destroyed, any products it contains will have their
  # category association nullified.
  has_many :products, dependent: :nullify

  # After any mods to product_categories, flush the cache used to populate the navbar so that
  # a new database query is run to refresh the cache
  after_commit :flush_root_categories_cache

  def has_grandchildren?
    children.where("children_count > 0").exists?
  end

  private

  def flush_root_categories_cache
    Rails.cache.delete("root_categories")
  end
end
