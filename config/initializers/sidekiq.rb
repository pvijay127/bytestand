Sidekiq.configure_server do |config|
  Sidekiq::Logging.initialize_logger(File.join(Rails.root, 'log/sidekiq.log'))
end
