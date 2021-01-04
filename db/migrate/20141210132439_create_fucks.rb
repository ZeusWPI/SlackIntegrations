class CreateFucks < ActiveRecord::Migration[4.2]
  def change
    create_table :fucks do |t|
      t.string :name
      t.integer :amount

      t.timestamps
    end
    add_index :fucks, :name
  end
end
