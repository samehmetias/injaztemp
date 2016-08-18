class CreateLessons < ActiveRecord::Migration
  def change
    create_table :lessons do |t|
      t.string :name,						null: false, default: ""
      t.datetime :date
      t.integer :implementer_request_id, 	null: false, default: 0
      t.string :status, 					null: false, default: "pending"

      t.timestamps null: false
    end
  end
end
