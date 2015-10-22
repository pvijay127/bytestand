class AddAppUninstallWebhookIdToShop < ActiveRecord::Migration
  def change
    add_column :shops, :webhook_id, :string
  end
end
