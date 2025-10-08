class ReviewNotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review_notification, only: %i[ show update destroy ]

  def index
    @review_notifications = current_user.review_notifications.order(created_at: :desc)
  end

  def show
  end

  def update
    if @review_notification.update(review_notification_params) == false
      flash[:alert] = "There was an error updating the notification."
    end
    redirect_to review_notifications_path
  end

  def destroy
    if @review_notification.destroy == false
      flash[:notice] = "There was an error deleting  notification #{@review_notification.review.body}."
    end
    redirect_to review_notifications_path
  end

  private

  def set_review_notification
    @review_notification = ReviewNotification.find(params[:id])
  end

  def review_notification_params
    params.expect(review_notification: [ :read ])
  end
end
