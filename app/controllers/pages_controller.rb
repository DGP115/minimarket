class PagesController < ApplicationController
  def about
    @product = Product.first
  end
end
