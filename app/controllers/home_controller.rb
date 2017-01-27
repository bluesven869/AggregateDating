class HomeController < ApplicationController
	require 'httparty'

	base_uri = 'https://api.coffeemeetsbagel.com/login'
	options = {
		body: {
	    	'permissions': ["user_friends","contact_email","email","user_photos","public_profile","user_birthday","user_education_history"],
	    	'app_version': '779',
	    	'access_token': 'EAAE998BGKHABADnrlCZCYU3puhrfvc34vY2bvXFt88w9BOJataaZAYPB9CLjM4vZBkbW4pcRo3i7kAhLnyOi1rC6vMZBvHEFyhy5ui8MtLDfjv7hRBdr7ijA7EKvEynMM8qW00qCk53d5yf00ef4FCZBBuQK88EYFmglqpSoZAe6dFjsC4SU7j'
	  	}
	}
	headers = {
		'AppStore-Version' => '3.4.1.779',
		'App-Version' => '779',
		'Client' => 'Android'
	}

	def index
		# response = HTTParty.post(base_uri, headers: headers)
	end
	
end