class AddBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.string :author
      t.string :book
      t.integer :page
      t.string :letter

      t.timestamps
    end
  end
end
