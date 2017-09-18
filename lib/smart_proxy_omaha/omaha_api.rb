require 'sinatra'
require 'smart_proxy_omaha/omaha_protocol'

module Proxy::Omaha

  class Api < ::Sinatra::Base
    extend Proxy::Omaha::DependencyInjection

    helpers ::Proxy::Helpers

    inject_attr :foreman_client_impl, :foreman_client
    inject_attr :release_repository_impl, :release_repository
    inject_attr :metadata_provider_impl, :metadata_provider

    post '/v1/update' do
      request.body.rewind
      request_body = request.body.read
      omaha_request = Proxy::Omaha::OmahaProtocol::Request.new(
        request_body,
        :ip => request.ip,
        :base_url => request.base_url
      )
      omaha_handler = Proxy::Omaha::OmahaProtocol::Handler.new(
        :request => omaha_request,
        :foreman_client => foreman_client,
        :repository => release_repository,
        :metadata_provider => metadata_provider
      )
      response = omaha_handler.handle
      status response.http_status
      response.to_xml
    end
  end
end
