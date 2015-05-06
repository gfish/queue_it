require 'queue_it/api/event'

module QueueIt
  module Api
    describe Event do
      let(:client)            { double(:api_client) }

      subject(:event_adapter) { Event.new(client) }

      context "#create_or_update" do
        specify "Submits proper request" do
          expect(client).to receive(:put).with("fancyevent", valid_create_body).and_return(double(body:{}))

          event_adapter.create_or_update(event_id:             "fancyevent",
                                         display_name:         "Fancy Event 2015",
                                         description:          "Foo",
                                         redirect_url:         "https://example.com/en/events/fancy_event/tickets",
                                         start_time:           Time.new(2015,04,28,17,25,46, "+02:00"),
                                         end_time:             Time.new(2015,04,28,21,25,46, "+02:00"),
                                         event_culture_name:   "en-US",
                                         know_user_secret_key: "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6",
                                         max_redirects_per_minute: 15,
                                         queue_number_validity_in_minutes: 15)
        end

        specify "Minimum viable attributes for creating event" do
          body = valid_create_body.merge({
            "Description"  => "",
            "EventEndTime" => "2016-04-27T21:25:46.0000000Z",
            "EventCulture" => "en-US",
          })

          expect(client).to receive(:put).with("fancyevent", body).and_return(double(body:{}))

          event_adapter.create_or_update(event_id:             "fancyevent",
                                         display_name:         "Fancy Event 2015",
                                         redirect_url:         "https://example.com/en/events/fancy_event/tickets",
                                         start_time:           Time.utc(2015,04,28,15,25,46),
                                         know_user_secret_key: "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6",)
        end

        specify "Set custom time zone in the ruby way" do
          body = valid_create_body.merge({
            "TimeZone"  => "Romance Standard Time",
          })

          expect(client).to receive(:put).with("fancyevent", body).and_return(double(body:{}))

          event_adapter.create_or_update(event_id:                          "fancyevent",
                                         display_name:                      "Fancy Event 2015",
                                         description:                       "Foo",
                                         redirect_url:                      "https://example.com/en/events/fancy_event/tickets",
                                         start_time:                        Time.new(2015,04,28,17,25,46, "+02:00"),
                                         end_time:                          Time.new(2015,04,28,21,25,46, "+02:00"),
                                         know_user_secret_key:              "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6",
                                         max_redirects_per_minute:          15,
                                         queue_number_validity_in_minutes:  15,
                                         time_zone:                         "Europe/Copenhagen",)
        end

        specify "Event id must have proper format" do
          invalid_event_id = "/fancyevent"

          expect do
            event_adapter.create_or_update(event_id:                          invalid_event_id,
                                           display_name:                      "Fancy Event 2015",
                                           description:                       "Foo",
                                           redirect_url:                      "https://example.com/en/events/fancy_event/tickets",
                                           start_time:                        Time.new(2015,04,28,17,25,46, "+02:00"),
                                           end_time:                          Time.new(2015,04,28,21,25,46, "+02:00"),
                                           know_user_secret_key:              "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6",
                                           max_redirects_per_minute:          15,
                                           queue_number_validity_in_minutes:  15,
                                           time_zone:                         "Europe/Copenhagen",)
          end.to raise_error(Event::InvalidEventIdFormat)
        end

        specify "Set custom number of redirects per minute" do
          body = valid_create_body.merge({
            "MaxRedirectsPerMinute" => "30",
          })

          expect(client).to receive(:put).with("fancyevent", body).and_return(double(body:{}))

          event_adapter.create_or_update(event_id:             "fancyevent",
                                         display_name:         "Fancy Event 2015",
                                         description:          "Foo",
                                         redirect_url:         "https://example.com/en/events/fancy_event/tickets",
                                         start_time:           Time.new(2015,04,28,17,25,46, "+02:00"),
                                         end_time:             Time.new(2015,04,28,21,25,46, "+02:00"),
                                         event_culture_name:   "en-US",
                                         know_user_secret_key: "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6",
                                         max_redirects_per_minute: 30,
                                         queue_number_validity_in_minutes: 15)
        end

        private

        def valid_create_body
          {
            "DisplayName"                  => "Fancy Event 2015",
            "RedirectUrl"                  => "https://example.com/en/events/fancy_event/tickets",
            "Description"                  => "Foo",
            "TimeZone"                     => "UTC",
            "PreQueueStartTime"            => "2015-04-28T14:25:46.0000000Z",
            "EventStartTime"               => "2015-04-28T15:25:46.0000000Z",
            "EventEndTime"                 => "2015-04-28T19:25:46.0000000Z",
            "EventCulture"                 => "en-US",
            "MaxRedirectsPerMinute"        => "15",
            "MaxNoOfRedirectsPrQueueId"    => "1",
            "QueueNumberValidityInMinutes" => "15",
            "AfterEventLogic"              => "RedirectUsersToTargetPage",
            "AfterEventRedirectPage"       => "",
            "UseSSL"                       => "Auto",
            "JavaScriptSupportEnabled"     => "False",
            "TargetUrlSupportEnabled"      => "False",
            "SafetyNetMode"                => "Disabled",
            "KnowUserSecurity"             => "MD5Hash",
            "KnowUserSecretKey"            => "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6",
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
      end
    end
  end
end
