require "test_helper"
require "application_system_test_case"

# Regression test for a bug where reopening a previously-viewed image showed a stale image and
# rectangles (from whichever image was most recently freshly loaded) while showing the correct
# annotations for the newly selected image. Uses two solid-color fixture images so the canvas'
# actual pixel content can be asserted directly, not just the annotation text next to it.
class ImageModalSwitchingTest < ApplicationSystemTestCase
  include Warden::Test::Helpers

  def teardown
    Warden.test_reset!
  end

  def setup
    @user = User.create!(email: "modaltest@example.com", password: "password123")
    @space = Space.create!(name: "Warehouse", user: @user)

    @image_a = @space.images.create!(title: "Image A")
    @image_a.file.attach(
      io: File.open(Rails.root.join("test/fixtures/files/solid_red.jpg")),
      filename: "solid_red.jpg", content_type: "image/jpeg"
    )
    @compartment_a = @image_a.compartments.create!(x: 60, y: 60, width: 20, height: 20)
    @compartment_a.object_infos.create!(description: "ANNOTATION FOR A")

    @image_b = @space.images.create!(title: "Image B")
    @image_b.file.attach(
      io: File.open(Rails.root.join("test/fixtures/files/solid_blue.jpg")),
      filename: "solid_blue.jpg", content_type: "image/jpeg"
    )
    @compartment_b = @image_b.compartments.create!(x: 60, y: 60, width: 20, height: 20)
    @compartment_b.object_infos.create!(description: "ANNOTATION FOR B")
  end

  test "reopening a previously viewed image shows its own picture and annotation, not a stale one" do
    login_as @user, scope: :user
    visit "/spaces/#{@space.id}"

    open_image_card("Image A")
    assert_annotation(@compartment_a, "ANNOTATION FOR A")
    assert_canvas_shows(:red)

    close_modal

    open_image_card("Image B")
    assert_annotation(@compartment_b, "ANNOTATION FOR B")
    assert_canvas_shows(:blue)

    close_modal

    # This reopen of A is exactly the previously-broken case: a cache hit used to skip redrawing
    # the canvas entirely, leaving B's picture on screen next to A's (correct) annotation.
    open_image_card("Image A")
    assert_annotation(@compartment_a, "ANNOTATION FOR A")
    assert_canvas_shows(:red)
  end

  private

  def open_image_card(title)
    find(".image-card", text: title).find("img").click
    assert_selector "#image-modal", visible: true
  end

  def assert_annotation(compartment, text)
    # The textarea's value is filled in by an async fetch after it appears, so wait for the
    # value itself rather than just the element's presence.
    assert has_field?("description-#{compartment.id}", with: text, wait: 5),
      "expected the annotation textarea for compartment #{compartment.id} to contain #{text.inspect}"
  end

  def close_modal
    find(".close-modal").click
  end

  def canvas_pixel_color
    page.evaluate_script(<<~JS)
      (function() {
        var ctx = document.getElementById('modal-canvas').getContext('2d');
        var data = ctx.getImageData(1, 1, 1, 1).data;
        return [data[0], data[1], data[2]];
      })()
    JS
  end

  # JPEG compression means the sampled pixel isn't exactly (255,0,0)/(0,0,255), so compare with
  # a tolerance instead of exact equality.
  def assert_canvas_shows(color)
    r, g, b = canvas_pixel_color
    case color
    when :red
      assert r > 200 && g < 50 && b < 50, "expected canvas pixel to be red, got rgb(#{r},#{g},#{b})"
    when :blue
      assert b > 200 && r < 50 && g < 50, "expected canvas pixel to be blue, got rgb(#{r},#{g},#{b})"
    end
  end
end
