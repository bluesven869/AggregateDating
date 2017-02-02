class HomeController < ApplicationController
	require 'httparty'
	def index
		# response = HTTParty.post(base_uri, headers: headers)
		@title = url_for(:only_path => false)
	  	@description = "This is an example description"
	end
	
end