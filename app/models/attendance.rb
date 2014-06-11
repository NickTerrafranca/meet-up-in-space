class Attendance < ActiveRecord::Base
  belongs_to :meetup
  belongs_to :user
end
