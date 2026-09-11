require "test_helper"

class SearchServiceTest < ActiveSupport::TestCase
  def setup
    @owner = User.create!(email: "owner@example.com", password: "password123")
    @other = User.create!(email: "other@example.com", password: "password123")

    @warehouse = Space.create!(name: "Warehouse", user: @owner)
    @cabinet = Space.create!(name: "Large cabinet", user: @owner, parent_space: @warehouse)
    @image = @cabinet.images.create!(title: "Cabinet photo")
    @compartment = @image.compartments.create!(x: 0, y: 0, width: 10, height: 10)
    @compartment.object_infos.create!(description: "tornilos y clavos")
  end

  test "finds an annotation via an exact substring match" do
    results = SearchService.new(@owner, "clavos").results
    assert_equal 1, results.length
    assert_equal :annotation, results.first.type
    assert_equal "Warehouse → Large cabinet", results.first.location
  end

  test "tolerates a small typo via fuzzy matching" do
    results = SearchService.new(@owner, "tornillos").results
    assert results.any? { |r| r.label == "tornilos y clavos" }
  end

  test "ranks an exact match above a fuzzy one" do
    @warehouse2 = Space.create!(name: "tornillos", user: @owner)

    results = SearchService.new(@owner, "tornillos").results
    assert_equal "tornillos", results.first.label
  end

  test "does not return results for unrelated queries" do
    results = SearchService.new(@owner, "xyzunrelatedquery").results
    assert_empty results
  end

  test "finds a subspace by name" do
    results = SearchService.new(@owner, "Large cabinet").results
    assert results.any? { |r| r.type == :subspace && r.label == "Large cabinet" }
  end

  test "finds an image by title" do
    results = SearchService.new(@owner, "Cabinet photo").results
    assert results.any? { |r| r.type == :image && r.label == "Cabinet photo" }
  end

  test "never returns another user's data" do
    results = SearchService.new(@other, "tornilos").results
    assert_empty results
  end
end
