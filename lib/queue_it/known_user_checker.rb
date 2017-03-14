require 'digest/md5'
require "queue_it/url_builder"

module QueueIt
  class KnownUserChecker

    attr_accessor :shared_event_key, :event_id, :customer_id

    def initialize(shared_event_key, event_id, customer_id)
      self.shared_event_key = shared_event_key
      self.event_id         = event_id
      self.customer_id      = customer_id
    end

    def create_or_verify_queue_it_session!(url, params)
      queue_id                  = params['q' ] # A QuID, the user’s queue ID
      encrypted_place_in_queue  = params['p' ] # A text, an encrypted version of the user’s queue number
      expected_hash             = params['h' ] # An integer calculated hash
      timestamp                 = params['ts'] # An integer timestamp counting number of seconds since 1970-01-01 00:00:00 UTC

      verify_request!(url, queue_id, encrypted_place_in_queue, expected_hash, timestamp)
    end

    def verify_request!(url, queue_id, encrypted_place_in_queue, expected_hash, timestamp)
      raise QueueIt::MissingArgsGiven.new if [ url, queue_id, encrypted_place_in_queue, timestamp, expected_hash ].any?(&:nil?)

      if verify_md5_hash?(url, expected_hash)
        decrypted_place_in_queue(encrypted_place_in_queue)
      else
        raise QueueIt::NotAuthorized.new
      end
    end

    private

    # uses one char of each string at a given starting point
    # given b852fe78-0d10-4254-823c-f8749c401153 should get 4212870
    def decrypted_place_in_queue(encrypted_place_in_queue)
      return encrypted_place_in_queue[ 30..30 ] + encrypted_place_in_queue[ 3..3 ] + encrypted_place_in_queue[ 11..11 ] +
             encrypted_place_in_queue[ 20..20 ] + encrypted_place_in_queue[ 7..7 ] + encrypted_place_in_queue[ 26..26 ] +
             encrypted_place_in_queue[ 9..9 ]
    end

    # TODO add timestamp check
    def verify_md5_hash?(url, expected_hash )
      url_no_hash = "#{ url[ 0..-33 ] }#{ shared_event_key }"
      actual_hash = Digest::MD5.hexdigest( utf8_encode( url_no_hash ) )

      return (expected_hash == actual_hash)
    end

    def utf8_encode(s)
      s.encode('UTF-8', 'UTF-8')
      s
    end
  end
end
