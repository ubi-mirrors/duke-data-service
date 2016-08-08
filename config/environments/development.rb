Rails.application.configure do
  config.cache_classes = ENV['RAILS_CACHE_CLASSES'].present?
  config.eager_load = ENV['RAILS_EAGER_LOAD'].present?
  config.consider_all_requests_local       = ENV['RAILS_CONSIDER_REQUESTS_LOCAL'].present?
  config.action_controller.perform_caching = ENV['RAILS_PERFORM_CACHING'].present?
  config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.assets.js_compressor = :uglifier
  config.assets.compile = ENV['RAILS_COMPILE_ASSETS'].present?
  config.assets.digest = ENV['RAILS_DIGEST_ASSETS'].present?
  config.assets.debug = ENV['RAILS_DEBUG_ASSETS'].present?
  config.assets.raise_runtime_errors = ENV['RAILS_ERRORS_ASSETS'].present?
  config.action_mailer.raise_delivery_errors = ENV['RAILS_MAILER_ERRORS'].present?
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  unless ENV['NOFORCESSL'].present?
    config.force_ssl = true
  end

  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.lograge.custom_options = lambda do |event|
      {
        request_id: event.payload[:request_id],
        user_agent: event.payload[:user_agent],
        #remote_ip: event.payload[:remote_ip],
        grape_controller: event.payload[:params]["controller"]
      }
  end
end
