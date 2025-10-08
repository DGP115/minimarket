class ReviewNotification < ApplicationRecord
  belongs_to :review
  belongs_to :user  # The seller receiving the notification

  # ---------------------- Ransack (search) - Related ----------------------
  # Ransack needs attributes and associations explicitly allowlisted as searchable.
  def self.ransackable_attributes(auth_object = nil)
    [ "created_at", "read", "review_id", "updated_at", "user_id" ]
  end

  def self.ransackable_associations(auth_object = nil)
    [ "review", "user" ]
  end
end
