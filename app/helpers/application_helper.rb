# Helper methods for views
module ApplicationHelper
  def flash_message_display_class(type)
    case type
    when "notice"
      "talic text-lime-700 bg-lime-100"
    when "alert"
      "font-semibold text-red-600 bg-yellow-500"
    when "error"
      "bg-yellow-100 text-yellow-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end
end
