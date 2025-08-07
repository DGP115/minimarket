class ProductCategory < ApplicationRecord
  has_ancestry orphan_strategy: :destroy,
               cache_depth: true,
               counter_cache: "children_count"

  validates :name, presence: true, uniqueness: true, length: { minimum: 1, maximum: 100 }

  # When a product category is destroyed, any products it contains will have their
  # category association nullified.
  has_many :products, dependent: :nullify
end
