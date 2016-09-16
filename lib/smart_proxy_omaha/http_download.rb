require 'thread'
require 'smart_proxy_omaha/http_shared'

module Proxy::Omaha
  class HttpDownload
    include Proxy::Log
    include HttpShared

    attr_accessor :dst, :src, :result

    def initialize(src, dst)
      @src = src
      @dst = dst
    end

    def start
      @task = Thread.new do
        @result = run
      end
      @task.abort_on_exception = true
      @task
    end

    def run
      with_filelock do
        logger.info "Downloading #{src} to #{dst}."
        res = download
        logger.info "Finished downloading #{dst}."
        res
      end
    end

    def join
      @task.join
    end

    private

    def download
      http, request = connection_factory(src)

      http.request(request) do |response|
        open(dst, 'w') do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end
      true
    end

    def with_filelock
      lock = Proxy::FileLock.try_locking(dst)
      if lock.nil?
        false
      else
        begin
          yield
        ensure
          Proxy::FileLock.unlock(lock)
        end
      end
    end
  end
end
