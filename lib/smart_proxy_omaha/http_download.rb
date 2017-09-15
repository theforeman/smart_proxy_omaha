require 'thread'
require 'smart_proxy_omaha/http_shared'

module Proxy::Omaha
  class HttpDownload
    include Proxy::Log
    include HttpShared

    attr_accessor :dst, :src, :tmp, :result

    def initialize(src, dst)
      @src = src
      @dst = dst
      @tmp = Tempfile.new('download', File.dirname(dst))
    end

    def start
      @task = Thread.new do
        @result = run
      end
      @task.abort_on_exception = true
      @task
    end

    def run
      logger.info "Downloading #{src} to #{dst}."
      res = download
      logger.info "Finished downloading #{dst}."
      res
    end

    def join
      @task.join
    end

    private

    def download
      http, request = connection_factory(src)

      http.request(request) do |response|
        open(tmp, 'w') do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end

      File.rename(tmp, dst)

      true
    ensure
      tmp.unlink
    end
  end
end
