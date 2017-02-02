class AdminController < ApplicationController
	require 'httparty'
	
	def index
		# response = HTTParty.post(base_uri, headers: headers)
	end
	def get_page_uris
		page_uris = PageUri.order(created_at: :asc)			
		@adminInfo = [{"result": "OK", "jsonObj": page_uris}]
	end

	def add_page_uri		
		if (not params.has_key?(:link))
			@adminInfo = [{"result": "Unallowed access!","jsonObj": "no params"}]
		else
			@link 	= JSON.parse params[:link]			
			uris = PageUri.where(["page_uri = ?", @link["page_uri"]])
			count = uris.count()
			if(count == 0)
				PageUri.create(page_uri: @link['page_uri'], page_type: @link['page_type'])
			end
			page_uris = PageUri.order(created_at: :asc)		
			@adminInfo = [{"result": "OK", "jsonObj": page_uris}]
		end
	end

	def update_page_uri
		if (not params.has_key?(:link))
			@adminInfo = [{"result": "Unallowed access!","jsonObj": "no params"}]
		else
			@link 	= JSON.parse params[:link]			
			uri = PageUri.where(["id = ?", @link["id"]])
			uri.update_all "page_uri='"+@link["page_uri"]+"', page_type=" + @link["page_type"]
			page_uris = PageUri.order(created_at: :asc)		
			@adminInfo = [{"result": "OK", "jsonObj": page_uris}]
		end
	end

	def delete_page_uri
		id = params[:id]
		PageUri.delete(id)
		page_uris = PageUri.order(created_at: :asc)		
		@adminInfo = [{"result": "OK", "jsonObj": page_uris}]
	end

	def select_page_uri
		if (not params.has_key?(:id))
			@adminInfo = [{"result": "Unallowed access!","jsonObj": "no params"}]
		else
			id = params[:id]
			seo = PageSeo.where(["uri_id = ?", id])			
			@adminInfo = [{"result": "OK", "jsonObj": seo}]
		end		
	end

	def save_seo_data
		if (not params.has_key?(:seo_obj))
			@adminInfo = [{"result": "Unallowed access!","jsonObj": "no params"}]
		else
			@seo_obj 	= JSON.parse params[:seo_obj]
			#seo.id                = $scope.seo_id
      		#seo.uri_id            = $scope.seo_link_id
      		#seo.page_title        = $scope.seo_title
      		#seo.url               = $scope.seo_url
      		#seo.page_description  = $scope.seo_description
      		#seo.page_keywords     = $scope.seo_keyword

			if (@seo_obj['id'] == 0)
				PageSeo.create(uri_id: @seo_obj['uri_id'], page_title: @seo_obj['page_title'], url: @seo_obj['url'], page_description: @seo_obj['page_description'], page_keywords: @seo_obj['page_keywords'])
				
			else
				seo = PageSeo.where(["id = ?", @seo_obj["id"]])
				sql = "uri_id=" + @seo_obj["uri_id"].to_s + ", page_title='" + @seo_obj["page_title"]+ "',url='" + @seo_obj["url"] + "',page_description='" + @seo_obj["page_description"] + "',page_keywords='" + @seo_obj["page_keywords"] + "'"
				seo.update_all sql
				
			end	
			seo = PageSeo.where(["uri_id = ?", @seo_obj["id"]])			
			@adminInfo = [{"result": "OK", "jsonObj": seo}]
		end	
	end

	def get_page_uri
		if (not params.has_key?(:link))
			@adminInfo = [{"result": "Unallowed access!","jsonObj": "no params"}]
		else
			link = params[:link].to_str
			uri = PageUri.where(["page_uri = ?", link])
			seo = PageSeo.where(["uri_id = ?", uri[0].id])			
			@adminInfo = [{"result": "OK", "jsonObj": seo}]
		end		
	end

end