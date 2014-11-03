class ChangeQuoteToText < ActiveRecord::Migration
  def up
    change_column :quotes, :text, :text
  end
  def down
    change_column :quotes, :text, :string
  end
end
