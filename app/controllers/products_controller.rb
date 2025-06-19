class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show edit update destroy ]
  # authenticate_user is provided by Devise
  before_action :authenticate_user!, only: %i[ new create edit update destroy ]
  before_action :require_same_user, only: %i[ edit update destroy ]

  def index
    @products = Product.all
  end

  def show
  end

  def new
    @product = current_user.products.new
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
  end

  def update
    if @product.save
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

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def whitelisted_params
    params.expect(product: [ :title, :description, :price ])
  end

  def require_same_user
    if @product.seller_id != current_user.id
      flash[:alert] = "You can only alter your own products"
      redirect_to @product
    end
  end
end
