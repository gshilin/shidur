# == Schema Information
#
# Table name: bookmarks
#
#  id         :integer          not null, primary key
#  author     :string
#  book       :string
#  page       :integer
#  letter     :string
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#  book_name  :string
#

class Bookmark < ActiveRecord::Base
end
