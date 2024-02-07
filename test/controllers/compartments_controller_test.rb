require "test_helper"

class CompartmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get compartments_create_url
    assert_response :success
  end
end
