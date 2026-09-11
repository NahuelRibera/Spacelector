require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  def setup
    @owner = User.create!(email: "owner@example.com", password: "password123")
    @other = User.create!(email: "other@example.com", password: "password123")

    @warehouse = Space.create!(name: "Warehouse", user: @owner)
    @cabinet = Space.create!(name: "Large cabinet", user: @owner, parent_space: @warehouse)
    @image = @cabinet.images.create!(title: "Cabinet photo")
    @compartment = @image.compartments.create!(x: 0, y: 0, width: 10, height: 10)
    @compartment.object_infos.create!(description: "tornilos y clavos")
  end

  test "an exact search redirects straight to the matching image with the compartment highlighted" do
    sign_in @owner

    get search_spaces_path(query: "clavos")

    assert_redirected_to space_path(@cabinet, image_id: @image.id, highlight_compartment_id: @compartment.id)
  end

  test "a misspelled search still finds the annotation" do
    sign_in @owner

    get search_spaces_path(query: "tornillos")

    assert_redirected_to space_path(@cabinet, image_id: @image.id, highlight_compartment_id: @compartment.id)
  end

  test "a search with no matches redirects home with a message instead of erroring" do
    sign_in @owner

    get search_spaces_path(query: "nothingmatchesthis")

    assert_redirected_to root_path
  end

  test "autocomplete only ever returns the signed-in user's own results" do
    sign_in @other

    get autocomplete_search_path(query: "tornilos")

    assert_response :success
    assert_equal [], JSON.parse(response.body)
  end
end
