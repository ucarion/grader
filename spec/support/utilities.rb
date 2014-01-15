def submission_file(file_name = "valid.rb")
  File.new(Rails.root + "spec/example_files/#{file_name}")
end

def sign_in(user)
  sign_out if signed_in?

  visit signin_path
  fill_in "Email",    with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def sign_out
  click_link "Sign out"
end

def signed_in?
  page.has_link?('', href: signout_path)
end
