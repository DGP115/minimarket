class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy remove_image ]

  # authenticate_user! is provided by Devise
  before_action :authenticate_user!, only: %i[ new create edit update destroy ]

  before_action :require_same_user, only: %i[ edit update destroy ]

  def show
    # Will need product reviews
    @reviews = @product.reviews.includes([ :user ]).order(created_at: :desc)
    # Preload current_user's review if they have one
    if user_signed_in?
      @current_user_review = @reviews.find { |r| r.user_id == current_user.id }
    else
      @current_user_review = nil
    end
    # Be ready with a new review object
    @new_review = @product.reviews.new(user_id: current_user&.id)
  end

  def new
    @product = current_user.products.new
    if !params[:product_category_id].nil?
      @product.product_category_id = params[:product_category_id]
      set_product_category_tree
    else
      flash[:alert] = "Can't create a product without specifying a category"
      render "new", status: :unprocessable_entity
    end
  end

  def create
    @product = current_user.products.new(whitelisted_params)

    if @product.save
      flash[:notice] = "Product #{@product.title} successfully created"
      redirect_to product_path(@product)
    else
      # Error trapping
      #   Re-render the "new" product page.
      #   Because the save returned false, the error trapping on the "new" page
      #   will display the errors
      render "new", status: :unprocessable_entity
    end
  end

  def edit
    set_product_category_tree
  end

  def update
    if @product.update(whitelisted_params)
      flash[:notice] = "Product #{@product.title} updated successfully"
      redirect_to product_path(@product)
    else
      # Error trapping
      #   Re-render the "edit" product page.
      #   Because the save returned false, the error trapping on the "new" page
      #   will display the errors
      render "edit", status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy

      flash[:notice] = "Product #{@product.title} deleted"
      redirect_to products_path

    else
      # Error trapping
      #   Re-render the "edit" product page.
      #   Because the save returned false, the error trapping on the "edit" page
      #   will display the errors
      render "edit", status: :unprocessable_entity
    end
  end

  def remove_image
    begin
      image_to_remove = @product.images.find(params[:attachment_id])
      image_to_remove.purge
        flash[:notice] = "Image removed successfully"
        redirect_to edit_product_path(@product)
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      flash[:alert] = "Invalid image ID"
      redirect_to edit_product_path(@product), status: :unprocessable_entity and return
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Image not found"
      redirect_to edit_product_path(@product), status: :not_found and return
    rescue => e
      Rails.logger.error "Failed to remove image: #{e.message}"
      flash[:alert] = "Failed to remove image"
      redirect_to edit_product_path(@product), status: :internal_server_error and return
    end
  end

  private

  def set_product
    # @product = Product.includes(product_category: {}).with_attached_images.limit(10).find(params[:id])
    @product = Product.find(params[:id])
  end

  def set_product_category_tree
    root = @product.product_category.root
    #  Need ALL product categories [under this root] to populate the dropdown that allows the user
    #  to reassign the product's category
    @product_categories = root.descendants.arrange(order: :name)
  end

  def whitelisted_params
    params.expect(product: [ :title, :description, :price, :product_category_id, :primary_image, images: [] ])
  end

  def require_same_user
    if @product.seller_id != current_user.id
      flash[:alert] = "You can only alter your own products"
      redirect_to @product
    end
  end
end
