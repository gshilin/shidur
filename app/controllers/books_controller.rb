class BooksController < ApplicationController
  def index
    @books = Book.titles_per_author
    @question = Question.first.try(:question)
    respond_to do |format|
      format.html
      format.json {
        render json: @books
      }
    end
  end

  def show
    render json: Book.slides(params[:id])
  end
end
