class CreateEmailSubscribers < ActiveRecord::Migration[5.0]
  def change
    create_table :email_subscribers do |t|
      t.string "email_address"      
      t.timestamps
    end
  end
end
