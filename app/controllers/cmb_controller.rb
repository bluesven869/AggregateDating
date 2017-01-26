require 'httparty'
require 'json'
class CmbController < ApplicationController
	include HTTParty
	debug_output $stdout
	

	def index
		# Login to CoffeeMeetBagel		
		# IN    fbToken : FaceBook Token
		# Return sessionid
		
		if (not params.has_key?(:fbToken))
			@cmbInfo = [{"loginResult": "Token Error", "sessionid":"NoSession","jsonObj": "Token"}]
		else
			base_uri = 'https://api.coffeemeetsbagel.com/login'			
			fbToken = params[:fbToken].to_str
			options = {
		    	'permissions': ['user_friends','contact_email','email','user_photos','public_profile','user_birthday','user_education_history'],
		    	'app_version': '779',
		    	'access_token': fbToken
			}
			
			headers = { 
		        'AppStore-Version': '3.4.1.779',
				'App-Version': '779',
				'Client': 'Android',
				'Content-Type': 'application/json'
		    }
			response = self.class.post(base_uri.to_str, 
				:body=> options.to_json,
				:headers => headers
			)
		    if response.success?
		      resHeader = response.headers['set-cookie']
		      splittedStr = resHeader.split(/[;]/)
		      splittedStr = splittedStr[3].split(/[=]/)
		      sessionid = splittedStr[2]		      
		      @cmbInfo = [{"loginResult": "success", "sessionid":sessionid,"jsonObj": response}]
		    else
		      @cmbInfo = [{"loginResult": "failed", "sessionid": "NONE", "jsonObj":response}]
		    end
		end
	end

	def get_profile
		#Get Profile
		#  IN     fbToken  : FaceBook Token
		#         sessionid: CMB session id
		#  Return
		#         jsonObj  : User Profile Info
		if (not params.has_key?(:fbToken)) || (not params.has_key?(:sessionid))
			@profileInfo = [{"loginResult": "Token Error", "sessionid":"NoSession","jsonObj": "Token"}]
		else
			fbToken = params[:fbToken].to_str
			sessionid = params[:sessionid].to_str
			base_uri = "https://api.coffeemeetsbagel.com/profile/me"
          	my_cookie = "sessionid="+sessionid
          	options = {

          	}
	      	headers = {
	    	  'AppStore-Version': '3.4.1.779',
			  'App-Version': '779',
			  'Client': 'Android',
			  'Device-Name': 'Genymotion Samsung Galaxy S4 - 4.4.4 - API 19 - 1080x1920',
			  'Content-Type': 'application/json',
			  'Facebook-Auth-Token': fbToken,
			  'Cookie': my_cookie	
	      	}
	      	response = self.class.get(base_uri.to_str,
	      	  :body=> options.to_json,
	      	  :headers => headers)
		  	if response.success?
		  	  @profileInfo = [{"loginResult": "success", "sessionid":sessionid,"jsonObj": response}]
		  	else
			  @profileInfo = [{"loginResult": "failed", "sessionid": sessionid, "jsonObj": response}]
			end	 
		end
	end 

	def set_profile
		#Set Profile
		#  IN     fbToken  : FaceBook Token
		#         sessionid: CMB session id
		#         user     : User Profile Info
		#  Return
		#         jsonObj  : User Profile Info (changed)

		if (not params.has_key?(:fbToken)) || (not params.has_key?(:sessionid))
			@cmbInfo = [{"loginResult": "Token Error", "sessionid":"NoSession","jsonObj": "Token"}]
		else
			fbToken = params[:fbToken].to_str
			sessionid = params[:sessionid].to_str
			@user 	= JSON.parse params[:user];
			base_uri = 'https://api.coffeemeetsbagel.com/profile/me'		
			my_cookie = "sessionid="+sessionid
	      	headers = {
		    	'AppStore-Version': '3.4.1.779',
				'App-Version': '779',
				'Client': 'Android',
				'Content-Type': 'application/json',
				'Facebook-Auth-Token': fbToken,
				'Cookie': my_cookie	
	      	}
	      	options = {	    	
		    	'id': @user["id"],
		    	'name': @user["name"],
		    	'gender': @user["gender"],
		    	'birthday': @user["birthday"],
		    	'user__email': @user["email"],
		    	'criteria__gender': @user["criteria_gender"],
			}	
		    response = self.class.put(base_uri.to_str,
		    	:body=> options.to_json,
		      	:headers => headers)
		    if response.success?
		      	@profileInfo = [{"loginResult": "Set Profile Success", "sessionid":sessionid,"jsonObj": response}]			  	
			else
			  	@profileInfo = [{"loginResult": "Set Profile Failed", "sessionid": sessionid, "jsonObj": response}]
			end	  
		end
	end

	def get_bagels
		# Get Bagels
		#    IN      fbToken : FaceBook Token
		#            sessionid: CMB Session ID
		#    OUT     
		#	         jsonObj : Today's Bagel Info 

		if (not params.has_key?(:fbToken)) || (not params.has_key?(:sessionid))
			@BaglesInfo = [{"success": false, "jsonObj": "No Authenticated"}]
		else
			fbToken = params[:fbToken].to_str
			sessionid = params[:sessionid].to_str
			base_uri = 'https://api.coffeemeetsbagel.com/bagels?embed=profile&prefetch=true'		
			my_cookie = "sessionid="+sessionid
	      	headers = {
		    	'AppStore-Version': '3.4.1.779',
				'App-Version': '779',
				'Client': 'Android',
				'Content-Type': 'application/json',
				'Facebook-Auth-Token': fbToken,
				'Cookie': my_cookie	
	      	}
		    response = self.class.get(base_uri.to_str,
		    	# :body=> options.to_json,
		      	:headers => headers)

		    if response.success?
		      	@BaglesInfo = [{"success": true, "jsonObj": response}]
		    else
			  	loginResult = "fail get bagels"
			  	@BaglesInfo = [{"success": false, "jsonObj": response}]
			end
		end
	end
	
	def get_bagels_history
		# Get Bagels History
		#    IN      fbToken : FaceBook Token
		#            sessionid: CMB Session ID
		#            @bagel : BagelObject(hex_id, cursor_after)
		#    OUT     
		#	         jsonObj : Bagels History before cursor_after 

		if (not params.has_key?(:fbToken)) || (not params.has_key?(:sessionid)) || (not params.has_key?(:bagel))
			@BaglesInfo = [{"success": false, "jsonObj": "Params Error"}]
		else
			fbToken = params[:fbToken].to_str
			sessionid = params[:sessionid].to_str		
			@bagel 	= JSON.parse params[:bagel];
			base_uri = 'https://api.coffeemeetsbagel.com/bagels'		
			my_cookie = "sessionid="+sessionid
	      	headers = {
		    	'AppStore-Version': '3.4.1.779',
				'App-Version': '779',
				'Client': 'Android',
				'Content-Type': 'application/json',
				'Facebook-Auth-Token': fbToken,
				'Cookie': my_cookie	
	      	}
	      	options = {	    	
		    	'embed': 'profile',
		    	'prefetch': true,
		    	'cursor_after': @bagel["cursor_after"],
		    	'updated_after': @bagel["hex_id"],
			}	
		    response = self.class.get(base_uri.to_str,
		    	:body=> options.to_json,
		      	:headers => headers)
		    if response.success?
		      	@BaglesList = [{"success": true, "jsonObj": response}]
		    else		  	
			  	@BaglesList = [{"success": false, "jsonObj": response}]
			end	  
		end
	end
	def send_batch
		# Batch Command
		if (not params.has_key?(:fbToken)) || (not params.has_key?(:sessionid)) || (not params.has_key?(:hex_id))
			@BaglesInfo = [{"success": false, "jsonObj": "Params Error"}]
		else
			fbToken = params[:fbToken].to_str
			sessionid = params[:sessionid].to_str
			hex_id = params[:hex_id].to_str
			base_uri = 'https://api.coffeemeetsbagel.com/batch'		
			my_cookie = "sessionid="+sessionid
	      	headers = {
		    	'AppStore-Version': '3.4.1.779',
				'App-Version': '779',
				'Client': 'Android',
				'Content-Type': 'application/json',
				'Facebook-Auth-Token': fbToken,
				'Cookie': my_cookie	
	      	}
	    
	      	options = [	    	
		    	{
		    		'relative_url': 'givetakes?embed=profile&updated_after='+hex_id,
		    		'method': 'GET'
		    	},
		    	{
		    		'relative_url': 'price',
		    		'method': 'GET'
		    	},
		    	{
		    		'relative_url': 'reportmeta?embed=profile&updated_after='+hex_id,
		    		'method': 'GET'
		    	},
		    	{
		    		'relative_url': 'risinggivetakes?embed=profile&updated_after='+hex_id,
		    		'method': 'GET'
		    	},
		    	{
		    		'relative_url': 'feature',
		    		'method': 'GET'
		    	},
		    	{
		    		'relative_url': 'reward',
		    		'method': 'GET'
		    	},
		    	{
		    		'relative_url': 'profile\/me',
		    		'method': 'GET'
		    	}
			]	
			
		    response = self.class.post(base_uri.to_str,
		    	:body=> options.to_json,
		      	:headers => headers)
		    if response.success?
		      	@BaglesInfo = [{"success": true, "jsonObj": response}]
		    else		  	
			  	@BaglesInfo = [{"success": false, "jsonObj": response}]
			end	  
		end
	end
	def get_resources
		# Get Resource
		#    IN      fbToken : FaceBook Token
		#            sessionid: CMB Session ID
		#    OUT     
		#	         jsonObj : Resource of App.
		if (not params.has_key?(:fbToken)) || (not params.has_key?(:sessionid))
			@ResourceInfo = [{"success": false, "jsonObj": "No Authenticated"}]
		else
			fbToken = params[:fbToken].to_str
			sessionid = params[:sessionid].to_str
			base_uri = 'https://api.coffeemeetsbagel.com/resource/locale/en_us.json'		
			my_cookie = "sessionid="+sessionid
	      	headers = {
		    	'AppStore-Version': '3.4.1.779',
				'App-Version': '779',
				'Client': 'Android',
				'Content-Type': 'application/json',
				'Facebook-Auth-Token': fbToken,
				'Cookie': my_cookie	
	      	}
	      	options = {	    	
		    	
			}	
		    response = self.class.get(base_uri.to_str,
		    	:body=> options.to_json,
		      	:headers => headers)
		    if response.success?
		      	@ResourceInfo = [{"success": true, "jsonObj": response}]
		    else
			  	@ResourceInfo = [{"success": false, "jsonObj": response}]
			end	  
		end
	end
	def get_photolabs
		#Get Bagels
		#    IN      fbToken : FaceBook Token
		#            sessionid: CMB Session ID
		#    OUT     
		#	         jsonObj : Photo Labs

		if (not params.has_key?(:fbToken)) || (not params.has_key?(:sessionid))
			@PhotoLabs = [{"success": false, "jsonObj": "No Authenticated"}]
		else
			fbToken = params[:fbToken].to_str
			sessionid = params[:sessionid].to_str
			base_uri = 'https://api.coffeemeetsbagel.com/photolabs'		
			my_cookie = "sessionid="+sessionid
	      	headers = {
		    	'AppStore-Version': '3.4.1.779',
				'App-Version': '779',
				'Client': 'Android',
				'Content-Type': 'application/json',
				'Facebook-Auth-Token': fbToken,
				'Cookie': my_cookie	
	      	}
	      	options = {	    	
		    	
			}	
		    response = self.class.get(base_uri.to_str,
		    	:body=> options.to_json,
		      	:headers => headers)
		    if response.success?
		      	@PhotoLabs = [{"success": true, "jsonObj": response}]
		    else
			  	@PhotoLabs = [{"success": false, "jsonObj": response}]
			end
		end
	end

	def give_take
		# Give Take
		#    IN      fbToken : FaceBook Token
		#            sessionid: CMB Session ID
		#  			 customer_id : Bagel_id
		#    OUT     
		#	         success : take result

		if (not params.has_key?(:fbToken)) || (not params.has_key?(:sessionid)) || (not params.has_key?(:customer_id) )
			@GiveTakeResult = [{"success": false, "jsonObj": "Params Error"}]
		else
			fbToken 		= params[:fbToken].to_str
			sessionid 		= params[:sessionid].to_str
			customer_id 	= params[:customer_id].to_str
			base_uri 		= 'https://api.coffeemeetsbagel.com/givetake'		
			my_cookie = "sessionid="+sessionid
	      	headers = {
		    	'AppStore-Version': '3.4.1.779',
				'App-Version': '779',
				'Client': 'Android',
				'Content-Type': 'application/json',
				'Facebook-Auth-Token': fbToken,
				'Cookie': my_cookie	
	      	}
	      	options = {	    	
		    	"id":customer_id,
		    	"shown":true
			}	
		    response = self.class.put(base_uri.to_str,
		    	:body=> options.to_json,
		      	:headers => headers)	    
		    if response.success?
		      	@GiveTakeResult = [{"success": true}]
		    else
			  	@GiveTakeResult = [{"success": false}]
			end	     
		end 
	end

	def purchase
		# Purchase
		#    IN      fbToken : FaceBook Token
		#            sessionid: CMB Session ID
		#  			 @purchase : Purchase Info(item_count, item_name, expected_price, give_ten_id)
		#    OUT     
		#	         success : take result

		if (not params.has_key?(:fbToken)) || (not params.has_key?(:sessionid)) || (not params.has_key?(:purchase))
			@PurchaseResult = [{"success": false, "jsonObj": "Params Error"}]
		else
			fbToken 		= params[:fbToken].to_str
			sessionid 		= params[:sessionid].to_str
			@purchase 	= JSON.parse params[:purchase];
			base_uri 		= 'https://api.coffeemeetsbagel.com/purchase'		
			my_cookie = "sessionid="+sessionid
	      	headers = {
		    	'AppStore-Version': '3.4.1.779',
				'App-Version': '779',
				'Client': 'Android',
				'Content-Type': 'application/json',
				'Facebook-Auth-Token': fbToken,
				'Cookie': my_cookie	
	      	}
	      	options = {	    	
		    	"item_count":@purchase["item_count"],
		    	"item_name":@purchase["item_name"],
		    	"expected_price":@purchase["expected_price"],
		    	"give_ten_id":@purchase["give_ten_id"]
			}	
		    response = self.class.post(base_uri.to_str,
		    	:body=> options.to_json,
		      	:headers => headers)	    
		    if response.success?
		      	@PurchaseResult = [{"success": true}]
		    else
			  	@PurchaseResult = [{"success": false}]
			end
		end    
	end

	def report
		#Report
		#    IN      fbToken : FaceBook Token
		#            sessionid: CMB Session ID
		#    OUT     
		#	         jsonObj : Report Result
		if (not params.has_key?(:fbToken)) || (not params.has_key?(:sessionid))
			@ReportResult = [{"success": false, "jsonObj": "No Authenticated"}]
		else
			fbToken 		= params[:fbToken].to_str
			sessionid 		= params[:sessionid].to_str
			base_uri 		= 'https://api.coffeemeetsbagel.com/report/4'		
			my_cookie = "sessionid="+sessionid
	      	headers = {
		    	'AppStore-Version': '3.4.1.779',
				'App-Version': '779',
				'Client': 'Android',
				'Content-Type': 'application/json',
				'Facebook-Auth-Token': fbToken,
				'Cookie': my_cookie	
	      	}
	      	options = {}	
		    response = self.class.get(base_uri.to_str,
		    	:body=> options.to_json,
		      	:headers => headers)	    
		    if response.success?
		      	@ReportResult = [{"success": true, jsonObj:response}]
		    else
			  	@ReportResult = [{"success": false, jsonObj:response}]
			end	   
		end   
	end
end
