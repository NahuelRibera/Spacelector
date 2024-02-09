module ImagesHelper
  def compartments_for_image(image)
    # Logic to fetch compartment data for the image
    # Assuming compartments is an array of hashes containing compartment data
    compartments = [
      { name: "Compartment 1", x: 10, y: 10, width: 50, height: 50 },
      { name: "Compartment 2", x: 100, y: 100, width: 80, height: 60 },
      # Add more compartments as needed
    ]

    # Convert compartments array to JSON and return
    compartments.to_json
  end
end
