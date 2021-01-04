class TextLength < ActiveRecord::Migration[4.2]
  def change
    change_column :quotes, :text, :text, :limit => 1000
  end
end
