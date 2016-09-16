module Proxy::Omaha
  module DependencyInjection
    include Proxy::DependencyInjection::Accessors
    def container_instance
      @container_instance ||= ::Proxy::Plugins.instance.find { |p| p[:name] == :omaha }[:di_container]
    end
  end
end
