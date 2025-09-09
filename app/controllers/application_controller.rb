class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # @root_categories is needed for row 2 of the navbar, so set it on each invocation of a controller.
  before_action :set_root_categories

  private

  # Since root categories won't change much, cache them in the Rails cache.
  def set_root_categories
    @root_categories = Rails.cache.fetch("root_categories", expires_in: 12.hours) do
      ProductCategory.roots.order(orderindex: :asc).to_a
    end
  end
end
