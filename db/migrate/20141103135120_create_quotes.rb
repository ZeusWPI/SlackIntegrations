class CreateQuotes < ActiveRecord::Migration[4.2]
  def change
    create_table :quotes do |t|
      t.string :token
      t.string :team_id
      t.string :channel_id
      t.string :channel_name
      t.string :user_id
      t.string :user_name
      t.string :command
      t.string :text

      t.timestamps
    end
  end
end
