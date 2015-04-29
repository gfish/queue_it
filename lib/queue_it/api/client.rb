require 'uri'
require 'faraday'
require 'faraday_middleware'
require 'faraday/raise_http_exception'
require 'queue_it/api/error'

module QueueIt
  module Api
    class Client
      JSON_FORMAT  = "application/json".freeze
      ENDPOINT_URL = URI("https://api.queue-it.net/1.2/event").freeze

      def initialize(api_key)
        self.api_key = api_key
      end

      def put(path, body)
        connection.put(path, body)
      end

      private

      attr_accessor :api_key

      def connection
        @connection ||= Faraday.new(options) do |builder|
          builder.request  :json
          builder.response :json, content_type: /\bjson$/

          builder.adapter  Faraday.default_adapter
          builder.use      FaradayMiddleware::RaiseHttpException
        end
      end

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
    end
  end
end
