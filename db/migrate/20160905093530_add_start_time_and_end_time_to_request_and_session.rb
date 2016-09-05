class AddStartTimeAndEndTimeToRequestAndSession < ActiveRecord::Migration
  def change
  	add_column :implementer_requests, :start_time, :time
  	add_column :implementer_requests, :end_time, :time
    
    add_column :lessons, :start_time, :time
    add_column :lessons, :end_time, :time
  end
end
