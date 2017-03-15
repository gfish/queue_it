### 1.1.6 - 2017-03-15

* Now by default, during creation event, we support using redirect urls
* Added possibility to pass redirect url for queue it

### 1.1.5 - 2016-06-02

* Remove warning about circular argument reference - api_key in Ruby 2.3.1

### 1.1.4 - 2016-04-06

* Solve gem publishing issue - no changes comparing to 1.1.3

### 1.1.3 - 2016-04-06

* do not rely on ActionDispatch::Resuest::Session API that was removed in Rails 4.2

### 1.1.2 - 2015-05-19

* More time zone mappings.
* Fixed discrepancy between 'Paris' and 'Europe/Paris'
  timezone mapping to Microsoft zones.

### 1.1.1 - 2015-05-11

* `QueueIt::Api::Event`
  * `#create_or_update` accepts `pre_queue_start_time`

### 1.1.0 - 2015-05-07

* Basic Api 2.0.beta integration
  * https://api2.queue-it.net
* `QueueIt::Api::Client`
  * Allows to perform request with `JSON` encoded data to proper endpoint
  * Debugging mode present
* `QueueIt::Api::Event`
    * Creates or updates queue with some basic setup which fits our current needs
    * Sets queue speed

### 1.0.0 - 2014-11-06

* Provides `#protect_with_queue!` method
  * renders page which allows to redirect users to Queue-It
  * handles KnowUserSecretKey verification
* Provides `#destroy_all_queue_it_sessions` method
  * clears queue which pushes client from queue after successful purchase
