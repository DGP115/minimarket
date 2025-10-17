class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Added "name" attribute to Devise user sign-up, so as per instructions:
  #     [https://github.com/heartcombo/devise?tab=readme-ov-file#configuring-models]
  # This caose is needed to enable the default Devise users controller to allow the name attribute
  # to pass through from the modified form
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end
end
