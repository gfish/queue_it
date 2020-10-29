require 'uri'
require 'faraday'
require 'faraday_middleware'
require 'faraday/raise_http_exception'
require 'queue_it/api/error'

module QueueIt
  module Api
    class Client
      JSON_FORMAT  = "application/json".freeze

      def initialize(customer_id, api_key: nil, debug: false)
        self.customer_id = customer_id
        self.api_key = api_key
        self.debug   = debug
        self.endpoint = URI("https://#{customer_id}.api2.queue-it.net/2_0/event")
      end

      def put(path, body)
        connection.put(path, body)
      end

      private

      attr_accessor :api_key, :customer_id, :debug, :endpoint

      def options
        {
          url: endpoint.dup,
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
