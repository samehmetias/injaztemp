class HomeController < ApplicationController
	before_filter :authenticate_user!
	def index
  		@list = "home"
  	end

end
