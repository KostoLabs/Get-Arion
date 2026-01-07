if ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.environment = ENV["RAILS_ENV"]
    config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]
    config.enabled_environments = %w[production]

    # Use traces_sampler to dynamically set the sample rate
    # and exclude ActionCable connections from profiling.
    config.traces_sampler = lambda do |context|
      if context[:transaction_context][:name] == "GET /cable"
        0.0
      else
        0.25
      end
    end

    config.profiler_class = Sentry::Vernier::Profiler
  end
end
