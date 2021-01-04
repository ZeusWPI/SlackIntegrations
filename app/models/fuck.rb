# == Schema Information
#
# Table name: fucks
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  amount     :integer
#  created_at :datetime
#  updated_at :datetime
#

class Fuck < ApplicationRecord
  has_many :fuckers

  validates :name, presence: true

  def self.format(name)
    return nil unless name || name.empty?

    name.squish.split(' ', 2)[1]
  end
end
