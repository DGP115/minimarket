class CartItem < ApplicationRecord
  # NOTE: re: touch: true
  # Whenever a CartItem changes, Rails will update cart.updated_at, which triggers Cart#after_commit.
  # So, in other words, if a cart_item changes, so does its cart
  belongs_to :cart, touch: true
  belongs_to :product

  # after_commit :update_cart_button

  private

  # def update_cart_button
  #   cart.update_cart_button
  # end
end
