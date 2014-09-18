class BooksController < ApplicationController
  def show
    @slides = []
    page = 0
    letter = 0
    subletter = 0
    content = []
    File.open(URI.decode(params[:id])).each_line do |line|
      case
        when line =~ /^\s*$/
        when line =~ /^%author/
        when line =~ /^%book/
        when line =~ /^%page\s+(.+)\s*$/
          page = $1
        when line =~ /^%letter\s+(.+)\s*$/
          unless content.blank?
            subletter += 1
            @slides << add_content(page, letter, subletter, content)
            content = []
          end
          letter = $1
          subletter = 0
        when line =~ /^%break$/
          unless content.blank?
            subletter += 1
            @slides << add_content(page, letter, subletter, content)
            content = []
          end
        else
          content << line.chop.gsub(/'/, '&#39;')
      end
    end
    @slides << add_content(page, letter, subletter, content) unless content.blank?
  end

  private
  def add_content(page, letter, subletter, content)
    "<li class=\"draggable\" data-page=\"#{page}\" data-letter=\"#{letter}#{subletter == 1 ? '' : "-#{subletter}"}\"><div class=\"wrap\"><div class=\"backdrop\"><span class=\"handle glyphicon glyphicon-move\"></span>" + content.join('<br/>') + '</div></div></li>'
  end
end
