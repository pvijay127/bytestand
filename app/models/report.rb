class Report < ActiveRecord::Base
  has_many :products
end

# == Schema Information
# Schema version: 20151008161652
#
# Table name: reports
#
#  created_at        :datetime         not null
#  id                :integer          not null, primary key
#  report_request_id :string
#  updated_at        :datetime         not null
#
