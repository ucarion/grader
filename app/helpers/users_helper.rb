module UsersHelper
  def main_profile_picture(user)
    image_tag(gravatar_image_url(user.email),
      class: "img-rounded", id: "profile-picture")
  end
end
