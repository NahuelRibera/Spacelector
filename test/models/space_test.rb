require "test_helper"

class SpaceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "owner@example.com", password: "password123")
  end

  test "belongs to a user" do
    space = Space.create!(name: "Warehouse", user: @user)
    assert_equal @user, space.user
  end

  test "a space can have subspaces via parent_space_id" do
    warehouse = Space.create!(name: "Warehouse", user: @user)
    cabinet = Space.create!(name: "Large cabinet", user: @user, parent_space: warehouse)

    assert_equal warehouse, cabinet.parent_space
    assert_includes warehouse.child_spaces, cabinet
  end

  test "destroying a space destroys its subspaces and images" do
    warehouse = Space.create!(name: "Warehouse", user: @user)
    cabinet = Space.create!(name: "Large cabinet", user: @user, parent_space: warehouse)
    image = cabinet.images.create!(title: "Photo")

    warehouse.destroy

    assert_nil Space.find_by(id: cabinet.id)
    assert_nil Image.find_by(id: image.id)
  end
end
