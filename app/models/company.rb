class Company < ActiveRecord::Base

	has_many :Users, dependent: :destroy
	has_many :implementer_requests, through: :Users

end
