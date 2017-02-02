class CreatePageSeos < ActiveRecord::Migration[5.0]
  def change
    create_table :page_seos do |t|
      t.integer	"uri_id"
      t.string "page_title"
      t.text "page_description"      
      t.string "page_keywords"
      t.string "url"
      t.string "fb_title"
      t.text "fb_description"
      t.string "twitter_title"
      t.text "twitter_description"
      t.timestamps
    end
  end
end
