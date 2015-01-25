class BooksController < ApplicationController
  def index
    @books = Book.titles_per_author
  end

  def show
    @slides = Book.slides(params[:id])
  end
end
