require 'thread'
require 'base64'
require 'smart_proxy_omaha/http_shared'
require 'smart_proxy_omaha/http_verify'

module Proxy::Omaha
  class HttpDownload
    include Proxy::Log
    include HttpShared

    attr_accessor :dst, :src, :tmp, :result, :http_response

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
      logger.info "#{filename}: Downloading #{src} to #{dst}."
      unless download
        logger.error "#{filename} failed to download."
        return false
      end
      logger.info "#{filename}: Finished downloading #{dst}."
      unless valid?
        logger.error "#{filename} is not valid. Deleting corrupt file."
        File.unlink(tmp)
        return false
      end
      # no DIGESTS file is provided for update.gz
      # so we need to generate our own based on the
      # http headers
      write_digest if filename == 'update.gz'
      finish
    ensure
      tmp.unlink
      true
    end

    def join
      @task.join
    end

    def valid?
      verifier.valid?
    end

    def finish
      File.rename(tmp, dst)
      true
    end

    def write_digest
      hexdigest = Digest.hexencode(Base64.decode64(verifier.local_md5))
      File.open("#{dst}.DIGESTS", 'w') { |file| file.write("#{hexdigest}  #{filename}\n") }
    end

    private

    def verifier
      @verifier ||= HttpVerify.new(
        :local_file => tmp,
        :http_request => http_response,
        :filename => filename,
      )
    end

    def filename
      File.basename(dst)
    end

    def download
      http, request = connection_factory(src)

      self.http_response = http.request(request) do |response|
        open(tmp, 'w') do |io|
          response.read_body do |chunk|
            io.write chunk
          end
        end
      end

      true
    end
  end
end
