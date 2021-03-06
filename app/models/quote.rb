# == Schema Information
#
# Table name: quotes
#
#  id           :integer          not null, primary key
#  token        :string(255)
#  team_id      :string(255)
#  channel_id   :string(255)
#  channel_name :string(255)
#  user_id      :string(255)
#  user_name    :string(255)
#  command      :string(255)
#  text         :text(1000)
#  created_at   :datetime
#  updated_at   :datetime
#

class Quote < ApplicationRecord
  validates :text, presence: true
end
