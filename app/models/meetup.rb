class Meetup < ActiveRecord::Base
  has_many :attendances
  has_many :users, through: :attendances
  validate :name, presence: true
  validate :location, presence: true
  validate :description, presence: true
  validate :start_time, presence: true
  validate :end_time, presence: true
end
