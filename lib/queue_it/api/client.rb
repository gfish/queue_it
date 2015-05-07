require 'uri'
require 'faraday'
require 'faraday_middleware'
require 'faraday/raise_http_exception'
require 'queue_it/api/error'

module QueueIt
  module Api
    class Client
      JSON_FORMAT  = "application/json".freeze
      ENDPOINT_URL = URI("https://api2.queue-it.net/2_0_beta/event").freeze

      def initialize(api_key: api_key, debug: false)
        self.api_key = api_key
        self.debug   = debug
      end

      def put(path, body)
        connection.put(path, body)
      end

      private

      attr_accessor :api_key, :debug

      def options
        {
          url: ENDPOINT_URL.dup,
          headers: {
            accept: JSON_FORMAT,
            content_type: JSON_FORMAT,
            "Api-Key" => api_key,
          },
        }
      end

      def debug?
        debug
      end

      def connection
        @connection ||= Faraday.new(options) do |builder|
          builder.request  :json
          builder.response :logger, nil, { bodies: true } if debug?
          builder.response :json, content_type: /\bjson$/

          builder.adapter  Faraday.default_adapter
          builder.use      FaradayMiddleware::RaiseHttpException
        end
      end
    end
  end
end
