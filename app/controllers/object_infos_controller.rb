class ObjectInfosController < ApplicationController
  before_action :set_compartment

  def create
    # Find an existing object_info or initialize a new one
    @object_info = @compartment.object_infos.find_or_initialize_by(id: params[:id])

    # Update attributes and save
    if @object_info.update(object_info_params)
      render json: @object_info, status: :ok
    else
      render json: @object_info.errors, status: :unprocessable_entity
    end
  end

  private

  def set_compartment
    @compartment = Compartment.find(params[:compartment_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Compartment not found' }, status: :not_found
  end

  def object_info_params
    # Ensure you permit only the params that should be allowed to be updated
    params.require(:object_info).permit(:description)
  end
end
