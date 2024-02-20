# app/controllers/object_infos_controller.rb
class ObjectInfosController < ApplicationController
  before_action :set_compartment, only: [:create]

  def create
    @object_info = @compartment.object_infos.new(object_info_params)
    if @object_info.save
      render json: @object_info, status: :ok
    else
      render json: @object_info.errors, status: :unprocessable_entity
    end
  end

  private

  def set_compartment
    @compartment = Compartment.find(params[:compartment_id])
  end

  def object_info_params
    params.require(:object_info).permit(:description) # Ensure these params match what's sent by your JS fetch request
  end
end
