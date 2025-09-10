class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  # This enables nested attributes for cart_items, allowing updates to cart items
  # through the cart model.  Used in the cart update action.
  accepts_nested_attributes_for :cart_items, allow_destroy: true

  after_commit :update_cart_button

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

  private
  # When changes to the cart occur, ensure the cart button icon is kept in synch [It displays total quanity]
  def update_cart_button
    broadcast_replace_to("cart_button", partial: "layouts/navbar/cart_icon", locals: { cart: self })
  end
end
