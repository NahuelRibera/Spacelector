module ImagesHelper
  def compartments_for_image(image)
    image.compartments.select(:name, :x, :y, :width, :height).map do |compartment|
      {
        name: compartment.name,
        x: compartment.x,
        y: compartment.y,
        width: compartment.width,
        height: compartment.height
      }
    end.to_json
  end
end
