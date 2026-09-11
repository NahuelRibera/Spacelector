class CompartmentsController < ApplicationController
  before_action :set_image, only: [:index, :create, :update, :destroy]
  before_action :set_compartment, only: [:update, :destroy]

  def create
    @compartment = @image.compartments.new(compartment_params)
    if @compartment.save
      redirect_to @image, notice: 'Compartment was successfully created.'
    else
      render :new
    end
  end

  def index
    compartments = @image.compartments
    render json: compartments
  end

  def update
    if @compartment.update(compartment_params)
      redirect_to @image, notice: 'Compartment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @compartment.destroy
    redirect_to @image, notice: 'Compartment was successfully destroyed.'
  end

  private

  def set_image
    @image = find_owned_image(params[:image_id])
  end

  def set_compartment
    @compartment = @image.compartments.find(params[:id])
  end

  def compartment_params
    params.require(:compartment).permit(:x, :y, :width, :height, :description)
  end
end
