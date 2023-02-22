### 4.0.0 - 2023-02-22

* Use `Same-Site: none` for cookies so that they work in iframes on third-party sites
* Bump bundler version to `~> 2`
* Bump ruby version to 3.1.3

### 3.0.1 - 2021-08-01

* Correctly delete cookies when a session is destroyed

### 3.0.0 - 2021-07-30

* Replace session store with cookie store to prevent some users of being kicked out of the queue

### 2.0.2 - 2021-07-21

* Defaults changed when creating/updating a queue: CustomLayout set to dark theme, MaxNoOfRedirectsPrQueueId to 3, QueueNumberValidityInMinutes to 30.
* UseSSL parameter is no longer sent since the use of https will be enforced.

### 2.0.1 - 2021-04-26

* Updated the queue and cancel URL from `q.queue-it.net` to `customer_id.queue-it.net`.
* Updated the queue URLs to use https.

### 2.0.0 - 2020-10-29

* A customer ID is needed to create a client instance
* Always include the Customer ID in the API request URL
* Bump webmock to properly handle Ruby 2.4+

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
