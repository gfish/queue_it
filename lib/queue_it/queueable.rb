module QueueIt
  module Queueable
    extend ActiveSupport::Concern

    included do
      def queue_it_queue_id(event_id)
        session[queue_it_session_variable(event_id)]
      end

      def destroy_all_queue_it_sessions
        session_variable_prefix = queue_it_session_variable("")
        session.reject!{ |session_key| session_key.start_with?(session_variable_prefix) }
      end

      def destroy_queue_it_session(event_id)
        session.delete(queue_it_session_variable(event_id))
      end

      def create_or_verify_queue_it_session(secret_key, event_id, customer_id, request_url, params)
        # If there exists a session, we return. This needs to be refactored when we start to look at the timestamp parameter
        return if session[queue_it_session_variable(event_id)].present?

        begin
          user_checker                                 = QueueIt::KnownUserChecker.new(secret_key, event_id, customer_id)
          session[queue_it_session_variable(event_id)] = user_checker.create_or_verify_queue_it_session!(request_url, params)

          # If the request URL contains queue_it params we remove them and redirect
          # this is done to mask the params we use to create and verify the queue_it session
          if QueueIt::UrlBuilder.contains_queue_params?(request_url)
            redirect_to QueueIt::UrlBuilder.clean_url(request_url) and return
          end
        rescue QueueIt::MissingArgsGiven
          queue_url = QueueIt::UrlBuilder.build_queue_url(customer_id, event_id)
          render("queue_it/enter_queue", layout: false, locals: { queue_it_url: queue_url }) and return
        rescue QueueIt::NotAuthorized
          queue_cancel_url = QueueIt::UrlBuilder.build_cancel_url(customer_id, event_id)
          render("queue_it/cheating_queue", layout: false, locals: { queue_it_url: queue_cancel_url }) and return
        end

      end

      def queue_it_session_variable(event_id)
        "KnownQueueItUser-#{event_id}"
      end

    end

  end
end
