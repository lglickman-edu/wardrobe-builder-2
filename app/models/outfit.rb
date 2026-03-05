# == Schema Information
#
# Table name: outfits
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  name        :string
#  notes       :text
#  occasion    :string
#  season      :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  style_id    :integer
#  user_id     :integer
#
class Outfit < ApplicationRecord
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"
  has_many  :outfit_items, class_name: "OutfitItem", foreign_key: "outfit_id", dependent: :destroy
  belongs_to :style, required: true, class_name: "Style", foreign_key: "style_id"
  has_many :items, through: :outfit_items, source: :item
end
