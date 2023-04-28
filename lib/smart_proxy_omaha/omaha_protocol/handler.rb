require 'smart_proxy_omaha/track'

module Proxy::Omaha::OmahaProtocol
  class Handler
    include ::Proxy::Log
    attr_reader :request, :foreman_client, :repository, :metadata_provider

    def initialize(options = {})
      @request = options.fetch(:request)
      @foreman_client = options.fetch(:foreman_client)
      @repository = options.fetch(:repository)
      @metadata_provider = options.fetch(:metadata_provider)
    end

    def handle
      logger.info "OmahaHandler: Received #{request.event_description} event with result: #{request.event_result}"

      unless request.from_coreos?
        logger.error "Appid does not match CoreOS. Aborting Omaha request."
        return Proxy::Omaha::OmahaProtocol::Eventacknowledgeresponse.new(
          :appid => request.appid,
          :base_url => request.base_url,
          :status => 'error-unknownApplication'
        )
      end

      unless Proxy::Omaha::Track.valid?(request.track)
        logger.error "Unknown track requested. Aborting Omaha request."
        return Proxy::Omaha::OmahaProtocol::Eventacknowledgeresponse.new(
          :appid => request.appid,
          :base_url => request.base_url,
          :status => 'error-unknownApplication'
        )
      end

      upload_facts
      process_report if request.event?

      if request.updatecheck?
        handle_update
      elsif request.event?
        handle_event
      elsif request.ping?
        handle_ping
      else
        logger.info "OmahaHandler: Unknown request."
        handle_error
      end
    rescue StandardError => e
      logger.error("OmahaHandler: Aw, Snap! Error: #{e}", e.backtrace)
      handle_error
    end

    private

    def upload_facts
      foreman_client.post_facts(request.facts_data.to_json)
    end

    def handle_event
      logger.info "OmahaHandler: Processing event."
      Proxy::Omaha::OmahaProtocol::Eventacknowledgeresponse.new(
        :appid => request.appid,
        :base_url => request.base_url
      )
    end

    def handle_ping
      logger.info "OmahaHandler: Processing ping."
      Proxy::Omaha::OmahaProtocol::Pingresponse.new(
        :appid => request.appid,
        :base_url => request.base_url
      )
    end

    def handle_error
      Proxy::Omaha::OmahaProtocol::Errorinternalresponse.new(
        :appid => request.appid,
        :base_url => request.base_url,
        :status => 'error-internal'
      )
    end

    def process_report
      report = {
        'host' => request.hostname,
        'status' => request.to_status.to_s,
        'omaha_version' => request.version,
        'machineid' => request.machineid,
        'omaha_group' => request.track,
        'oem' => request.oem,
        'reported_at' => report_timestamp,
      }
      foreman_client.post_report({ 'omaha_report' => report }.to_json)
    end

    def handle_update
      latest_os = repository.latest_os(request.track, request.board)
      if !latest_os.nil? && latest_os.version > Gem::Version.new(request.version)
        logger.info "OmahaHandler: Offering update from #{request.version} to #{latest_os.version}"
        Proxy::Omaha::OmahaProtocol::Updateresponse.new(
          :appid => request.appid,
          :metadata => metadata_provider.get(request.track, latest_os, request.board),
          :board => request.board,
          :base_url => request.base_url,
          :name => latest_os.update_filename
        )
      else
        logger.info "OmahaHandler: No update."
        Proxy::Omaha::OmahaProtocol::Noupdateresponse.new(
          :appid => request.appid,
          :base_url => request.base_url
        )
      end
    end

    def report_timestamp
      Time.now.getutc.to_s
    end
  end
end
