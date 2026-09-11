require "test_helper"

class CompartmentsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @owner = User.create!(email: "owner@example.com", password: "password123")
    @other = User.create!(email: "other@example.com", password: "password123")
    @space = Space.create!(name: "Warehouse", user: @owner)
    @image = @space.images.create!(title: "Large cabinet photo")
    @compartment = @image.compartments.create!(x: 10, y: 20, width: 100, height: 150)
  end

  test "listing compartments for an image returns their coordinates" do
    sign_in @owner

    get image_compartments_path(@image)
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 1, body.length
    assert_equal 10, body.first["x"]
  end

  test "a user cannot list another user's image compartments by guessing its id" do
    sign_in @other

    get image_compartments_path(@image)
    assert_response :not_found
  end

  test "saving an annotation on a compartment persists it and reopening the image shows it again" do
    sign_in @owner

    post create_or_update_compartment_object_infos_path(@compartment), params: { object_info: { description: "tornilos y clavos" } }, as: :json
    assert_response :success
    assert_equal "tornilos y clavos", @compartment.reload.object_infos.last.description

    get image_compartments_path(@image)
    assert_response :success
  end

  test "editing an annotation updates the existing record instead of creating a new one" do
    sign_in @owner
    post create_or_update_compartment_object_infos_path(@compartment), params: { object_info: { description: "first note" } }, as: :json

    assert_no_difference "ObjectInfo.count" do
      post create_or_update_compartment_object_infos_path(@compartment), params: { object_info: { description: "updated note" } }, as: :json
    end

    assert_equal "updated note", @compartment.reload.object_infos.last.description
  end

  test "a user cannot write an annotation on another user's compartment" do
    sign_in @other

    post create_or_update_compartment_object_infos_path(@compartment), params: { object_info: { description: "hijacked" } }, as: :json
    assert_response :not_found
    assert_empty @compartment.object_infos
  end
end
