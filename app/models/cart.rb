class Cart < ApplicationRecord
  belongs_to :user

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  # This enables nested attributes for cart_items, allowing updates to cart items
  # through the cart model.  Used in the cart update action.
  accepts_nested_attributes_for :cart_items, allow_destroy: true

  # Broadcast updates whenever the cart itself or one of its cart_items changes
  after_commit :update_cart_button

  def total_quantity
    active_items.sum { |item| item.quantity.to_i }
  end

  def total_purchase
    active_items.sum { |item| item.quantity.to_i * item.product.price }
  end

  def is_empty?
    self.cart_items.empty?
  end

  def active_items
    # NOTE:  cart_items are marked for deletion in the form, awaiting actual deletion by controller.
    #        Filter out these soft_deletes when computing totals.
    #        && item.persisted? ensures we are only filtering items that have persisted
    #        vs just created in memeort by Rails when form enters edit mode,
    cart_items.reject { |item| item.marked_for_destruction? && item.persisted? }
  end

  def update_cart_button
    # dom_id() is a Rails view helper, not available to models, so the below replicates its function
    dom_id = "button_cart_#{self.id}"
    # Ensure to include target: in the Turbo_stream broadcast definition
    broadcast_replace_later_to(dom_id,
                               target: dom_id,
                               partial: "layouts/navbar/cart_icon",
                               locals: {
                                 cart: self,
                                 total_quantity: total_quantity,
                                 total_purchase: total_purchase
                               }
    )
  end
end
