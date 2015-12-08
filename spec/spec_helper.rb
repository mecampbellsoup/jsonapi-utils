require 'rails/all'
require 'rails/test_help'
require 'rspec/rails'
require 'smart_rspec'
require 'factory_girl'

require 'jsonapi-resources'
require 'jsonapi/utils'

require 'pry'

require 'support/helpers'

##
# General configs
##

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Helpers::ResponseParser

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

Rails.env = 'test'

JSONAPI.configure do |config|
  config.json_key_format = :underscored_key
  config.default_paginator = :paged
end

##
# Rails application
##

puts "RAILS VERSION: #{Rails.version}"

class TestApp < Rails::Application
  config.eager_load = false
  config.root = File.dirname(__FILE__)
  config.session_store :cookie_store, key: 'session'
  config.secret_key_base = 'secret'

  #Raise errors on unsupported parameters
  config.action_controller.action_on_unpermitted_parameters = :raise

  ActiveRecord::Schema.verbose = false
  config.active_record.schema_format = :none
  config.active_support.test_order = :random

  # Turn off millisecond precision to maintain Rails 4.0 and 4.1 compatibility in test results
  Rails::VERSION::MAJOR >= 4 && Rails::VERSION::MINOR >= 1 &&
    ActiveSupport::JSON::Encoding.time_precision = 0
end

TestApp.initialize!

Dir[Rails.root.join('support/shared/**/*.rb')].each { |f| require f }

require 'support/models'
require 'support/factories'
require 'support/resources'
require 'support/controllers'

##
# Routes
##

JSONAPI.configuration.route_format = :dasherized_route

TestApp.routes.draw do
  jsonapi_resources :users do
    jsonapi_resources :posts
  end
end

