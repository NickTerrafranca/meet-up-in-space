class Meetup < ActiveRecord::Base
  has_many :users, through: :attendances
end
