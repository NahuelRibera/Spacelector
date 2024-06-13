class SpacesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    if user_signed_in?
      # Display the user's spaces or child spaces if they are logged in
      @spaces = params[:parent_space_id].present? ? Space.find(params[:parent_space_id]).child_spaces : current_user.spaces.where(parent_space_id: nil)
    else
      # Set @spaces to all spacess
      @spaces = Space.all
    end
  end

  def new
    @space = Space.new
    @space.parent_space_id = params[:parent_space_id] if params[:parent_space_id].present?
  end

  def create
    @space = current_user.spaces.new(space_params)
    if @space.save
      redirect_to space_path(@space), notice: 'Space was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def search
    query = params[:query]
    # Adjust the query based on where the searchable information is actually stored.
    # This example assumes a direct relationship for simplicity.
    compartments = Compartment.joins(:object_infos).where("object_infos.description ILIKE ?", "%#{query}%").distinct

    if compartments.any?
      # Assuming each compartment is related to one image, and each image to one space.
      # This will need adjustment based on your actual data model.
      compartment = compartments.first
      image = compartment.image
      space = image.space
      redirect_to space_path(space, image_id: image.id, highlight_compartment_id: compartment.id)
    else
      redirect_to root_path, alert: 'No results found.'
    end
  end

  def autocomplete_search
    query = params[:query]
    results = Compartment.joins(:object_infos)
                         .where("object_infos.description ILIKE ?", "%#{query}%")
                         .limit(5)
                         .distinct
                         .pluck('object_infos.description')

    # Split by slashes or commas and then further split by spaces to get individual words
    results = results.map { |description| description.split(/[\/,]/).map(&:strip) }.flatten
    results = results.map { |item| item.split(/\s+/) }.flatten
    results = results.select { |word| word.downcase.start_with?(query.downcase) }
    render json: results.uniq
  end

  def show
    @space = Space.find(params[:id])
    @image = @space.images.first # Or fetch the desired image using your logic
    @compartments = @image.compartments if @image.present?
    @child_spaces = @space.child_spaces
  end

  def destroy
    @space = Space.find(params[:id])
    if @space.destroy
      flash[:notice] = 'Space was successfully deleted.'
      redirect_to spaces_path
    else
      flash[:alert] = 'Error deleting space.'
      redirect_to space_path(@space)
    end
  end

  def update_name
    @space = Space.find(params[:id])
    if @space.update(name: params[:name])
      render json: { success: true, message: 'Space name successfully updated' }
    else
      render json: { success: false, errors: @space.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def space_params
    params.require(:space).permit(:name, :parent_space_id)
  end
end
