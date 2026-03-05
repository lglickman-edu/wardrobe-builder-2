class CreateStyles < ActiveRecord::Migration[8.0]
  def change
    create_table :styles do |t|
      t.integer :user_id
      t.string :name
      t.text :description
      t.text :rules_json
      t.datetime :archived_at

      t.timestamps
    end
  end
end
