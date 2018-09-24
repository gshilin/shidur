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

class ContentValidator < ActiveModel::Validator
  def validate(record)
    success, errors = Book.parse_data_for_slides(record.content)
    errors.each do |page, letter, subletter|
      record.errors[:base] << "Too many lines on page #{page} letter #{letter}-#{subletter}"
    end unless success
  end
end

class Book < ActiveRecord::Base

  validates_presence_of :author, message: 'שם מחבר לא יכול להיות ריק'
  validates_presence_of :title, message: 'כותרת לא יכולה להיות ריקה'

  validates_with ContentValidator

  def content=(data)
    super

    result, slides = Book.parse_data_for_slides(data)
    write_attribute :slides, slides.to_json if result
  end

  def test_data_for_slides
    page      = 0
    letter    = 0
    subletter = 0

    slide_content = []
    slide_lines   = 0

    has_author   = false
    has_title    = false
    chech_lineno = false

    self.content.split(/\n|\r\n/).each do |line|
      case
      when line =~ /^\s*$/
      when line =~ /^%author/
        has_author = true
      when line =~ /^%book/
        has_title = true
      when line =~ /^%page\s+(.+)\s*$/
        if $1.blank?
          self.errors[:base] << "אין מספר דף  באיזור דף  #{page} אות #{letter}-#{subletter}"
        end
        page = $1
        unless slide_content.blank?
          slide_content = []
          slide_lines   = 0
        end
      when line =~ /^%letter\s+(.+)\s*$/
        if $1.blank?
          self.errors[:base] << "אין מספר אות בדף #{page} אחרי אות #{letter}-#{subletter}"
        end
        if slide_content.blank?
          subletter     += 1
          slide_content = []
          slide_lines   = 0
        end
        letter       = $1
        subletter    = 0
        chech_lineno = true
      when line =~ /^%break$/
        unless slide_content.blank?
          subletter     += 1
          slide_content = []
          slide_lines   = 0
        else
          self.errors[:base] << "אין תוכן בדף #{page} אות #{letter}-#{subletter}"
        end
      else
        if chech_lineno
          unless line =~ /^#{letter}/
            self.errors[:base] << "מספר שורה אינו תואם בדף #{page} אות #{letter}-#{subletter}"
          end
          chech_lineno = false
        end
        slide_content << line.gsub(/'/, '&#39;').gsub(/^(\.\d+(\/\d+)*)\s/, "<bdi dir=\"ltr\">\\1</bdi>&nbsp;")
        slide_lines += 1
        self.errors[:base] << "יותר מדי שורות  #{page} אות #{letter}-#{subletter}" if slide_lines > 4
      end
    end
    self.errors[:base] << 'שם מחבר לא יכול להיות ריק' unless has_author
    self.errors[:base] << 'כותרת לא יכולה להיות ריקה' unless has_title
  end

  private

  def self.add_content(page, letter, subletter, content, revert)
    # "<li class=\"draggable\" data-page=\"#{page}\" data-letter=\"#{letter}#{subletter == 1 ? '' : "-#{subletter}"}\"><div class=\"wrap\"><div class=\"backdrop\"><span class=\"handle glyphicon glyphicon-move\"></span>" + content.join('<br/>') + '</div></div></li>'
    { page: page, letter: letter, subletter: subletter, revert: revert, content: content.join('<br/>') }
  end

  def self.parse_data_for_slides(data)
    result        = []
    slides        = []
    page          = 0
    letter        = 0
    revert        = 0
    subletter     = 0
    slide_content = []
    slide_lines   = 0
    data.split(/\n|\r\n/).each do |line|
      case
      when line =~ /^\s*$/
      when line =~ /^%author/
      when line =~ /^%book/
      when line =~ /^%revert/
        revert = 1
      when line =~ /^%page\s+(.+)\s*$/
        unless slide_content.blank?
          subletter += 1
          slides << add_content(page, letter, subletter, slide_content, revert)
          slide_content = []
          slide_lines   = 0
        end
        page = $1
      when line =~ /^%letter\s+(.+)\s*$/
        unless slide_content.blank?
          subletter += 1
          slides << add_content(page, letter, subletter, slide_content, revert)
          slide_content = []
          slide_lines   = 0
        end
        letter    = $1
        subletter = 0
      when line =~ /^%break$/
        unless slide_content.blank?
          subletter += 1
          slides << add_content(page, letter, subletter, slide_content, revert)
          slide_content = []
          slide_lines   = 0
        end
      else
        line = line.gsub(/'/, '&#39;').gsub(/^(\.\d+(\/\d+)*)\s/, "<bdi dir=\"ltr\">\\1</bdi>&nbsp;")
        line = "<h3>#{$1}</h3>" if line =~ /^%H\s+(.+)\s*$/
        line = "<h3>#{$1}</h3>" if line =~ /^%H3\s+(.+)\s*$/
        line = "<h4>#{$1}</h4>" if line =~ /^%H4\s+(.+)\s*$/
        line = "<h5>#{$1}</h5>" if line =~ /^%H5\s+(.+)\s*$/
        line = "<h6>#{$1}</h6>" if line =~ /^%H6\s+(.+)\s*$/
        line = "<div class='source'>#{$1}</div>" if line =~ /^%S\s+(.+)\s*$/
        slide_content << line
        slide_lines += 1
        result << [page, letter, subletter] if slide_lines > 4
      end
    end
    slides << add_content(page, letter, subletter, slide_content, revert) unless slide_content.blank?

    result.blank? ? [true, slides] : [false, result]
  end
end
