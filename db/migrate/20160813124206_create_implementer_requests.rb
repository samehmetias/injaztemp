class CreateImplementerRequests < ActiveRecord::Migration
  def change
    create_table :implementer_requests do |t|
      t.string :classroom,        default: ""
      t.date :start_date
      t.integer :duration,        default: 0
      t.integer :school_id,       null: false, default: 0
      t.integer :user_id,         null: false, default: 0
      t.integer :program_id,      null: false, default: 0
      t.string :status,           default: 'pending'

      t.timestamps null: false
    end
  end
end
