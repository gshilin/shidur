# == Schema Information
#
# Table name: books
#
#  id         :integer          not null, primary key
#  author     :string(255)
#  title      :string(255)
#  content    :text
#  created_at :datetime
#  updated_at :datetime
#  slides     :text
#

class Book < ActiveRecord::Base
  def content=(data)
    slides = []
    page = 0
    letter = 0
    subletter = 0
    content = []
    data.split(/\n|\r\n/).each do |line|
      case
        when line =~ /^\s*$/
        when line =~ /^%author/
        when line =~ /^%book/
        when line =~ /^%page\s+(.+)\s*$/
          page = $1
        when line =~ /^%letter\s+(.+)\s*$/
          unless content.blank?
            subletter += 1
            slides << add_content(page, letter, subletter, content)
            content = []
          end
          letter = $1
          subletter = 0
        when line =~ /^%break$/
          unless content.blank?
            subletter += 1
            slides << add_content(page, letter, subletter, content)
            content = []
          end
        else
          content << line.chop.gsub(/'/, '&#39;')
      end
    end
    slides << add_content(page, letter, subletter, content) unless content.blank?
    self.slides = slides.join('')
  end

  def self.authors
    Book.order(:author).pluck(:author)
  end

  def self.titles(author_name)
    Book.where(author: author_name).order(:title).pluck(:id, :title)
  end

  def self.slides(book_id)
    Book.where(id: book_id).pluck(:slides).first
  end

  private
  def add_content(page, letter, subletter, content)
    "<li class=\"draggable\" data-page=\"#{page}\" data-letter=\"#{letter}#{subletter == 1 ? '' : "-#{subletter}"}\"><div class=\"wrap\"><div class=\"backdrop\"><span class=\"handle glyphicon glyphicon-move\"></span>" + content.join('<br/>') + '</div></div></li>'
  end

end
