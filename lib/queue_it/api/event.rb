require 'json'
require 'uri'

module QueueIt
  module Api
    class Event
      def initialize(client)
        self.client = client
      end

      def create_or_update(event_id:, display_name:, start_time:, know_user_secret_key:, redirect_url:, end_time: nil, description: nil, max_redirects_per_minute: 15, event_culture_name: "en-GB", time_zone: "UTC", queue_number_validity_in_minutes: 15)
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

      ONE_YEAR        = 31557600.freeze
      ONE_HOUR        = 3600.freeze
      MD5HashSecurity = 5.freeze
      UseSSLAuto      = 2.freeze

      MICROSOFT_TIME_ZONE_INDEX_VALUES = {
        "Europe/Copenhagen" => "Romance Standard Time",
        "Europe/Helsinki"   => "FLE Standard Time",
        "Europe/London"     => "GMT Standard Time",
        "Europe/Paris"      => "GMT Standard Time",
        "Paris"             => "Romance Standard Time",
        "Stockholm"         => "W. Europe Standard Time",
      }.freeze

      def utc_start_time(start_time)
        start_time.to_i
      end

      def utc_end_time(start_time, end_time)
        end_time && end_time.to_i || utc_start_time(start_time) + ONE_YEAR
      end

      def pre_queue_start_time(start_time)
        start_time.to_i - ONE_HOUR
      end

      def translate_time_zone(time_zone)
        MICROSOFT_TIME_ZONE_INDEX_VALUES.fetch(time_zone, time_zone)
      end

      def queue_attributes(start_time:, end_time:, know_user_secret_key:, max_redirects_per_minute:, redirect_url:, description:, display_name:, event_culture_name:, queue_number_validity_in_minutes:, time_zone:)
        {
          "AfterEventLogic"              =>2,
          "AfterEventRedirectPage"       =>nil,
          "AllowedCustomLayouts"         =>[],
          "BrowserCultureEnabled"        =>true,
          "CustomLayout"                 =>"HighLoad layout",
          "Description"                  =>description,
          "DisplayName"                  =>display_name,
          "DomainAlias"                  =>"String content",
          "EventCultureName"             =>event_culture_name,
          "EventEndTime"                 =>"/Date(#{utc_end_time(start_time, end_time)})/",
          "EventStartTime"               =>"/Date(#{utc_start_time(start_time)})/",
          "JavaScriptSupportEnabled"     =>false,
          "KnowUserSecretKey"            =>know_user_secret_key,
          "KnowUserSecurity"             =>MD5HashSecurity,
          "MaxNoOfRedirectsPrQId"        =>1,
          "MaxRedirectsPerMinute"        =>max_redirects_per_minute,
          "PreQueueStartTime"            =>"/Date(#{pre_queue_start_time(start_time)})/",
          "QueueNumberValidityInMinutes" =>queue_number_validity_in_minutes,
          "RedirectUrl"                  =>URI(redirect_url).to_s,
          "ReportPerformanceCounters"    =>true,
          "SafetyNetAverageMinutes"      =>3,
          "SafetyNetEvent"               =>false,
          "TargetUrlSupportEnabled"      =>false,
          "TargetUrlValidationRegex"     =>"",
          "TimeZone"                     =>translate_time_zone(time_zone),
          "UseSSL"                       =>UseSSLAuto,
          "XUsersInFrontOfYou"           =>100
        }
      end

      def perform_request(method, path, body = {})
        json_response = client.public_send(method, path, body)
        json_response.body
      end
    end
  end
end
