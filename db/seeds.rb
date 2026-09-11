# Loads a small, reproducible demo: one user, a couple of spaces/subspaces, two images with
# drawn compartments and annotations (including a deliberate typo, to show off fuzzy search).
#
# Run with: bin/rails db:seed
#
# It is idempotent (find_or_create_by!) and additive: it never deletes anything, and re-running
# it is safe. It refuses to run against production, since it creates a fixed, publicly known
# login (see README) that should never exist on a real deployment.

if Rails.env.production?
  puts "Skipping db/seeds.rb: refusing to create the fixed demo account in production."
  return
end

demo_user = User.find_or_create_by!(email: "demo@spacelector.dev") do |user|
  user.password = "spacelector123"
end

warehouse = Space.find_or_create_by!(name: "Warehouse", user: demo_user, parent_space_id: nil)
cabinet = Space.find_or_create_by!(name: "Large cabinet", user: demo_user, parent_space: warehouse)
lockers = Space.find_or_create_by!(name: "Lockers", user: demo_user, parent_space: warehouse)

def seed_image(space, title, file_name, compartments)
  image = space.images.find_or_create_by!(title: title) do |img|
    img.file.attach(
      io: File.open(Rails.root.join("db/seed_images", file_name)),
      filename: file_name,
      content_type: "image/jpeg"
    )
  end

  return image if image.compartments.any?

  compartments.each do |coords|
    compartment = image.compartments.create!(x: coords[:x], y: coords[:y], width: coords[:width], height: coords[:height])
    compartment.object_infos.create!(description: coords[:description])
  end

  image
end

seed_image(cabinet, "Cabinet drawers", "cabinet_drawers.jpg", [
  { x: 40, y: 100, width: 260, height: 180, description: "screws nuts bolts" },
  { x: 340, y: 100, width: 260, height: 180, description: "cables chargers" },
  # Deliberate typo ("tornillos" misspelled) to demonstrate approximate/fuzzy search.
  { x: 640, y: 100, width: 260, height: 180, description: "tornilos sueltos" }
])

seed_image(lockers, "Lockers row", "lockers.jpg", [
  { x: 60, y: 120, width: 400, height: 220, description: "winter coats" },
  { x: 500, y: 120, width: 400, height: 220, description: "cleaning suplies" }
])

puts "Seeded demo account: demo@spacelector.dev / spacelector123"
puts "Spaces: #{Space.where(user: demo_user).count}, Images: #{Image.joins(:space).where(spaces: { user: demo_user }).count}"
