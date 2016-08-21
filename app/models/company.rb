class Company < ActiveRecord::Base

	has_many :Users, dependent: :destroy

end
