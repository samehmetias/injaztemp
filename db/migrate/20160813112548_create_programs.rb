class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.string :name,		null: false, default: ""
      t.integer :duration,		null: false, default: 0
      t.string :participants,		null: false, default: ""
      t.string :overview,		null: false, default: ""

      t.timestamps null: false
    end
  end
end
