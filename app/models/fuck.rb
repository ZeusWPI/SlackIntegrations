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

class Fuck < ActiveRecord::Base
  has_many :fuckers

  validates :name, presence: true

  def self.format(name)
    return "no fuck given" unless name
    name.squish.split(' ', 2)[1]
  end
end
