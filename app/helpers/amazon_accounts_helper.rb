module AmazonAccountsHelper
  def has_errors? record
    record.errors.any?
  end

  def error_messages record, &block
    record.errors.full_messages.each(&block)
  end
end
