class SearchController < ApplicationController
  def index
    if params[:q].present?
      # Use left_outer_joins to include products without a category
      @query = Product.left_outer_joins(:product_category).ransack(params[:q])

      @products = @query.result(distinct: false).includes(:product_category)

    else
      @query = Product.ransack(params[:q])
      @products = Product.none   # empty ActiveRecord::Relation
    end
  end

  def clear
    @query = Product.ransack(params[:q])
    @products = Product.none   # empty ActiveRecord::Relation
    redirect_to search_path
  end
end
