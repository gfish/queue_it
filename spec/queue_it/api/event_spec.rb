require 'queue_it/api/fake_client'
require 'queue_it/api/event'

module QueueIt
  module Api
    describe Event do
      let(:client) { FakeClient.new("VALID_KEY") }

      subject(:event_adapter) { Event.new(client) }

      context "#create_or_update" do
        specify "creates or updates event" do
          expect(event_adapter.create_or_update(event_id:             "fancy_event",
                                                display_name:         "Fancy Event 2015",
                                                description:          "Foo",
                                                redirect_url:         "https://example.com/en/events/fancy_event/tickets",
                                                start_time:           Time.new(2015,04,28,17,25,46, "+02:00"),
                                                end_time:             Time.new(2015,04,28,21,25,46, "+02:00"),
                                                know_user_secret_key: "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6",
                                                max_redirects_per_minute: 15,
                                                queue_number_validity_in_minutes: 15))
            .to eq(expected_create_response)
        end

        specify "minimum viable attributes for creating event" do
          end_time = Time.utc(2016,04,27,21,25,46).to_i
          response = expected_create_response.merge({
              "Description"       => nil,
              "EventEndTime"      => "/Date(#{end_time})/",
              "EventEndLocalTime" => "/Date(#{end_time}+0000)/",
            })

          expect(event_adapter.create_or_update(event_id:             "fancy_event",
                                                display_name:         "Fancy Event 2015",
                                                redirect_url:         "https://example.com/en/events/fancy_event/tickets",
                                                start_time:           Time.utc(2015,04,28,15,25,46),
                                                know_user_secret_key: "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6",))
            .to eq(response)
        end

        specify "set custom time zone in the ruby way" do
          response = expected_create_response.merge({ "TimeZone" => "Romance Standard Time" })
          expect(event_adapter.create_or_update(event_id:                          "fancy_event",
                                                display_name:                      "Fancy Event 2015",
                                                description:                       "Foo",
                                                redirect_url:                      "https://example.com/en/events/fancy_event/tickets",
                                                start_time:                        Time.new(2015,04,28,17,25,46, "+02:00"),
                                                end_time:                          Time.new(2015,04,28,21,25,46, "+02:00"),
                                                know_user_secret_key:              "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6",
                                                max_redirects_per_minute:          15,
                                                queue_number_validity_in_minutes:  15,
                                                time_zone:                         "Europe/Copenhagen",))
            .to eq(response)
        end
      end

      private

      def expected_create_response
        {
          "AfterEventLogic"              => 2,
          "AfterEventRedirectPage"       => nil,
          "AllowedCustomLayouts"         => [],
          "BrowserCultureEnabled"        => false,
          "CustomLayout"                 => nil,
          "Description"                  => "Foo",
          "DisplayName"                  => "Fancy Event 2015",
          "DomainAlias"                  => "fancy_event-testcompany.queue-it.net",
          "EventCultureName"             => "en-GB",
          "EventEndTime"                 => "/Date(1430249146)/",
          "EventStartTime"               => "/Date(1430234746)/",
          "JavaScriptSupportEnabled"     => false,
          "KnowUserSecretKey"            => "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6",
          "KnowUserSecurity"             => 5,
          "MaxNoOfRedirectsPrQId"        => 1,
          "MaxRedirectsPerMinute"        => 15,
          "PreQueueStartTime"            => "/Date(1430231146)/",
          "QueueNumberValidityInMinutes" => 15,
          "RedirectUrl"                  => "https://example.com/en/events/fancy_event/tickets",
          "ReportPerformanceCounters"    => false,
          "SafetyNetAverageMinutes"      => 3,
          "SafetyNetEvent"               => false,
          "TargetUrlSupportEnabled"      => true,
          "TargetUrlValidationRegex"     => "",
          "TimeZone"                     => "UTC",
          "UseSSL"                       => 2,
          "XUsersInFrontOfYou"           => 100,
          "EventEndLocalTime"            => "/Date(1430249146+0000)/",
          "EventId"                      => "fancy_event",
          "EventStartLocalTime"          => "/Date(1430234746+0000)/",
          "PreQueueStartLocalTime"       => "/Date(1430231146+0000)/",
          "QueueUrl"                     => "http://fancy_event-testcompany.queue-it.net/?c=testcompany&e=fancy_event"
        }
      end
    end
  end
end
