require "test_helper"

class ImagesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @owner = User.create!(email: "owner@example.com", password: "password123")
    @other = User.create!(email: "other@example.com", password: "password123")
    @space = Space.create!(name: "Warehouse", user: @owner)
    @file = fixture_file_upload("test_image.jpg", "image/jpeg")
  end

  test "uploading an image with compartments persists the image, its file and its coordinates" do
    sign_in @owner

    assert_difference "Image.count", 1 do
      assert_difference "Compartment.count", 2 do
        post space_images_path(@space), params: {
          image: {
            title: "Large cabinet photo",
            file: @file,
            compartments_attributes: {
              "0" => { x: 10, y: 20, width: 100, height: 150 },
              "1" => { x: 200, y: 20, width: 100, height: 150 }
            }
          }
        }
      end
    end

    image = @space.images.order(:created_at).last
    assert_redirected_to space_path(@space)
    assert image.file.attached?
    assert_equal [10, 200], image.compartments.order(:x).pluck(:x)
  end

  test "rejects a file type that cannot be processed, without saving anything" do
    sign_in @owner
    bad_file = fixture_file_upload("test_image.jpg", "text/plain")

    assert_no_difference "Image.count" do
      post space_images_path(@space), params: { image: { title: "Not an image", file: bad_file } }
    end

    assert_response :unprocessable_entity
  end

  test "a user cannot upload into another user's space by guessing its id" do
    sign_in @other

    assert_no_difference "Image.count" do
      post space_images_path(@space), params: { image: { title: "Intruder photo", file: @file } }
    end

    assert_response :not_found
  end

  test "a user cannot open another user's image by guessing its id" do
    sign_in @owner
    post space_images_path(@space), params: { image: { title: "Photo", file: @file } }
    image = @space.images.order(:created_at).last

    sign_out @owner
    sign_in @other

    get space_image_path(@space, image)
    assert_response :not_found
  end
end
