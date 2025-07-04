class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  #  Broadcast changes to reviews to "subscribers" of the related turbo_stream - aka a streamable.
  #  broadcasts_refreshes_to:
  #   - configures the model to broadcast a “page refresh” on creates, updates, and destroys
  #   - :product is the streamable, which, oddly enough, means listeners will listen for a 
  #      turbo_stream_from @product
  broadcasts_refreshes_to :product
end
