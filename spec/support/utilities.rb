def sign_in(user)
  visit signin_path
  fill_in "Email", user.Email
  fill_in "Password", user.password
  click_button "Sign in"
end
