class CreatePhones < ActiveRecord::Migration
  def change
    create_table :phones do |t|

    	t.integer :user_id, null: false, default:0
    	t.string :token, null: false, default:""
    	t.string :uuid, null: false, default:""
    	t.boolean :is_android, null: false, default:false
      t.timestamps
    end
  end
end
