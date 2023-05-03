# frozen_string_literal: true

require 'smart_proxy_omaha/omaha_api'

map '/omaha' do
  run Proxy::Omaha::Api
end

map '/omahareleases' do
  run Rack::Directory.new(Proxy::Omaha::Plugin.settings.contentpath)
end
