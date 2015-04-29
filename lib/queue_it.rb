require "queue_it/version"
require "queue_it/known_user_checker"
require "queue_it/api/client"
require "queue_it/api/event"

module QueueIt
  class NotAuthorized    < StandardError; end
  class MissingArgsGiven < StandardError; end
end

require "queue_it/queueable" if defined?(::Rails)
require "queue_it/railtie"   if defined?(::Rails)
