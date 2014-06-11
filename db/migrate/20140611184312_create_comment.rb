class CreateComment < ActiveRecord::Migration
  def change
    create_table :comments do |table|
      table.integer :user_id, null: false
      table.integer :meetup_id, null: false
      table.text :content, null: false

      table.timestamp
    end
  end
end
