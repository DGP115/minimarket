class ReviewNotification < ApplicationRecord
  belongs_to :review
  belongs_to :user  # The seller receiving the notification
end
