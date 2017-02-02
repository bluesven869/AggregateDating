Rails.application.routes.draw do
	
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'

  resources :cmb, only: [:index]
  get '/cmb/get_profile'
  get '/cmb/set_profile'
  get '/cmb/get_bagels'
  get '/cmb/set_bagel'
  get '/cmb/send_batch'
  get '/cmb/get_resources'
  get '/cmb/get_bagels_history'
  get '/cmb/get_photolabs'
  get '/cmb/give_take'
  get '/cmb/purchase'
  get '/cmb/report'
  get '/cmb/photo'
  resources :tinder, only: [:index]  
  resources :bumble, only: [:index]  
  resources :mailchimp, only: [:index]
  get '/mailchimp/email_subscriber'
  get '/mailchimp/email_subscriber_list'
  get '/mailchimp/delete_email'

  resources :admin, only: [:index]
  get '/admin/get_page_uris'
  get '/admin/add_page_uri'
  get '/admin/update_page_uri'
  get '/admin/delete_page_uri'
  get '/admin/select_page_uri'
  get '/admin/save_seo_data'
  get '/admin/get_page_uri'
end
