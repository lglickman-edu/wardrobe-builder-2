class AddCleanToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :clean, :boolean
  end
end
