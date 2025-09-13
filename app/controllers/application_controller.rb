class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # @root_categories is needed for row 2 of the navbar, so set it on each invocation of a controller.
  before_action :set_root_categories

  # Added "name" attribute to Devise user sign-up, so as per instructions:
  #     [https://github.com/heartcombo/devise?tab=readme-ov-file#configuring-models]
  # This caose is needed to enable the default Devise users controller to allow the name attribute
  # to pass through from the modified form
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  private

  # Since root categories won't change much, cache them in the Rails cache.
  def set_root_categories
    @root_categories = Rails.cache.fetch("root_categories", expires_in: 12.hours) do
      ProductCategory.roots.order(orderindex: :asc).to_a
    end
  end
end
