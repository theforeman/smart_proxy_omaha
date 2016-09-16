module ::Proxy::Omaha
  class ConfigurationLoader
    def load_classes
      require 'smart_proxy_omaha/dependency_injection'
      require 'smart_proxy_omaha/foreman_client'
      require 'smart_proxy_omaha/omaha_api'
    end

    def load_dependency_injection_wirings(container_instance, settings)
      container_instance.singleton_dependency :foreman_client_impl, Proxy::Omaha::ForemanClient
      container_instance.singleton_dependency :release_repository_impl, Proxy::Omaha::ReleaseRepository
      container_instance.singleton_dependency :metadata_provider_impl, (lambda do
        Proxy::Omaha::MetadataProvider.new(:contentpath => settings[:contentpath])
      end)
    end
  end
end
