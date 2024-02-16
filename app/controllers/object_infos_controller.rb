class ObjectInfosController < ApplicationController
  before_action :set_compartment

  def create
    @object_info = @compartment.object_infos.new(object_info_params)
    if @object_info.save
      render json: @object_info, status: :created
    else
      render json: @object_info.errors, status: :unprocessable_entity
    end
  end

  private

  def set_compartment
    @compartment = Compartment.find(params[:compartment_id])
  end

  def object_info_params
    params.require(:object_info).permit(:name, :description, :quantity)
  end
end
