ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  # Routes are scoped under an optional (:locale) segment; without this, calling a path
  # helper with a single positional argument (e.g. space_path(@space)) binds it to :locale
  # instead of :id, since default_url_options here isn't ApplicationController's.
  setup do
    Rails.application.routes.default_url_options[:locale] = "en"
  end
end
