require "queue_it/version"
require "queue_it/known_user_checker"

module QueueIt
  class NotAuthorized    < StandardError; end
  class MissingArgsGiven < StandardError; end
end
