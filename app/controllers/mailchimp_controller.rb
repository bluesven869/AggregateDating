class MailchimpController < ApplicationController
	require 'httparty'
	
	def index
		# response = HTTParty.post(base_uri, headers: headers)
	end

	def email_subscriber
		email = params[:email].to_str	
		
		emails = EmailSubscriber.where(["email_address = ?", email])
		count = emails.count()
		if(count == 0)
			EmailSubscriber.create(email_address: email)
		end
		@mailchimpInfo = [{"result": "OK", "jsonObj": count}]
	end
	def email_subscriber_list
		emails = EmailSubscriber.order(created_at: :desc)
		@mailchimpInfo = [{"result": "OK", "jsonObj": emails}]
	end
	def delete_email
		id = params[:id]
		EmailSubscriber.delete(id)
		emails = EmailSubscriber.order(created_at: :desc)
		@mailchimpInfo = [{"result": "OK", "jsonObj": emails}]
	end
end