class AddLatitudeAndLongitudeToSchool < ActiveRecord::Migration
  def change
    add_column :schools, :latitude, :float
    add_column :schools, :longitude, :float
    add_column :schools, :address, :text
  end
end
