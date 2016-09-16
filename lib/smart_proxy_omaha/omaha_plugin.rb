module Proxy::Omaha
  class NotFound < RuntimeError; end

  class Plugin < ::Proxy::Plugin
    plugin 'omaha', Proxy::Omaha::VERSION

    http_rackup_path File.expand_path('omaha_http_config.ru', File.expand_path('../', __FILE__))
    https_rackup_path File.expand_path('omaha_http_config.ru', File.expand_path('../', __FILE__))

    load_classes ::Proxy::Omaha::ConfigurationLoader
    load_dependency_injection_wirings ::Proxy::Omaha::ConfigurationLoader

    default_settings :sync_releases => 0,
      :contentpath => '/var/lib/foreman-proxy/omaha/content'

    validate_readable :contentpath
  end
end
