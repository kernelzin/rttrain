class BoxesController < ApplicationController
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
    params[:chars]
    char = params[:chars][:char]
    x = params[:chars][:x].to_f
    y = params[:chars][:y].to_f
    w = params[:chars][:w].to_f
    h = params[:chars][:h].to_f
    @box = Box.find_by(id: params[:chars][:box])
    if params[:chars][:id]
      @char =  @box.chars.find_by(id: params[:chars][:id])
      @char.update_attributes(char: char, x1: x.round, x2: x.round + w.round, y1: y.round - h.round, y2: y.round )
    else
      @char =  @box.chars.create!(x1: x.round, x2: x.round + w.round, y1: y.round, y2: y.round + h.round )
    end
    respond_with @box do |format|
       format.json {render json: @char}
    end
  end

  def destroy
    params[:chars]
    @box = Box.find_by(id: params[:chars][:box])
    @box.chars.find_by(id: params[:chars][:id]).delete
    respond_with @box do |format|
       format.json {render json: @char}
    end
  end

  def show
    resource
    respond_to do |format|
      format.html
      format.json { render json:  @box }

    end
  end
  private

  def permitted_params
    params.require(:chars).permit!
  end

end
