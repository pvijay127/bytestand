class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.text :domain, index: true
      t.text :token

      t.timestamps null: false
    end
  end
end
