class MailchimpController < ApplicationController
	require 'httparty'
	
	def index
		# response = HTTParty.post(base_uri, headers: headers)
	end

	def email_subscriber
		email = params[:email].to_str	
		
		emails = EmailSubscriber.where(["email_address = ?", email])
		puts emails
		count = emails.count()
		puts count
		if(count == 0)
			EmailSubscriber.create(email_address: email)
		end
		@mailchimpInfo = [{"result": "OK", "jsonObj": count}]
	end
end