class BooksController < ApplicationController
  def show
    @slides = Book.slides(params[:id])
  end
end
