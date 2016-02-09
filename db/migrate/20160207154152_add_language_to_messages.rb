class AddLanguageToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :language, :string, default: 'he'
  end
end
