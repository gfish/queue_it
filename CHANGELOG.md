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
