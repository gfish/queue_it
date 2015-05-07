require 'queue_it/api/event'
require 'queue_it/api/client'
require 'webmock'

module QueueIt
  module Api
    describe Event do
      let(:client)                   { double(:api_client) }
      let(:know_user_secret_key)     { "930f42ca-d9e7-4202-bff4-606e127b1c103980c131-cd8a-4e35-a945-50f7b5102ad6" }
      let(:event_id)                 { "fancyevent" }
      let(:display_name)             { "Fancy Event 2015" }
      let(:description)              { "Foo" }
      let(:redirect_url)             { "https://example.com/en/events/fancy_event/tickets" }
      let(:time_zone)                { "Europe/Copenhagen" }
      let(:event_culture_name)       { "en-US" }
      let(:max_redirects_per_minute) { 15 }
      let(:queue_number_validity_in_minutes) { 15 }

      subject(:event_adapter) { Event.new(client) }

      context "#create_or_update" do
        specify "Submits proper request" do
          expect(client).to receive(:put).with(event_id, valid_create_body).and_return(double(body:{}))

          event_adapter.create_or_update(event_id:                         event_id,
                                         display_name:                     display_name,
                                         description:                      description,
                                         redirect_url:                     redirect_url,
                                         start_time:                       Time.new(2015,04,28,17,25,46, "+02:00"),
                                         end_time:                         Time.new(2015,04,28,21,25,46, "+02:00"),
                                         event_culture_name:               event_culture_name,
                                         know_user_secret_key:             know_user_secret_key,
                                         max_redirects_per_minute:         max_redirects_per_minute,
                                         queue_number_validity_in_minutes: queue_number_validity_in_minutes)
        end

        specify "Minimum viable attributes for creating event" do
          body = valid_create_body.merge({
            "Description"       => "",
            "EventEndTime"      => "2016-04-27T21:25:46.0000000Z",
            "EventCulture"      => event_culture_name,
            "KnowUserSecretKey" => nil,
          })

          expect(client).to receive(:put).with(event_id, body).and_return(double(body:{}))

          event_adapter.create_or_update(event_id:             event_id,
                                         display_name:         display_name,
                                         redirect_url:         redirect_url,
                                         start_time:           Time.utc(2015,04,28,15,25,46),)
        end

        specify "Set custom time zone in the ruby way" do
          body = valid_create_body.merge({
            "TimeZone"  => "Romance Standard Time",
          })

          expect(client).to receive(:put).with(event_id, body).and_return(double(body:{}))

          event_adapter.create_or_update(event_id:                          event_id,
                                         display_name:                      display_name,
                                         description:                       description,
                                         redirect_url:                      redirect_url,
                                         start_time:                        Time.new(2015,04,28,17,25,46, "+02:00"),
                                         end_time:                          Time.new(2015,04,28,21,25,46, "+02:00"),
                                         know_user_secret_key:              know_user_secret_key,
                                         max_redirects_per_minute:          max_redirects_per_minute,
                                         queue_number_validity_in_minutes:  queue_number_validity_in_minutes,
                                         time_zone:                         time_zone,)
        end

        specify "Event id must have proper format" do
          invalid_event_id = "/fancyevent"

          expect do
            event_adapter.create_or_update(event_id:                          invalid_event_id,
                                           display_name:                      display_name,
                                           description:                       description,
                                           redirect_url:                      redirect_url,
                                           start_time:                        Time.new(2015,04,28,17,25,46, "+02:00"),
                                           end_time:                          Time.new(2015,04,28,21,25,46, "+02:00"),
                                           know_user_secret_key:              know_user_secret_key,
                                           max_redirects_per_minute:          max_redirects_per_minute,
                                           queue_number_validity_in_minutes:  queue_number_validity_in_minutes,
                                           time_zone:                         time_zone,)
          end.to raise_error(Event::InvalidEventIdFormat)
        end

        specify "Set custom number of redirects per minute" do
          body = valid_create_body.merge({ "MaxRedirectsPerMinute" => "30", })

          expect(client).to receive(:put).with(event_id, body).and_return(double(body:{}))

          event_adapter.create_or_update(event_id:                         event_id,
                                         display_name:                     display_name,
                                         description:                      description,
                                         redirect_url:                     redirect_url,
                                         start_time:                       Time.new(2015,04,28,17,25,46, "+02:00"),
                                         end_time:                         Time.new(2015,04,28,21,25,46, "+02:00"),
                                         event_culture_name:               event_culture_name,
                                         know_user_secret_key:             know_user_secret_key,
                                         max_redirects_per_minute:         30,
                                         queue_number_validity_in_minutes: queue_number_validity_in_minutes)
        end

        specify "Request hits proper endpoint" do
          client        = Client.new(api_key: "SECURE_KEY")
          event_adapter = Event.new(client)

          headers = {'Accept' =>'application/json', 'Content-Type' =>'application/json', 'Api-Key' =>'SECURE_KEY'}
          body    = JSON.generate(valid_create_body)

          stub_request(:put, "https://api2.queue-it.net/2_0_beta/event/fancyevent").with(body: body, headers: headers)

          event_adapter.create_or_update(event_id:                         event_id,
                                         display_name:                     display_name,
                                         description:                      description,
                                         redirect_url:                     redirect_url,
                                         start_time:                       Time.new(2015,04,28,17,25,46, "+02:00"),
                                         end_time:                         Time.new(2015,04,28,21,25,46, "+02:00"),
                                         event_culture_name:               event_culture_name,
                                         know_user_secret_key:             know_user_secret_key,
                                         max_redirects_per_minute:         max_redirects_per_minute,
                                         queue_number_validity_in_minutes: queue_number_validity_in_minutes)

        end

        private

        let(:valid_create_body) do
          {
            "DisplayName"                  => display_name,
            "RedirectUrl"                  => redirect_url,
            "Description"                  => description,
            "TimeZone"                     => "UTC",
            "PreQueueStartTime"            => "2015-04-28T14:25:46.0000000Z",
            "EventStartTime"               => "2015-04-28T15:25:46.0000000Z",
            "EventEndTime"                 => "2015-04-28T19:25:46.0000000Z",
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
      end
    end
  end
end
