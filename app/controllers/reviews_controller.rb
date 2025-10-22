class ReviewsController < ApplicationController
  before_action :set_review, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, only: %i[ create edit update destroy ]

  # GET /reviews/1 or /reviews/1.json
  def show
  end

  # GET /reviews/new
  def new
    @review = Review.new
  end

  # GET /reviews/1/edit
  def edit
  end

  def index
    @reviews = Review.where(user_id: current_user.id).order(created_at: :desc)
  end

  # POST /reviews or /reviews.json
  def create
    @review = current_user.reviews.new(review_params)
    if @review.save
      # Create a notification for the seller of the product being reviewed
      ReviewNotification.create!(review: @review, user_id: @review.product.seller_id)

      flash[:notice] = "Review was successfully created."
      redirect_to product_path(@review.product)
    else
      render "new", status: :unprocessable_entity
    end
  end

  # PATCH/PUT /reviews/1 or /reviews/1.json
  def update
    if @review.update(review_params)

      # If an existing review notification exists for the seller of the product being reviewed
      # update it to unread, otherwise create a new notification
      notification = ReviewNotification.find_by(review: @review, user_id: @review.product.seller_id)
      if notification == nil
        notification = ReviewNotification.create!(review: @review, user_id: @review.product.seller_id)
      else
        notification.update(read: false)
      end

      flash[:notice] = "Review was successfully updated."

      # Normally would have an instance of @product, but for reviews have a product_id in params
      redirect_to product_path(params[:review][:product_id])
    else
      # Error trapping
      #   Re-render the "new" product page.
      #   Because the save returned false, the error trapping on the "new" page
      #   will display the errors
      render "edit", status: :unprocessable_entity
    end
  end

  # DELETE /reviews/1 or /reviews/1.json
  def destroy
    @review.destroy!

    # NOTE:  status: :see_other (HTTP 303 See Other) is the proper redirect code after a DELETE request
    #         — it tells browsers:  “The deletion worked — now go look at this other page.
    respond_to do |format|
      format.html { redirect_to reviews_path,
                    status: :see_other,
                    notice: "Review was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def review_params
      params.expect(review: [ :body, :product_id, :read ])
    end
end
