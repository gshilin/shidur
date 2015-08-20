class Messages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :message, default: ''
      t.string :user_name, default: ''
      t.string :type, default: ''

      t.timestamps
    end
  end
end
