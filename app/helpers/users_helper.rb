module UsersHelper
  def gravatar_for(user, args = {})
    id = Digest::MD5::hexdigest(user.email.downcase)
    url = "https://secure.gravatar.com/avatar/#{id}?s=#{args[:size] || 200}"
    image_tag(url, alt: user.name, class: "gravatar " + (args[:class] || ""))
  end
end
