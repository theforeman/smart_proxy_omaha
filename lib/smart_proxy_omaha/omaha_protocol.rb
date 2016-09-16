require 'nokogiri'
require 'smart_proxy_omaha/release_repository'
require 'smart_proxy_omaha/metadata'
require 'smart_proxy_omaha/metadata_provider'
require 'smart_proxy_omaha/omaha_protocol/response'
require 'smart_proxy_omaha/omaha_protocol/request'
require 'smart_proxy_omaha/omaha_protocol/eventacknowledgeresponse'
require 'smart_proxy_omaha/omaha_protocol/noupdateresponse'
require 'smart_proxy_omaha/omaha_protocol/updateresponse'
require 'smart_proxy_omaha/omaha_protocol/handler'

module Proxy::Omaha::OmahaProtocol
  COREOS_APPID = 'e96281a6-d1af-4bde-9a0a-97b76e56dc57'

  EVENT_TYPES = {
    0 => 'unknown',
    1 => 'download complete',
    2 => 'install complete',
    3 => 'update complete',
    4 => 'uninstall',
    5 => 'download started',
    6 => 'install started',
    9 =>  'new application install started',
    10 => 'setup started',
    11 => 'setup finished',
    12 => 'update application started',
    13 => 'update download started',
    14 => 'update download finished',
    15 => 'update installer started',
    16 => 'setup update begin',
    17 => 'setup update complete',
    20 => 'register product complete',
    30 => 'OEM install first check',
    40 => 'app-specific command started',
    41 => 'app-specific command ended',
    100 => 'setup failure',
    102 => 'COM server failure',
    103 => 'setup update failure',
    800 => 'ping'
  }.freeze

  EVENT_RESULTS = {
    0 =>  'error',
    1 =>  'success',
    2 =>  'success reboot',
    3 =>  'success restart browser',
    4 =>  'cancelled',
    5 =>  'error installer MSI',
    6 =>  'error installer other',
    7 =>  'noupdate',
    8 =>  'error installer system',
    9 =>  'update deferred',
    10 => 'handoff error'
  }.freeze

  def self.event_description(id)
    id = 0 unless EVENT_TYPES.key?(id)
    EVENT_TYPES[id]
  end

  def self.event_result(id)
    id = 0 unless EVENT_RESULTS.key?(id)
    EVENT_RESULTS[id]
  end
end
