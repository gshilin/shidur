class AddApprovedToQuestions < ActiveRecord::Migration
  def change
    add_column :messages, :approved, :boolean, default: false
  end
end
