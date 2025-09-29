source 'https://rubygems.org'

ruby '3.2.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.5', '>= 7.1.5.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

gem 'active_model_serializers', '~> 0.10.15'
gem 'pagy', '~> 9.4'
gem 'pundit', '~> 2.4'

group :development do
  gem 'debug', platforms: %i[mri windows]
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'selenium-webdriver'
end

group :development, :test do
  gem 'factory_bot_rails', '~> 6.5'
  gem 'faker', '~> 3.5'
  gem 'pundit-matchers', '~> 4.0'
  gem 'rspec-rails',         '~> 7.1'
  gem 'rubocop',             '~> 1.81', require: false
  gem 'rubocop-factory_bot', '~> 2.26', require: false
  gem 'rubocop-rails',       '~> 2.33', require: false
  gem 'rubocop-rspec',       '~> 3.0', require: false
end
gem 'bcrypt', '~> 3.1.7'
gem 'jwt', '~> 2.8'
