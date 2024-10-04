class CreateLinkClicks < ActiveRecord::Migration[8.0]
  def change
    create_table :link_clicks do |t|
      t.string :url
      t.string :anchor_text
      t.string :referrer
      t.string :user_agent
      t.string :ip_address

      t.timestamps
    end

    # Adding indexes for faster querying
    add_index :link_clicks, :url
    add_index :link_clicks, :created_at
    add_index :link_clicks, :ip_address
    add_index :link_clicks, :referrer
  end
end
