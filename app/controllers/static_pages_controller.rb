class StaticPagesController < ApplicationController
  def index
  end

  def boom
    @jam = params[:is_this]
    @jamz = params[:franks_red]
  end
end
