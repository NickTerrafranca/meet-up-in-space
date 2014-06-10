class Attendance < ActiveRecord::Base
  belongs_to :meetups
  belongs_to :users
end
