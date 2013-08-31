def sign_in(user, options={})
  if options[:no_capybara]
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
  else
    visit signin_path
    fill_in "Email",    with: user.email
    fill_in "Password", with: user.password
    click_button "Sign in"
  end
end

def sign_out
  click_link "Sign out"
end

def submission_file(file_name = "valid.rb")
  File.new(Rails.root + "spec/example_files/#{file_name}")
end
