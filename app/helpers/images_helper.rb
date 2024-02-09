module ImagesHelper
  def compartments_for_image(image)
    image.compartments.map { |compartment| { name: compartment.name, x: compartment.x, y: compartment.y, width: compartment.width, height: compartment.height } }.to_json
  end
end
