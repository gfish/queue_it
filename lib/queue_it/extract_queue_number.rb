require 'digest/md5'

module QueueIt
  class ExtractQueueNumber
    def call(secret_key:, request_url:, request_params:)
      encrypted_place_in_queue = request_params['p']
      expected_hash = request_params['h']

      raise QueueIt::MissingArgsGiven.new if queue_it_params_missing?(request_params)

      if verify_md5_hash?(request_url, expected_hash, secret_key)
        return decrypted_place_in_queue(encrypted_place_in_queue)
      else
        raise QueueIt::NotAuthorized.new
      end
    end

    private

    def queue_it_params_missing?(params)
      queue_id = params['q'] # A QuID, the user’s queue ID
      encrypted_place_in_queue = params['p'] # A text, an encrypted version of the user’s queue number
      expected_hash = params['h'] # An integer calculated hash
      timestamp = params['ts'] # An integer timestamp counting number of seconds since 1970-01-01 00:00:00 UTC

      [queue_id, encrypted_place_in_queue, timestamp, expected_hash].any?(&:nil?)
    end

    # uses one char of each string at a given starting point
    # given b852fe78-0d10-4254-823c-f8749c401153 should get 4212870
    def decrypted_place_in_queue(encrypted_place_in_queue)
      return encrypted_place_in_queue[ 30..30 ] + encrypted_place_in_queue[ 3..3 ] + encrypted_place_in_queue[ 11..11 ] +
             encrypted_place_in_queue[ 20..20 ] + encrypted_place_in_queue[ 7..7 ] + encrypted_place_in_queue[ 26..26 ] +
             encrypted_place_in_queue[ 9..9 ]
    end

    # TODO add timestamp check
    def verify_md5_hash?(url, expected_hash, secret_key)
      url_no_hash = "#{url[ 0..-33 ]}#{secret_key}"
      actual_hash = Digest::MD5.hexdigest(url_no_hash)

      return (expected_hash == actual_hash)
    end
  end
end
