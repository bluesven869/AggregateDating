require 'httparty'
require 'json'
class BumbleController < ApplicationController
	include HTTParty
	debug_output $stdout
	

	def index
		# Login to CoffeeMeetBagel		
		# IN    fbToken : FaceBook Token
		# Return sessionid
		
		if (not params.has_key?(:fbToken))
			@bumbleInfo = [{"Result": "Error","jsonObj": "Token"}]
		else
			#base_uri = 'https://api.gotinder.com/auth'			
			#fbToken = params[:fbToken].to_str
			#fbUserID = params[:fbUserID].to_str
			#uuid = SecureRandom.uuid
			#options = {
		    #	'facebook_token': fbToken,
		    #	'facebook_id': fbUserID
			#}
			
			#headers = { 
			#	'X-Auth-Token': uuid,
			#	'User-agent': 'User-Agent: Tinder/3.0.4 (iPhone; iOS 7.1; Scale/2.00)',
			#	'Content-Type': 'application/json'
		    #}
			#response = self.class.post(base_uri.to_str, 
			#	:body=> options.to_json,
			#	:headers => headers
			#)
		    #if response.success?
		    #  @tinderInfo = [{"Result": "success","jsonObj": response}]
		    #else
		    #  @tinderInfo = [{"Result": "failed", "jsonObj":response}]
		    #end
		    @bumbleInfo = [{"Result": "failed","jsonObj": "API has not completed yet"}]
		end
	end
end
