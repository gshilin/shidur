class CreateBooksTable < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :author
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
