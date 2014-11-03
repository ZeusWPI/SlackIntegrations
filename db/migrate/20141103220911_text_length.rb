class TextLength < ActiveRecord::Migration
  def change
    change_column :quotes, :text, :text, :limit => 1000
  end
end
