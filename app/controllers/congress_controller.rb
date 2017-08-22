class CongressController < ApplicationController
  layout 'congress'

  def index
    render layout: nil
  end

  def new
    @accept = ['cg']
    @accept << 'he' if params[:he]
    @accept << 'ru' if params[:ru]
    @accept << 'en' if params[:en]
    @accept << 'es' if params[:es]
  end
end
