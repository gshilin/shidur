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
    super

    slides        = []
    page          = 0
    letter        = 0
    subletter     = 0
    slide_content = []
    data.split(/\n|\r\n/).each do |line|
      case
        when line =~ /^\s*$/
        when line =~ /^%author/
        when line =~ /^%book/
        when line =~ /^%page\s+(.+)\s*$/
          page = $1
        when line =~ /^%letter\s+(.+)\s*$/
          unless slide_content.blank?
            subletter += 1
            slides << add_content(page, letter, subletter, slide_content)
            slide_content = []
          end
          letter    = $1
          subletter = 0
        when line =~ /^%break$/
          unless slide_content.blank?
            subletter += 1
            slides << add_content(page, letter, subletter, slide_content)
            slide_content = []
          end
        else
          slide_content << line.gsub(/'/, '&#39;').gsub(/^(\.\d+(\/\d+)*)\s/, "<bdi dir=\"ltr\">\\1</bdi>&nbsp;")
      end
    end
    slides << add_content(page, letter, subletter, slide_content) unless slide_content.blank?
    self.slides = slides.join('')
  end

  def self.authors
    Book.distinct.order(:author).pluck(:author)
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
