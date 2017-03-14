require 'queue_it'

module QueueIt
  RSpec.describe KnownUserChecker do
    let(:secret_key) { "1c9950a7-f716-432e-b5fa-b148d00480db" }
    let(:service) { KnownUserChecker.new }

    specify "happy path" do
      url = "https://example.com/some/path?q=2647344b-e639-4cd6-8a77-3a8801553716&p=053eeb2c-b272-41a2-aacf-2742bc99676c&ts=1489367379&c=examplecompany&e=someeventid42&rt=Queue&h=bbaf9807496ecb687c85bfcc1a8369e1"

      result = service.(
        secret_key: secret_key,
        request_url: url,
        request_params: parse_params(url))
      expect(result).not_to be_empty
    end

    specify do
      url = "https://example.com/some/path"

      expect do
        service.(secret_key: secret_key, request_url: url, request_params: {})
      end.to raise_error(MissingArgsGiven)
    end

    specify "queue id param is required" do
      url = "https://example.com/some/path?p=053eeb2c-b272-41a2-aacf-2742bc99676c&ts=1489367379&c=examplecompany&e=someeventid42&rt=Queue&h=bbaf9807496ecb687c85bfcc1a8369e1"

      expect do
        service.(secret_key: secret_key, request_url: url, request_params: parse_params(url))
      end.to raise_error(MissingArgsGiven)
    end

    specify "timestamp param is required" do
      url = "https://example.com/some/path?q=2647344b-e639-4cd6-8a77-3a8801553716&p=053eeb2c-b272-41a2-aacf-2742bc99676c&c=examplecompany&e=someeventid42&rt=Queue&h=bbaf9807496ecb687c85bfcc1a8369e1"

      expect do
        service.(secret_key: secret_key, request_url: url, request_params: parse_params(url))
      end.to raise_error(MissingArgsGiven)
    end

    specify "encrypted place in queue param is required" do
      url = "https://example.com/some/path?q=2647344b-e639-4cd6-8a77-3a8801553716&ts=1489367379&c=examplecompany&e=someeventid42&rt=Queue&h=bbaf9807496ecb687c85bfcc1a8369e1"

      expect do
        service.(secret_key: secret_key, request_url: url, request_params: parse_params(url))
      end.to raise_error(MissingArgsGiven)
    end

    specify "hash is required" do
      url = "https://example.com/some/path?q=2647345b-e639-4cd6-8a77-3a8801553716&p=053eeb2c-b272-41a2-aacf-2742bc99676c&ts=1489367379&c=examplecompany&e=someeventid42&rt=Queue"

      expect do
        service.(secret_key: secret_key, request_url: url, request_params: parse_params(url))
      end.to raise_error(MissingArgsGiven)
    end

    def parse_params(url)
      CGI.parse(URI.parse(url).query).each_with_object({}) {|(k,v),o| o[k] = v.first }
    end
  end
end
