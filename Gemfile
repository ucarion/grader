source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Use sqlite3 as the database for Active Record
group :development, :test do
  gem 'rspec-rails'
  gem 'sqlite3'
end

# Heroku uses postgres
group :production do
  gem 'pg'
end

group :assets do
  # Use SCSS for stylesheets
  gem 'sass-rails', '~> 4.0.0'

  # Use Uglifier as compressor for JavaScript assets
  gem 'uglifier', '>= 1.3.0'

  # Use CoffeeScript for .js.coffee assets and views
  gem 'coffee-rails', '~> 4.0.0'
end

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Use bootstrap from SCSS as CSS library
gem 'bootstrap-sass'

# For password hashing
gem 'bcrypt-ruby', '3.0.1'

# For fake data
gem 'faker'

# Data pagination
gem 'bootstrap-will_paginate'

group :test do
  gem 'selenium-webdriver'
  gem 'capybara'

  gem 'factory_girl_rails'
end
