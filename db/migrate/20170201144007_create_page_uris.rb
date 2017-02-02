class CreatePageUris < ActiveRecord::Migration[5.0]
  def change
    create_table :page_uris do |t|      
      t.string "page_uri"
      t.integer "page_type"
      t.timestamps
    end
  end
end
