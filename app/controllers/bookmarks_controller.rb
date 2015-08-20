class BookmarksController < ApplicationController

  def create
    if Bookmark.new(bookmark_parameters).save
      render json: {message: 'Created'}, status: 200
    else
      render json: {message: 'Unable to save'}, status: 422
    end
  end

  def destroy
    if Bookmark.where(id: params[:id]).first.try(:delete)
      render json: {message: 'Deleted'}, status: 200
    else
      render json: {message: 'Unable to delete'}, status: 422
    end
  end

  private

  def bookmark_parameters
    params.permit(:author, :book, :page, :letter)
  end
end
