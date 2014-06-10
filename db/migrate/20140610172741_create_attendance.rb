class CreateAttendance < ActiveRecord::Migration
  def change
    create_table :attendances do |table|
      table.integer :user_id, null: false
      table.integer :meetup_id, null: false
      table.string :member_type, null:false

      table.timestamps
    end
  end
end
