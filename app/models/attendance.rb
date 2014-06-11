class Attendance < ActiveRecord::Base
  belongs_to :meetup
  belongs_to :user
  validate :user_id, presence: true
  validate :meetup_id, presence: true
  validate :member_type, presence: true
end
