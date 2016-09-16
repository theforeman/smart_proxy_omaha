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

      unless ['stable', 'beta', 'alpha'].include?(request.track)
        logger.error "Unknown track requested. Aborting Omaha request."
        return Proxy::Omaha::OmahaProtocol::Eventacknowledgeresponse.new(
          :appid => request.appid,
          :base_url => request.base_url,
          :status => 'error-unknownApplication'
        )
      end

      upload_facts
      process_report

      if request.updatecheck
        handle_update
      else
        handle_event
      end
    end

    private

    def upload_facts
      foreman_client.post_facts(request.facts_data.to_json)
    end

    def handle_event
      Proxy::Omaha::OmahaProtocol::Eventacknowledgeresponse.new(
        :appid => request.appid,
        :base_url => request.base_url
      )
    end

    def process_report
      report = {
        'host' => request.hostname,
        'status' => request.to_status.to_s,
        'omaha_version' => request.version,
        'reported_at' => Time.now.getutc.to_s
      }
      foreman_client.post_report({'omaha_report' => report}.to_json)
    end

    def handle_update
      latest_os = repository.latest_os(request.track)
      if !latest_os.nil? && latest_os > Gem::Version.new(request.version)
        Proxy::Omaha::OmahaProtocol::Updateresponse.new(
          :appid => request.appid,
          :metadata => metadata_provider.get(request.track, latest_os),
          :board => request.board,
          :base_url => request.base_url
        )
      else
        Proxy::Omaha::OmahaProtocol::Noupdateresponse.new(
          :appid => request.appid,
          :base_url => request.base_url
        )
      end
    end
  end
end
