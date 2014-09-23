class Admin::BooksController < ApplicationController
  def index
    @books = Book.order(:author)
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      redirect_to admin_books_url, notice: 'Successfully created book.'
    else
      render :action => 'new'
    end
  end

  def edit
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update_attributes(book_params)
      redirect_to admin_books_url, notice: 'Successfully updated book.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    book = Book.find(params[:id])
    render admin_books_url, alert: 'No such book' and return unless book
    book.destroy
    redirect_to admin_books_url, notice: 'Successfully destroyed book.'
  end

  private

  def book_params
    params.require(:book).permit(:author, :title, :content)
  end
end
