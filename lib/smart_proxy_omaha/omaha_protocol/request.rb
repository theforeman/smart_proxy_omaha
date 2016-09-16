require 'resolv'
require 'ipaddr'

module Proxy::Omaha::OmahaProtocol
  class Request
    attr_reader :appid, :version, :track, :updatecheck, :eventtype, :eventresult, :board,
      :alephversion, :oemversion, :oem,
      :platform, :osmajor, :osminor, :hostname, :ipaddress, :ipaddress6,
      :body, :ip, :base_url

    def initialize(body, options)
      @body = body
      @ip = options.fetch(:ip)
      @base_url = options.fetch(:base_url)
      parse_request
      parse_ipaddress
      raise "Could not determine request hostname." if hostname.nil?
    end

    def facts_data
      {
        :name => hostname,
        :facts => to_facts.merge({:_type => :foreman_omaha, :_timestamp => Time.now})
      }
    end

    def to_status
      return :downloading if eventtype == 13 && eventresult == 1
      return :downloaded if eventtype == 14 && eventresult == 1
      return :installed if eventtype == 3 && eventresult == 1
      return :instance_hold if eventtype == 800 && eventresult == 1
      return :complete if eventtype == 3 && eventresult == 2
      return :error if eventtype == 3 && eventresult == 0
      :unknown
    end

    def event_description
      Proxy::Omaha::OmahaProtocol.event_description(eventtype)
    end

    def event_result
      Proxy::Omaha::OmahaProtocol.event_result(eventresult)
    end

    def from_coreos?
      appid == Proxy::Omaha::OmahaProtocol::COREOS_APPID
    end

    private

    def parse_request
      xml_request = Nokogiri::XML(body)
      @appid = xml_request.xpath('/request/app/@appid').to_s.gsub(/^{?([a-f0-9\-]+)}?$/, '\1')
      @version = xml_request.xpath('/request/app/@version').to_s
      @osmajor = version.gsub(/^(\d+)\.\d\.\d$/, '\1')
      @osminor = version.gsub(/^\d+\.(\d\.\d)$/, '\1')
      @track = xml_request.xpath('/request/app/@track').to_s
      @board = xml_request.xpath('/request/app/@board').to_s
      @alephversion = xml_request.xpath('/request/app/@alephversion').to_s
      @oemversion = xml_request.xpath('/request/app/@oemversion').to_s
      @oem = xml_request.xpath('/request/app/@oem').to_s
      @platform = xml_request.xpath('/request/os/@platform').to_s
      @platform = 'CoreOS' if @platform.empty?
      @updatecheck = !xml_request.xpath('/request/app/updatecheck').to_s.empty?
      @eventtype = xml_request.xpath('/request/app/event/@eventtype').to_s.to_i
      @eventresult = xml_request.xpath('/request/app/event/@eventresult').to_s.to_i
    end

    def parse_ipaddress
      ipaddr = IPAddr.new(ip) rescue nil
      return if ipaddr.nil?
      @ipaddress = ipaddr.to_s if ipaddr.ipv4?
      @ipaddress6 = ipaddr.to_s if ipaddr.ipv6?
      @hostname = lookup_hostname(ipaddr.to_s)
    end

    def lookup_hostname(hostip)
      Resolv.getname(hostip)
    rescue Resolv::ResolvError
      nil
    end

    def to_facts
      {
        :appid => appid,
        :version => version,
        :track => track,
        :board => board,
        :alephversion => alephversion,
        :oemversion => oemversion,
        :oem => oem,
        :platform => platform,
        :osmajor => osmajor,
        :osminor => osminor,
        :ipaddress => ipaddress,
        :ipaddress6 => ipaddress6,
        :hostname => hostname
      }
    end
  end
end
