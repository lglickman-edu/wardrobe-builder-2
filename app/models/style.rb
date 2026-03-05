# == Schema Information
#
# Table name: styles
#
#  id          :bigint           not null, primary key
#  archived_at :datetime
#  description :text
#  name        :string
#  rules_json  :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :integer
#
class Style < ApplicationRecord
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"
  has_many  :outfits, class_name: "Outfit", foreign_key: "style_id", dependent: :destroy
end
