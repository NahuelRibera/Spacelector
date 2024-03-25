class ImagesController < ApplicationController
  before_action :set_space, only: [:new, :create, :show, :destroy]
  skip_before_action :verify_authenticity_token, only: [:convert_heic]

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

  def conversion_complete
    image = Image.find(params[:id])
    if image.converted?
      render json: { converted: true, url: rails_blob_url(image.file) }
    else
      render json: { converted: false }
    end
  end

  def convert_heic
    file = params[:file]

    if file.content_type == 'image/heic'
      require "image_processing/mini_magick"

      # Temporarily save the uploaded file to disk
      uploaded_file = Tempfile.new(['upload', '.heic'])
      File.binwrite(uploaded_file.path, file.read)

      # Perform the conversion
      processed_image = ImageProcessing::MiniMagick
                          .source(uploaded_file.path)
                          .convert("jpg")
                          .call

      # Create a new blob from the processed image
      converted_blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(processed_image.path, 'rb'),
        filename: "#{file.original_filename.split('.').first}.jpg",
        content_type: 'image/jpeg'
      )

      # Clean up temporary files
      uploaded_file.close
      uploaded_file.unlink
      processed_image.close
      processed_image.unlink

      # Respond with the URL to the converted image
      render json: { preview_url: rails_blob_url(converted_blob) }, status: :ok
    else
      render json: { error: "Unsupported file type." }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
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
