class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|

    	t.string :name,		null: false, default: ""
      t.timestamps
    end
  end
end
