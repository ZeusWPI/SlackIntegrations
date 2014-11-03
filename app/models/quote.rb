class Quote < ActiveRecord::Base
  validates :text, presence: true
end
