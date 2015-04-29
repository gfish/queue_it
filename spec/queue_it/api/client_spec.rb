require 'json'
require 'webmock/rspec'
require 'queue_it/api/client'
require 'pry'

module QueueIt
  module Api
    describe Client do
      subject(:client) { described_class.new("SECURE_KEY") }

      specify "PUT data under given endpoint & path in JSON format" do
        request_hash  = { "Request" => true }
        response_hash = { "Response" => true }

        stub_successful_put(request_hash, response_hash)

        expect( client.put("fancy_event", request_hash).body ).to eq(response_hash)
      end

      specify "authentication error handling" do
        stub_unauthorized

        expect{ client.put("fancy_event", {}) }.to raise_error(Forbidden)
      end

      specify "error details are being parsed" do
        stub_unauthorized

        begin
          client.put("fancy_event", {})
        rescue Forbidden => e
          expect(e.status).to eq(403)
          expect(e.code).to   eq(4000)
          expect(e.text).to   eq("Authentication failed. Supply valid API key to access this operation")
        end
      end

      specify "server error with html body" do
        stub_internal_server_error

        expect{ client.put("fancy_event", "{}") }.to raise_error(InternalServerError)
      end

      specify "error without a body" do
        stub_internal_server_error

        begin
          client.put("fancy_event", "{}")
        rescue InternalServerError => e
          expect(e.status).to eq(500)
          expect(e.code).to   be_nil
          expect(e.text).to   eq("<html>Internal Server Error<\/html>")
        end
      end

      specify "bad request error handling" do
        stub_bad_request

        expect{ client.put("fancy_event", "{}") }.to raise_error(BadRequest)
      end

      specify "not found error handling" do
        stub_not_found

        expect{ client.put("fancy_event", "{}") }.to raise_error(NotFound)
      end

      specify "service unavailable error handling" do
        stub_service_unavailable

        expect{ client.put("fancy_event", "{}") }.to raise_error(ServiceUnavailable)
      end

      private

      def endpoint_url
        Client::ENDPOINT_URL.to_s + "/fancy_event"
      end

      def stub_request_factory(method: :put, status: 200, request_body: "{}", response_body: "{}", content_type: "application/json")
        stub_request(method, endpoint_url)
          .with(:body => request_body, :headers => {'Accept'=>'application/json', 'Api-Key'=>'SECURE_KEY', 'Content-Type'=>'application/json'})
          .to_return(:status => status, :body => response_body, :headers => { 'Content-Type' => content_type })
      end

      def stub_unauthorized
        body = "{\"ErrorCode\":4000,\"ErrorText\":\"Authentication failed. Supply valid API key to access this operation\"}"
        stub_request_factory(status: 403, response_body: body)
      end

      def stub_internal_server_error
        stub_request_factory(status: 500, response_body: "<html>Internal Server Error</html>", content_type: "text/html")
      end

      def stub_successful_put(request_body, response_body)
        stub_request_factory(request_body: JSON.generate(request_body), response_body: JSON.generate(response_body))
      end

      def stub_bad_request
        stub_request_factory(status: 400)
      end

      def stub_not_found
        stub_request_factory(status: 404)
      end

      def stub_service_unavailable
        stub_request_factory(status: 503)
      end
    end
  end
end
