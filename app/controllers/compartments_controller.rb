class CompartmentsController < ApplicationController
  before_action :set_image, only: [:index, :create, :update, :destroy]
  before_action :set_compartment, only: [:update, :destroy]

  # POST /images/:image_id/compartments
  def create
    @compartment = @image.compartments.new(compartment_params)
    if @compartment.save
      redirect_to @image, notice: 'Compartment was successfully created.'
    else
      render :new
    end
  end

  def create_or_update_object_info
    puts "Description received: #{params[:object_info][:description]}"
    # Rest of your logic to handle the creation or update
  end

  def index
    image = Image.find(params[:image_id])
    compartments = image.compartments
    render json: compartments
  end

  # PATCH/PUT /images/:image_id/compartments/:id
  def update
    if @compartment.update(compartment_params)
      redirect_to @image, notice: 'Compartment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /images/:image_id/compartments/:id
  def destroy
    @compartment.destroy
    redirect_to @image, notice: 'Compartment was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_image
    @image = Image.find(params[:image_id])
  end

  def set_compartment
    @compartment = @image.compartments.find(params[:id])
  end

  def compartment_params
    params.require(:compartment).permit(:x, :y, :width, :height, :description) # Ensure :description is permitted if it's part of your model
  end
end
