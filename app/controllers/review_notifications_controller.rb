class ReviewNotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_review_notification, only: %i[ show update destroy ]

  def index
    # Take advantage of sortable view columns provided by ransack gem
    @query = current_user.review_notifications.ransack(params[:q])
    # The ".includes" eager includes the associations to review and review's association to product
    # to avoid N+1 queries in the view
    @review_notifications = @query.result.includes(review: [ :product, :user ])

    # Apply default ordering only when no sort param is present
    unless params.dig(:q, :s).present?
      @review_notifications = @review_notifications.order(created_at: :desc)
    end

    respond_to do |format|
      format.html
      format.turbo_stream
    end
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
