class CreateShortLinks < ActiveRecord::Migration[7.2]
  def change
    create_table :short_links do |t|
      t.string :original_url
      t.string :alias
      t.datetime :expires_at

      t.timestamps
    end
  end
end
