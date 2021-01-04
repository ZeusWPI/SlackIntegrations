class CreateFuckers < ActiveRecord::Migration[4.2]
  def change
    create_table :fuckers do |t|
      t.references :fuck, null: false
      t.string :user_id

      t.timestamps
    end
  end
end
