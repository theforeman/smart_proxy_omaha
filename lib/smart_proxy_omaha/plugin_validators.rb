module Proxy
  module Omaha
    module PluginValidators
      class DistributionValidator < ::Proxy::PluginValidators::Base
        def validate!(settings)
          raise ::Proxy::Error::ConfigurationError, "Setting '#{@setting_name}' must be a supported Omaha distribution ('coreos' or 'flatcar')" unless ['coreos', 'flatcar'].include?(settings[@setting_name])
        end
      end
    end
  end
end
