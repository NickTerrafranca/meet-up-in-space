class CreateMeetup < ActiveRecord::Migration
  def change
    create_table :meetups do |table|
      table.string :name, null: false
      table.string :location, null: false
      table.string :description, null: false, limit: 2000
      table.string :start_time, null: false
      table.string :end_time, null: true

      table.timestamps
    end
  end
end
