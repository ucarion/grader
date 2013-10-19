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

# Font awesome
gem "font-awesome-rails"

# For forms that require inputting dates
gem 'bootstrap-datepicker-rails'

# For dealing with file attachments for submissions
gem "paperclip", "~> 3.0"

# For playing with docker
gem 'docker-api', require: 'docker'

# For background tasks
gem 'delayed_job_active_record'

# For an activity feed
gem 'public_activity'

# For pretty graphs
gem "highcharts-rails", "~> 3.0.0"

# For enums
gem 'classy_enum'

# For nested forms
gem 'cocoon'

# For finding string similarity
gem 'damerau-levenshtein'

gem 'candela', path: '~/ruby/candela'

group :test do
  gem 'selenium-webdriver'
  gem 'capybara'

  # for capybara's save_and_open_page
  gem 'launchy'

  gem 'factory_girl_rails'
end
