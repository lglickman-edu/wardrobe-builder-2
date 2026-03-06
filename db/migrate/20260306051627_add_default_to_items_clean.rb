class AddDefaultToItemsClean < ActiveRecord::Migration[8.0]
  def change
    change_column_default :items, :clean, true
  end
end
