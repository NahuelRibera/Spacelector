class ObjectInfosController < ApplicationController
  before_action :authenticate_user! # Assuming you're using Devise for authentication
  before_action :set_compartment, only: [:create]

  def create
    @object_info = @compartment.object_infos.build(object_info_params)
    if @object_info.save
      render json: @object_info, status: :created
    else
      render json: @object_info.errors, status: :unprocessable_entity
    end
  end

  private

  def set_compartment
    @compartment = current_user.compartments.find(params[:compartment_id])
  end

  def object_info_params
    params.require(:object_info).permit(:description) # Ensure these params match what's sent by your JS fetch request
  end
end
