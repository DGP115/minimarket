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

  # POST /reviews or /reviews.json
  def create
    @review = current_user.reviews.new(review_params)
    respond_to do |format|
      if @review.save
        format.html do
          flash[:notice] = "Review was successfully created."
          redirect_to product_path(@review.product)
        end
        format.turbo_stream do
          # In the case of a turbo_stream, we tell turbo to:
          #   - prepend the new review
          #   - to the "reviews" section of the dom
          render turbo_stream: turbo_stream.prepend("reviews", @review)
        end
      else
        # Error trapping
        #   Re-render the "new" product page.
        #   Because the save returned false, the error trapping on the "new" page
        #   will display the errors
        render "new", status: :unprocessable_entity
      end
    end
  end

  # PATCH/PUT /reviews/1 or /reviews/1.json
  def update
    if @review.update(review_params)
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

    respond_to do |format|
      format.html { redirect_to reviews_path, status: :see_other, notice: "Review was successfully destroyed." }
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
      params.expect(review: [ :body, :product_id ])
    end
end
