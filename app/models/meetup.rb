class Meetup < ActiveRecord::Base
  has_many :users, through: :attendances
  has_many :attendances
  has_many :comments
  validates :name, presence: true
  validates :location, presence: true
  validates :description, presence: true
  validates :start_time, presence: true
end
