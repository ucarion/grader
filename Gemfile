source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'
gem 'unicorn'

group :development do
  gem 'awesome_print'

  gem 'debugger'

  # Charliesome's better errors and REPL
  # Make sure this _never_ goes in production.
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'capistrano', '~> 3.0'
  gem 'capistrano-rvm'
  gem 'capistrano-bundler'
  gem 'capistrano-rails'
end

group :development, :test do
  gem 'rspec-rails'

  gem 'factory_girl_rails'
end

# Use Postgres as a database
gem 'pg'

# For authentication
gem 'devise'

# For authorization
gem 'pundit'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

gem 'therubyracer'

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

# For running DelayedJob as a daemon
gem 'daemons'

# For pretty graphs
gem "highcharts-rails", "~> 3.0.0"

# For enums
gem 'classy_enum'

# For nested forms
gem 'cocoon'

# For finding string similarity
gem 'damerau-levenshtein'

# For displaying similar strings
gem 'diffy'

# For linking to Gravatars
gem 'gravatar_image_tag'

# Syntax highlighting and Markdown
gem 'redcarpet'
gem 'pygments.rb' # why the .rb? Because screw you, that's why.

# Cron jobs
gem 'whenever', require: false

# Human sorting
gem 'naturally'

# Static markdown -- pages like 'about', 'help', etc.
gem 'markdown-rails'

gem 'nokogiri'

gem 'figaro'

group :test do
  gem 'selenium-webdriver'
  gem 'capybara'

  # for capybara's save_and_open_page
  gem 'launchy'
end
