class AddTableForQuestion < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :question, default: ''
    end
  end
end
