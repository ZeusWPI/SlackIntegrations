# == Schema Information
#
# Table name: fuckers
#
#  id         :integer          not null, primary key
#  fuck_id    :integer          not null
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Fucker < ApplicationRecord
  belongs_to :fuck, counter_cache: :amount

  validates :user_id, presence: true
end
