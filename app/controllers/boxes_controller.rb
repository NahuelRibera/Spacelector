# app/controllers/boxes_controller.rb
class BoxesController < ApplicationController
  before_action :set_image

  def new
    @box = @image.boxes.new
  end

  def create
    @box = @image.boxes.new(box_params)
    if @box.save
      respond_to do |format|
        format.js
      end
    else
      render :new
    end
  end

  private

  def set_image
    @image = Image.find(params[:image_id])
  end

  def box_params
    params.require(:box).permit(:top, :left, :width, :height)
  end
end
