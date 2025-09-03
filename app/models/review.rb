class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  #  Broadcast changes in reviews to "subscribers" of the related turbo_stream -
  #  aka a streamable.
  #  broadcasts_prepend_to:
  #   - configures the model to broadcast a “page refresh”
  #   - :product is the streamable, which, oddly enough, means listeners will listen for a
  #      turbo_stream_from @product
  after_create_commit do
    broadcast_prepend_to product,
      target: "reviews",
      partial: "reviews/review",
      locals: { review: self }
  end

  after_update_commit do
    broadcast_replace_to product
  end

  after_destroy_commit do
    broadcast_remove_to product
  end
end
