# Helper methods for views
module ApplicationHelper
  def flash_message_display_class(type)
    case type
    when "notice"
      "italic text-lime-700 bg-lime-100"
    when "alert"
      "font-semibold text-red-600 bg-yellow-500"
    when "error"
      "bg-yellow-100 text-yellow-800"
    else
      "bg-gray-100 text-gray-800"
    end
  end

  # Create a funny avator for each user, using a hash of their username taken from Gravatar
  def avatar_for(user, options = { size: "300x300" })
    email_address = user.email.downcase
    hash = Digest::MD5.hexdigest(email_address)
    size = options[:size]
    robot_url = "https://robohash.org/#{hash}.png/bgset_any?size=#{size}"
    image_tag(robot_url, alt: current_user.name, class: "rounded-circle shadow")
  end

  def avatar_for_name(name, options = { size: "300x300" })
    hash = Digest::MD5.hexdigest(name)
    size = options[:size]
    robot_url = "https://robohash.org/#{hash}.png/bgset_any?size=#{size}"
    image_tag(robot_url, alt: name, class: "rounded-circle shadow")
  end
end
