require 'queue_it'

module QueueIt
  RSpec.describe KnownUserChecker do
    let(:secret_key) { "1c9950a7-f716-432e-b5fa-b148d00480db" }
    let(:event_id) { "someeventid42" }
    let(:customer_id) { "examplecompany" }
    let(:service) { KnownUserChecker.new(secret_key, event_id, customer_id) }

    specify "happy path" do
      url = "https://example.com/some/path?q=2647344b-e639-4cd6-8a77-3a8801553716&p=053eeb2c-b272-41a2-aacf-2742bc99676c&ts=1489367379&c=examplecompany&e=someeventid42&rt=Queue&h=bbaf9807496ecb687c85bfcc1a8369e1"

      expect(service.create_or_verify_queue_it_session!(url, parse_params(url))).not_to be_empty
    end

    specify do
      url = "https://example.com/some/path"

      expect do
        service.create_or_verify_queue_it_session!(url, {})
      end.to raise_error(MissingArgsGiven)
    end

    def parse_params(url)
      CGI.parse(URI.parse(url).query).each_with_object({}) {|(k,v),o| o[k] = v.first }
    end
  end
end
