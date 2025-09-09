class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  # This enables nested attributes for cart_items, allowing updates to cart items
  # through the cart model.  Used in the cart update action.
  accepts_nested_attributes_for :cart_items, allow_destroy: true

  def total_quantity
    cart_items.sum(&:quantity)
  end

  def total_purchase
    total_purchase = 0
    self.cart_items.each do |item|
      total_purchase += item.quantity.to_i * item.product.price
    end
    total_purchase
  end
end
