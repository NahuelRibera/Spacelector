class ImagesController < ApplicationController
  before_action :set_space, only: [:new, :create, :show]

  def create
    @image = @space.images.new(image_params)
    @image.file.attach(params[:image][:file]) # Attach the file
    @image.file_path = @image.file.key # Set the file_path to the attachment key

    if @image.save
      redirect_to space_path(@space), notice: 'Image successfully uploaded.'
    else
      render :new
    end
  end

  def new
    @image = Image.new # Create a new image instance without associating it to any space yet
  end

  def show
    @image = Image.find(params[:id])
    @boxes = @image.boxes
  end

  private

  def image_params
    params.require(:image).permit(:file, :title)
  end

  def set_space
    @space = Space.find(params[:space_id])
  end
end
