class AuthorsController < ApplicationController
  def index
    @authors = Dir.entries('books').reject { |d| d=~ /^\.|\.\.$/ }.sort
  end

  def show
    author = params[:id]
    @books = Dir.entries("books/#{author}").reject { |d| d=~ /^\.|\.\.$/ }.map do |book|
      path = "books/#{author}/#{book}"
      (File.foreach(path).grep(/^%book/)).map { |b| b =~ /\s(.+)$/; [path, $1] }.first
    end.sort
  end
end
