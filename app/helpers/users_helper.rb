module UsersHelper
  def main_profile_picture(user)
    profile_picture(user, class: "img-rounded", id: "profile-picture")
  end

  def profile_picture(user, opts = {})
    opts[:class] ||= ""
    opts[:class] += " gravatar"

    image_tag(gravatar_image_url(user.email), opts)
  end

  def link_to_destroy(user)
    link_to("delete", user, method: :delete,
      data: { confirm: "Are you sure you want to delete #{user.name}?" })
  end
end
