require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Código não é recarregado entre requests
  config.cache_classes = true
  config.eager_load = true

  # Ambiente de produção
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Host Authorization
  if ENV["RAILS_ALLOWED_HOSTS"].present?
    ENV["RAILS_ALLOWED_HOSTS"].split(",").each do |host|
      config.hosts << host.strip
    end
  else
    # Apenas para demo: permite todos os hosts
    config.hosts.clear
  end

  # Master key (certifique-se que está no ENV)
  config.require_master_key = true

  # Servir arquivos estáticos se variável estiver presente
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Assets
  config.assets.compile = false
  config.active_storage.service = :local

  # SSL (opcional)
  # config.force_ssl = true

  # Logs
  config.log_level = :info
  config.log_tags = [:request_id]

  if ENV["RAILS_LOG_TO_STDOUT"].present? || ENV["RAILS_ENV"] == "production"
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
  config.i18n.fallbacks = true
end
