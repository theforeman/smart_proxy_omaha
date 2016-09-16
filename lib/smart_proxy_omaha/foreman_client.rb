module Proxy::Omaha
  class ForemanClient < Proxy::HttpRequest::ForemanRequest
    def post_facts(factsdata)
      send_request(request_factory.create_post('api/hosts/facts', factsdata))
    end

    def post_report(report)
      send_request(request_factory.create_post('api/omaha_reports', report))
    end
  end
end
