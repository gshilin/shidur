class AuthorsController < ApplicationController
  def index
    @authors = Book.authors
  end

  def show
    @titles = Book.titles(params[:id])
  end
end
