class SpacesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    if user_signed_in?
      # Display the user's spaces or child spaces if they are logged in
      @spaces = params[:parent_space_id].present? ? Space.find(params[:parent_space_id]).child_spaces : current_user.spaces.where(parent_space_id: nil)
    else
      # Set @spaces to all spaces
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
                         .limit(5) # you can set a limit to the number of results
                         .distinct
                         .pluck(:description)
    render json: results # This will return an array of descriptions
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
