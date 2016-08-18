class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name,   null: false, default: ""
      t.string :district,   null: false, default: ""
      t.integer :prep_classes,    null: false, default: 0
      t.integer :sec_classes,   null: false, default: 0
      t.integer :uni_classes,   null: false, default: 0

      t.timestamps null: false
    end
  end
end
