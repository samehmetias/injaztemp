class ChangeOverviewType < ActiveRecord::Migration
  def up
    change_column :program, :overview, :text
end
def down
    # This might cause trouble if you have strings longer
    # than 255 characters.
    change_column :program, :overview, :string
end
end
