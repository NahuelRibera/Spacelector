class SpacesController < ApplicationController
  before_action :authenticate_user!

  def index
    @spaces = params[:parent_space_id].present? ? Space.find(params[:parent_space_id]).child_spaces : current_user.spaces.where(parent_space_id: nil)
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

  def show
    @space = Space.find(params[:id])
    @child_spaces = @space.child_spaces
  end

  def destroy
    @space = Space.find(params[:id])
    if @space.destroy
      flash[:notice] = 'Space was successfully deleted.'
    else
      flash[:alert] = 'Error deleting space.'
    end

    if @space.parent_space
      redirect_to space_path(@space.parent_space)
    else
      redirect_to spaces_path
    end
  end


  private

  def space_params
    params.require(:space).permit(:name, :parent_space_id)
  end
end
