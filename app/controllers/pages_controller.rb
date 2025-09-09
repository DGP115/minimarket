class PagesController < ApplicationController
  def home
    if user_signed_in?
      # NOTE:  redirect_to is required here as it is the proper way for one controller
      # to invoke the method of another
      redirect_to product_categories_path
    else
      render :home
    end
  end
  def about
  end
end
