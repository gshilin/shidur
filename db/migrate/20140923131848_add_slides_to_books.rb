class AddSlidesToBooks < ActiveRecord::Migration
  def change
    add_column :books, :slides, :text
  end
end
