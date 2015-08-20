# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  message    :string           default("")
#  user_name  :string           default("")
#  type       :string           default("")
#  created_at :datetime
#  updated_at :datetime
#

class Message < ActiveRecord::Base
  Message.inheritance_column = nil
end
