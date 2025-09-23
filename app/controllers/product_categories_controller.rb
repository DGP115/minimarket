class ProductCategoriesController < ApplicationController
  before_action :set_product_category, only: %i[ show edit update destroy ]

  def index
    # See application_controller.  @root_categories set there
  end

  def show
    @product_category = ProductCategory.find(params[:id])
    @products = @product_category.products.order(:title).includes([ :rich_text_description ]).with_attached_images.limit(10)
    @product_categories = @product_category.descendants.arrange(order: :name)
  end

  def new
    @product_category = ProductCategory.new
  end

  def create
    @product_category = ProductCategory.new(product_category_params)

    if @product_category.save
      redirect_to @product_category
      flash[:notice] = "Product category #{@product_category.name} was successfully created."
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product_category.update(product_category_params)
      redirect_to @product_category
      flash[:notice] = "Product category #{@product_category.name} was successfully updated."
    else
      render "edit", status: :unprocessable_entity
    end
  end

  def add_child
    @parent_category = ProductCategory.find(params[:id])
    @product_category = ProductCategory.new(parent: @parent_category)
    render "new"
  end

  def destroy
    if @product_category.destroy
      redirect_to product_categories_path
      flash[:notice] = "Product category #{product_category.name} was successfully deleted."
    else
      flash[:alert] = "Error deleting product category #{product_category.name}."
      redirect_to product_categories_path, status: :unprocessable_entity
    end
  end

  private
  def product_category_params
    params.expect(product_category: [ :name, :description, :parent_id ])
  end

  def set_product_category
    @product_category = ProductCategory.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Product category not found."
    redirect_to product_categories_path
  end
end
