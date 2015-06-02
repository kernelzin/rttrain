class PicturesController < ApplicationController
  respond_to :html, :json, :xml, :js # TODO: remove js

  def index
    @pictures = Picture.all
    respond_to do |format|
      format.html
      format.json { render json:  @picturees }
    end
  end

  def resource
    @picture = Picture.find(params[:id])
  end

  def new

  end

  def create

  end

  def edit
    resource
  end

  def update(obj = nil)
    obj ||= resource
    obj.update_attributes(permitted_params)
    if resource.font.pictures.count == 1
      redirect_to(edit_box_path(resource.box.id))
    else
      redirect_to(trains_path)
    end
  end


  def show
    resource
    respond_to do |format|
      format.html
    end
  end
  private

  def permitted_params
    params.require(:picture).permit!
  end
end
