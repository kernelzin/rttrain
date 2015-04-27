class TrainController < ApplicationController
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

  end

  def create

  end

  def show
    resource
    respond_to do |format|
      format.html
      format.json { render json:  @train }

    end
  end
end
