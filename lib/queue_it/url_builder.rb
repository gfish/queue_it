require 'addressable/uri'

module QueueIt
  class UrlBuilder
    def self.build_queue_url(customer_id, event_id, redirect_url)
      "http://q.queue-it.net/?c=#{customer_id}&e=#{event_id}&t=#{CGI.escape(redirect_url)}"
    end

    def self.build_cancel_url(customer_id, event_id, queue_id = nil)
      "http://q.queue-it.net/cancel.aspx?c=#{customer_id}&e=#{event_id}&q=#{queue_id}"
    end

    # Removes all queue_it params from URL
    # eg.:
    # http://billetto.com/events/distortion/tickets?q=3d2d5097-c7e1-40e3-8d55-4bb721819324&p=56d0f360-4201-4e47-90d9-333872063976&ts=1393411468&c=billettodk&e=rainmaking&rt=Queue&h=0931dc67562c9a25c7a37bad33a6b46a
    # to:
    # http://billetto.com/events/distortion/tickets
    def self.clean_url(request_url)
      uri = Addressable::URI.parse(request_url)

      params = uri.query_values
      queue_it_params.each do |param|
        params.delete(param)
      end

      uri.query_values = params
      uri.to_s
    end

    def self.contains_queue_params?(request_url)
      uri = Addressable::URI.parse(request_url)
      request_params = uri.query_values

      # Check if request_params contains any queue_it_params
      !(queue_it_params & request_params.keys).empty?
    end

   private
    def self.queue_it_params
      ['q', 'p', 'h', 'ts', 'e', 'rt', 'c']
    end
  end
end


