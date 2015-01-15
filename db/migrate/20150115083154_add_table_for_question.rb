class AddTableForQuestion < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :questions, default: ''
    end
  end
end
