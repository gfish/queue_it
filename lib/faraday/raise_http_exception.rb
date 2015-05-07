require 'faraday'
require 'json'

module FaradayMiddleware
  class RaiseHttpException < Faraday::Middleware
    def call(env)
      @app.call(env).on_complete do |response|
        case response[:status].to_i
        when 400
          raise QueueIt::Api::BadRequest.new(response.body, error_details(response))
        when 403
          raise QueueIt::Api::Forbidden.new(response.body, error_details(response))
        when 404
          raise QueueIt::Api::NotFound.new(response.body, error_details(response))
        when 500
          raise QueueIt::Api::InternalServerError.new(response.body, error_details(response))
        when 503
          raise QueueIt::Api::ServiceUnavailable.new(response.body, error_details(response))
        end
      end
    end

    private

    def error_response_body(code, text)
      { "ErrorCode" => code, "ErrorText" => text }
    end

    def acts_like_json?(response_body)
      !response_body.nil? && !response_body.empty? && response_body.kind_of?(String)
    end

    def parse_json(body)
      JSON.parse(body)
    rescue JSON::ParserError
      error_response_body(nil, body)
    end

    def parse_body(response_body)
      acts_like_json?(response_body) ? parse_json(response_body) : error_response_body(nil, nil)
    end

    def error_details(response)
      response_body = parse_body(response.body)
      { status: response[:status].to_i, code: response_body["ErrorCode"], text: response_body["ErrorText"] }
    end
  end
end
