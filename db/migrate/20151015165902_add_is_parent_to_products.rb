class AddIsParentToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_parent, :boolean
  end
end
