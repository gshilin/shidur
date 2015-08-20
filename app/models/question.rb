# == Schema Information
#
# Table name: questions
#
#  id          :integer          not null, primary key
#  question    :string           default("")
#  user        :string
#  is_question :boolean          default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#

class Question < ActiveRecord::Base
end
