class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  #  Broadcast changes in reviews to "subscribers" of the related turbo_stream -
  #  aka a streamable.
  #  broadcasts_prepend_to:
  #   - configures the model to broadcast a “page refresh”
  #   - :product is the streamable, so we are telling teh server to broadcast to product pages showing the reviewed product
  after_create_commit do
    # Broadcast to the product (show page) of the product receiving the review
    broadcast_prepend_to product,
      target: "reviews",
      partial: "reviews/review",
      locals: { review: self }

     # Broadcast to seller’s notifications
     broadcast_prepend_to "seller_#{product.seller_id}_notifications",
       target: "seller_notifications",
       partial: "layouts/navbar/seller_notification",
       formats: [ :html ],        # <-- This is the missing key
       locals: { review: self }
  end

  after_update_commit do
    broadcast_replace_to product

    # Broadcast to seller’s notifications
    broadcast_prepend_to "seller_#{product.seller_id}_notifications",
      target: "seller_notifications",
      partial: "layouts/navbar/seller_notification",
      formats: [ :html ],        # <-- This is the missing key
      locals: { review: self }
  end

  after_destroy_commit do
    broadcast_remove_to product
  end

  # ---------------------- Ransack (search) - Related ----------------------
  # Ransack needs product_category attributes and associations explicitly allowlisted as searchable.
  def self.ransackable_attributes(auth_object = nil)
    [ "body" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "product" ]
  end
end
