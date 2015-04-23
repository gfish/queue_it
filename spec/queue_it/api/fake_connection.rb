require 'ostruct'

module QueueIt
  module Api
    class FakeConnection
      def initialize(api_key:, endpoint_url:)
        self.api_key      = api_key
        self.endpoint_url = endpoint_url
      end

      def put(path, body)
        OpenStruct.new( body: create_or_update_response(path, body) )
      end

      private

      attr_accessor :api_key, :endpoint_url

      def create_or_update_response(event_id, attributes)
        end_time             = attributes.fetch("EventEndTime")
        start_time           = attributes.fetch("EventStartTime")
        pre_queue_start_time = attributes.fetch("PreQueueStartTime")
        {
          "AfterEventLogic"=>2,
          "AfterEventRedirectPage"=>nil,
          "AllowedCustomLayouts"=>[],
          "BrowserCultureEnabled"=>false,
          "CustomLayout"=>nil,
          "Description"=>attributes.fetch("Description"),
          "DisplayName"=>attributes.fetch("DisplayName"),
          "DomainAlias"=>"#{event_id}-testcompany.queue-it.net",
          "EventCultureName"=>attributes.fetch("EventCultureName"),
          "EventEndTime"=>"#{end_time}",
          "EventStartTime"=>"#{start_time}",
          "JavaScriptSupportEnabled"=>false,
          "KnowUserSecretKey"=>attributes.fetch("KnowUserSecretKey"),
          "KnowUserSecurity"=>5,
          "MaxNoOfRedirectsPrQId"=>1,
          "MaxRedirectsPerMinute"=>attributes.fetch("MaxRedirectsPerMinute"),
          "PreQueueStartTime"=>"#{pre_queue_start_time}",
          "QueueNumberValidityInMinutes"=>attributes.fetch("QueueNumberValidityInMinutes"),
          "RedirectUrl"=>attributes.fetch("RedirectUrl"),
          "ReportPerformanceCounters"=>false,
          "SafetyNetAverageMinutes"=>3,
          "SafetyNetEvent"=>false,
          "TargetUrlSupportEnabled"=>true,
          "TargetUrlValidationRegex"=>"",
          "TimeZone"=>attributes.fetch("TimeZone"),
          "UseSSL"=>2,
          "XUsersInFrontOfYou"=>100,
          "EventEndLocalTime"=>"/Date(#{extract_time(end_time)}+0000)/",
          "EventId"=>event_id,
          "EventStartLocalTime"=>"/Date(#{extract_time(start_time)}+0000)/",
          "PreQueueStartLocalTime"=>"/Date(#{extract_time(pre_queue_start_time)}+0000)/",
          "QueueUrl"=>"http://#{event_id}-testcompany.queue-it.net/?c=testcompany&e=#{event_id}"
        }
      end

      def extract_time(string)
        string.scan(/(?<=\/Date\()[0-9]+/).first
      end
    end
  end
end
