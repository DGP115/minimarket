class ProductCategoriesController < ApplicationController
  before_action :set_product_category, only: %i[ show edit update destroy ]

  def index
    @root_categories = ProductCategory.roots.order(orderindex: :asc)
  end

  def root
    @root_category = ProductCategory.find(params[:id])
    @product_categories = @root_category.descendants.arrange(order: :name)
    render partial: "product_categories/category_tree",
           locals: { root: @root_category, product_categories: @product_categories }
  end

  def show
    @product_category = ProductCategory.find(params[:id])
    @products = @product_category.products.order(:title)
    @product_categories = @product_category.descendants.arrange(order: :name)
    render partial: "product_categories/product_list",
           locals: { product_category: @product_category,
                     products: @products,
                     product_categories: @product_categories }
  end

  def new
    @product_category = ProductCategory.new
  end

  def create
    @product_category = ProductCategory.new(product_category_params)
    if @product_category.save
      redirect_to @product_category
      flash[:notice] = "Product category #{product_category.name} was successfully created."
    else
      render "new", status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product_category.update(product_category_params)
      redirect_to @product_category
      flash[:notice] = "Product category #{product_category.name} was successfully updated."
    else
      render "edit", status: :unprocessable_entity
    end
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
