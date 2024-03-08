class ImagesController < ApplicationController
  before_action :set_space, only: [:new, :create, :show]

  def create
    @image = @space.images.new(image_params)
    @image.file.attach(params[:image][:file])
    @image.file_path = @image.file.key

    if @image.save
      redirect_to space_path(@space), notice: 'Image successfully uploaded.'
    else
      render :new
    end
  end

  def new
    @image = Image.new
    @compartment = @image.compartments.build  # Initialize a new compartment associated with the image
  end

  def show
    @image = Image.find(params[:id])
    @compartments = @image.compartments || [] # Initialize @compartments to an empty array if it's nil
  end

  def convert_heic
    file = params[:file]

    if file.content_type == 'image/heic'
      # ... existing logic to convert the file ...

      url = url_for(converted_blob) # Generates a URL for direct access to the blob
      render json: { preview_url: url }, status: :ok
    else
      render json: { error: "Unsupported file type." }, status: :unprocessable_entity
    end
  rescue => e
    Rails.logger.error("HEIC conversion failed: #{e.message}")
    render json: { error: "Error processing the image: #{e.message}" }, status: :unprocessable_entity
  end

  def destroy
    @space = Space.find(params[:space_id])
    @image = @space.images.find(params[:id])
    @image.destroy
    redirect_to @space, notice: 'Image was successfully deleted.'
  end

  private

  def image_params
    params.require(:image).permit(:file, :title, compartments_attributes: [:name, :x, :y, :width, :height])
  end

  def set_space
    @space = Space.find(params[:space_id])
  end
end
