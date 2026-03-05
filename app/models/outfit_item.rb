# == Schema Information
#
# Table name: outfit_items
#
#  id         :bigint           not null, primary key
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  item_id    :integer
#  outfit_id  :integer
#
class OutfitItem < ApplicationRecord
  belongs_to :item, required: true, class_name: "Item", foreign_key: "item_id"
  belongs_to :outfit, required: true, class_name: "Outfit", foreign_key: "outfit_id"
end
