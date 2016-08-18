class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
    	t.string :key
    	t.integer :user_id
    	t.timestamps
    end
    add_index :api_keys, :key
  end
end
