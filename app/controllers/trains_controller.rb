class TrainsController < ApplicationController
  respond_to :html, :json, :xml, :js # TODO: remove js

  def index
    @trains = Train.all
    respond_to do |format|
      format.html
      format.json { render json:  @trains }
    end
  end

 def resource
    @train = Train.find(params[:id])
  end

  def new
    @train =  Train.new
  end

  def create
    @train = Train.new(permitted_params)
    render "new"
    @train.save
  end

  def show
    resource
    respond_to do |format|
      format.html
      format.json { render json:  @train }

    end
  end
  private
  def permitted_params
    params.require(:train).permit(:name, fonts_attributes: [:name, :italic, :bold, :fixed, :serif, :fraktur, :_destroy])
  end
end
