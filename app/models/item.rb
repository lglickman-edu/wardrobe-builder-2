# == Schema Information
#
# Table name: items
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  category    :string
#  color       :string
#  image_url   :string
#  name        :string
#  notes       :text
#  season      :string
#  tags_json   :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#
class Item < ApplicationRecord
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"
  has_many  :outfit_items, class_name: "OutfitItem", foreign_key: "item_id", dependent: :destroy
  has_many :outfits, through: :outfit_items, source: :outfit

  mount_uploader :image_url, ImageUploader

end
