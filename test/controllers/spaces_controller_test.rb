require "test_helper"

class SpacesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @owner = User.create!(email: "owner@example.com", password: "password123")
    @other = User.create!(email: "other@example.com", password: "password123")
    @space = Space.create!(name: "Warehouse", user: @owner)
  end

  test "creating a space and opening it works end to end" do
    sign_in @owner

    assert_difference "Space.count", 1 do
      post spaces_path, params: { space: { name: "Garage" } }
    end

    space = Space.order(:created_at).last
    assert_redirected_to space_path(space)

    follow_redirect!
    assert_response :success
    assert_select "h1", "Garage"
  end

  test "a subspace can be created and reopened under its parent" do
    sign_in @owner

    post spaces_path, params: { space: { name: "Large cabinet", parent_space_id: @space.id } }
    subspace = Space.order(:created_at).last
    assert_equal @space.id, subspace.parent_space_id

    get space_path(subspace)
    assert_response :success
  end

  test "a user cannot open another user's space by guessing its id" do
    sign_in @other

    get space_path(@space)
    assert_response :not_found
  end

  test "a user cannot delete another user's space by guessing its id" do
    sign_in @other

    assert_no_difference "Space.count" do
      delete space_path(@space)
    end
  end

  test "a user cannot rename another user's space by guessing its id" do
    sign_in @other

    patch update_space_name_path(@space), params: { name: "Hijacked" }, as: :json
    assert_response :not_found
    assert_equal "Warehouse", @space.reload.name
  end

  test "signed out visitors see the homepage, never another user's spaces" do
    get spaces_path
    assert_response :success
    assert_select "h1", text: @space.name, count: 0
  end

  test "opening a space that does not exist returns 404, not a crash" do
    sign_in @owner
    get space_path(id: 999_999)
    assert_response :not_found
  end
end
