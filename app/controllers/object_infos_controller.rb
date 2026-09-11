class ObjectInfosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_compartment, only: [:create_or_update, :last]

  def create_or_update
    @object_info = @compartment.object_infos.first_or_initialize
    if @object_info.update(object_info_params)
      render json: @object_info, status: :ok
    else
      render json: @object_info.errors, status: :unprocessable_entity
    end
  end

  def last
    @object_info = @compartment.object_infos.last
    if @object_info
      render json: @object_info, status: :ok
    else
      render json: {}, status: :not_found
    end
  end

  private

  def set_compartment
    @compartment = Compartment.joins(image: :space).merge(current_user.spaces).find(params[:compartment_id])
  end

  def object_info_params
    params.require(:object_info).permit(:description)
  end
end
