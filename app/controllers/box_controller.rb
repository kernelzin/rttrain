class BoxController < ApplicationController
  respond_to :html, :json, :xml, :js # TODO: remove js

  def index
    @boxes = Box.all
    respond_to do |format|
      format.html
      format.json { render json:  @boxes }
    end
  end

 def resource
    @box = Box.find(params[:id])
  end

  def new

  end

  def create

  end

  def show
    resource
    respond_to do |format|
      format.html
      format.json { render json:  @box }

    end
  end
end
