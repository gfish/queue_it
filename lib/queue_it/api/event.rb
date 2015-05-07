require 'json'
require 'uri'
require 'time'

module QueueIt
  module Api
    class Event
      InvalidEventIdFormat = Class.new(StandardError)

      def initialize(client)
        self.client = client
      end

      def create_or_update(event_id:, display_name:, start_time:, know_user_secret_key: nil, redirect_url:, end_time: nil, description: "", max_redirects_per_minute: 15, event_culture_name: "en-US", time_zone: "UTC", queue_number_validity_in_minutes: 15)
        raise InvalidEventIdFormat unless valid_event_id_format?(event_id)

        attributes = queue_attributes(
          start_time:                       start_time,
          end_time:                         end_time,
          know_user_secret_key:             know_user_secret_key,
          max_redirects_per_minute:         max_redirects_per_minute,
          redirect_url:                     redirect_url,
          description:                      description,
          display_name:                     display_name,
          event_culture_name:               event_culture_name,
          queue_number_validity_in_minutes: queue_number_validity_in_minutes,
          time_zone:                        time_zone)

        perform_request(:put, event_id, attributes)
      end

      private

      attr_accessor :client

      ONE_YEAR = 31557600
      ONE_HOUR = 3600

      MICROSOFT_TIME_ZONE_INDEX_VALUES = {
        "Europe/Copenhagen" => "Romance Standard Time",
        "Europe/Helsinki"   => "FLE Standard Time",
        "Europe/London"     => "GMT Standard Time",
        "Europe/Paris"      => "GMT Standard Time",
        "Paris"             => "Romance Standard Time",
        "Stockholm"         => "W. Europe Standard Time",
      }.freeze

      EVENT_ID_FORMAT = /\A[a-zA-z0-9]{1,512}\z/.freeze

      def valid_event_id_format?(event_id)
        "#{event_id}".match(EVENT_ID_FORMAT)
      end

      def utc_start_time(start_time)
        start_time.utc
      end

      def utc_end_time(start_time, end_time)
        end_time && end_time.utc || utc_start_time(start_time) + ONE_YEAR
      end

      def pre_queue_start_time(start_time)
        start_time.utc - ONE_HOUR
      end

      def translate_time_zone(time_zone)
        MICROSOFT_TIME_ZONE_INDEX_VALUES.fetch(time_zone, time_zone)
      end

      def queue_attributes(start_time:, end_time:, know_user_secret_key:, max_redirects_per_minute:, redirect_url:, description:, display_name:, event_culture_name:, queue_number_validity_in_minutes:, time_zone:)
        {
          "DisplayName"                  => display_name,
          "RedirectUrl"                  => URI(redirect_url).to_s,
          "Description"                  => description,
          "TimeZone"                     => translate_time_zone(time_zone),
          "PreQueueStartTime"            => pre_queue_start_time(start_time).iso8601(7),
          "EventStartTime"               => utc_start_time(start_time).iso8601(7),
          "EventEndTime"                 => utc_end_time(start_time, end_time).iso8601(7),
          "EventCulture"                 => event_culture_name,
          "MaxRedirectsPerMinute"        => "#{max_redirects_per_minute}",
          "MaxNoOfRedirectsPrQueueId"    => "1",
          "QueueNumberValidityInMinutes" => "#{queue_number_validity_in_minutes}",
          "AfterEventLogic"              => "RedirectUsersToTargetPage",
          "AfterEventRedirectPage"       => "",
          "UseSSL"                       => "Auto",
          "JavaScriptSupportEnabled"     => "False",
          "TargetUrlSupportEnabled"      => "False",
          "SafetyNetMode"                => "Disabled",
          "KnowUserSecurity"             => "MD5Hash",
          "KnowUserSecretKey"            => know_user_secret_key,
          "CustomLayout"                 => "Default layout by Queue-it",
          "XUsersInFrontOfYou"           => nil,
          "TargetUrlValidationRegex"     => "",
          "DomainAlias"                  => "",
          "AllowedCustomLayouts"         => [],
          "BrowserCultureEnabled"        => "True",
          "IdleQueueLogic"               => "UseBeforePage",
          "IdleQueueRedirectPage"        => ""
        }
      end

      def perform_request(method, path, body = {})
        json_response = client.public_send(method, path, body)
        json_response.body
      end
    end
  end
end
