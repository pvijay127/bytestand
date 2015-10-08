class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :report_request_id

      t.timestamps null: false
    end
  end
end
