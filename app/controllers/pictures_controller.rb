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

  def show
    resource
    respond_to do |format|
      format.html
    end
  end
end
