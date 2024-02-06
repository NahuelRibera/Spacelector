class CompartmentsController < ApplicationController
  before_action :set_image

  def create
    @compartment = @image.compartments.new(compartment_params)
    if @compartment.save
      render json: @compartment, status: :created
    else
      render json: @compartment.errors, status: :unprocessable_entity
    end
  end

  private

  def set_image
    @image = Image.find(params[:image_id])
  end

  def compartment_params
    params.require(:compartment).permit(:name, :x, :y, :width, :height)
  end
end
