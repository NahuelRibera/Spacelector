module ImagesHelper
  def compartments_for_image(image)
    image.compartments.select(:id, :name, :x, :y, :width, :height).map do |compartment|
      {
        id: compartment.id, # Ensure the ID is included here
        name: compartment.name,
        x: compartment.x,
        y: compartment.y,
        width: compartment.width,
        height: compartment.height
      }
    end.to_json.html_safe
  end
end
