class ApiKey < ActiveRecord::Base
	attr_accessor :user_id
	belongs_to :user
	before_create :generate_token

	private
	
	def generate_token
		begin
	  		self.key = SecureRandom.hex.to_s
		end while self.class.exists?(key: key)
	end
end
