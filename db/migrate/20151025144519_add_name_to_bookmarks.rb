class AddNameToBookmarks < ActiveRecord::Migration
  def change
    add_column :bookmarks, :book_name, :string
  end
end
