# QueueIt

This is a gem for integrating Ruby on Rails with Queue-it that is an online queuing system, https://queue-it.com/

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'queue_it'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install queue_it
```

## Usage

We are using Queue-it on http://billetto.co.uk, and we create our queued events like this:

```ruby
event  = create(:event,
                :queue_it_enabled               => true,
                :queue_it_customer_id           => 'billettodk',
                :queue_it_event_id              => 'rainmaking',
                :queue_it_known_user_secret_key => 'asdfbmnwqeklrj'
               )
```

In our Event-model, we determine whether or not its queue-enabled:

```ruby
class Event < ActiveRecord::Base
  def queue_enabled?
    queue_it_enabled? &&
    queue_it_customer_id.present? &&
    queue_it_event_id.present? &&
    queue_it_known_user_secret_key.present?
  end
end
```

For us, our precious actions are all about tickets, so we protect these actions like this:

```ruby
class EventsController < ApplicationController
  include QueueIt::Queueable

  def tickets
    event = Event.find(params[:id])

    if event.queue_enabled?
      protect_with_queue!(event.queue_it_known_user_secret_key,
                          event.queue_it_event_id,
                          event.queue_it_customer_id)
      # We use performed to see if our queue protection have rendered something,
      # if it has rendered stop all other execution
      return if performed?
    end
  end

  def receipt
    # The user has bought his/her tickets, push them out of the queue
    destroy_all_queue_it_sessions
  end
end
```

### API
#### Client

Initialize client to pass it as a dependency to `Event` instance.

``` ruby
client = QueueIt::Api::Client.new(api_key: "SECRET_API_KEY")
```

#### Event
##### #create_or_update
Handles: https://api2.queue-it.net/Help/Api/PUT-2_0_beta-event-eventId

Basic usage
``` ruby
event = QueueIt::Api::Event.new(client)

event.create_or_update(event_id:     'justatestevent',
                       display_name: "Test event",
                       start_time:   Time.now,
                       redirect_url: 'https://example.com/en/events/not-so-fancy-event/tickets')
# produces
{
  "QueueUrl"=>"http://justatestevent-examplecom.queue-it.net/?c=examplecom&e=justatestevent",
  "EventId"=>"justatestevent",
  "PreQueueStartLocalTime"=>"2015-05-07T13:29:00.0000000Z",
  "EventStartLocalTime"=>"2015-05-07T14:29:00.0000000Z",
  "EventEndLocalTime"=>"2016-05-06T19:29:00.0000000Z",
  "QueueStatus"=>"Running",
  "LastPassedAutoTestRun"=>"",
  "DisplayName"=>"Test event",
  "RedirectUrl"=>"https://example.com/en/events/not-so-fancy-event/tickets",
  "Description"=>"",
  "TimeZone"=>"UTC",
  "PreQueueStartTime"=>"2015-05-07T13:29:00.0000000Z",
  "EventStartTime"=>"2015-05-07T14:29:00.0000000Z",
  "EventEndTime"=>"2016-05-06T20:29:00.0000000Z",
  "EventCulture"=>"en-US",
  "MaxNoOfRedirectsPrQueueId"=>"1",
  "QueueNumberValidityInMinutes"=>"15",
  "AfterEventLogic"=>"RedirectUsersToTargetPage",
  "AfterEventRedirectPage"=>"",
  "UseSSL"=>"Auto",
  "JavaScriptSupportEnabled"=>"False",
  "TargetUrlSupportEnabled"=>"False",
  "SafetyNetMode"=>"Disabled",
  "KnowUserSecurity"=>"MD5Hash",
  "KnowUserSecretKey"=>"SECRET",
  "CustomLayout"=>"Default layout by Queue-it",
  "XUsersInFrontOfYou"=>"0",
  "TargetUrlValidationRegex"=>"",
  "DomainAlias"=>"justatestevent-examplecom.queue-it.net",
  "AllowedCustomLayouts"=>[],
  "BrowserCultureEnabled"=>"True",
  "IdleQueueLogic"=>"UseBeforePage",
  "IdleQueueRedirectPage"=>""
}
```

Available named attributes
``` ruby
event_id:
display_name:
start_time:
end_time:
know_user_secret_key:
redirect_url:
description:
max_redirects_per_minute:
event_culture_name:
time_zone:
queue_number_validity_in_minutes:
```

##### #set_speed

Set redirect speed on an event queue.

See: https://api2.queue-it.net/Help/Api/PUT-2_0_beta-event-eventId-queue-speed

``` ruby
event = QueueIt::Api::Event.new(client)

event.set_speed(event_id: "justatestevent", max_redirects_per_minute: 15)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
