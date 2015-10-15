class AddParentToProduct < ActiveRecord::Migration
  def change
    add_column :products, :parent_asin, :string
    add_column :products, :parent_id, :integer, index: true
    add_foreign_key :products, :products, primary_key: :id, column: :parent_id
  end
end
