class ErrorsController < ApplicationController
  # This controller handles routing errors and other errors.
  # It is used to display user-friendly error pages.

  # Action for handling 404 Not Found errors
  def not_found
    render file: "#{Rails.root}/public/404.html", status: :not_found, layout: false
  end
end
