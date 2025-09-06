class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  # This enables nested attributes for cart_items, allowing updates to cart items
  # through the cart model.  Used in the cart update action.
  accepts_nested_attributes_for :cart_items, allow_destroy: true
end
