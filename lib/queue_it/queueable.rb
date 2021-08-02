require 'queue_it/url_builder'

module QueueIt
  module Queueable
    extend ActiveSupport::Concern

    included do
      def protect_with_queue!(known_user_secret_key, event_id, customer_id, redirect_url: nil)
        create_or_verify_queue_it_session(known_user_secret_key,
                                          event_id,
                                          customer_id,
                                          request.original_url,
                                          params,
                                          redirect_url)
      end

      def queue_it_queue_id(event_id)
        cookies.signed[queue_it_session_variable(event_id)].to_i
      end

      def destroy_all_queue_it_sessions
        session_variable_prefix = queue_it_session_variable("")
        cookies.each do |key, _|
          cookies.delete(key) if key.starts_with?(session_variable_prefix)
        end
      end

      def destroy_queue_it_session(event_id)
        cookies.delete(queue_it_session_variable(event_id))
      end

      def queue_it_session_variable(event_id)
        "KnownQueueItUser-#{event_id}"
      end

    private

      def create_or_verify_queue_it_session(secret_key, event_id, customer_id, request_url, params, current_tickets_url)
        # If there exists a session, we return. This needs to be refactored when we start to look at the timestamp parameter
        return if cookies.signed[queue_it_session_variable(event_id)].present?

        begin
          queue_number = QueueIt::ExtractQueueNumber.new.(
            secret_key: secret_key,
            request_url: request_url,
            request_params: params)
          cookies.signed[queue_it_session_variable(event_id)] = { value: queue_number, expires: 24.hours.from_now }

          # If the request URL contains queue_it params we remove them and redirect
          # this is done to mask the params we use to create and verify the queue_it session
          if QueueIt::UrlBuilder.contains_queue_params?(request_url)
            redirect_to QueueIt::UrlBuilder.clean_url(request_url) and return
          end
        rescue QueueIt::MissingArgsGiven
          queue_url = QueueIt::UrlBuilder.build_queue_url(customer_id, event_id, current_tickets_url)
          destroy_all_queue_it_sessions
          render("queue_it/enter_queue", layout: false, locals: { queue_it_url: queue_url }) and return
        rescue QueueIt::NotAuthorized
          queue_cancel_url = QueueIt::UrlBuilder.build_cancel_url(customer_id, event_id)
          destroy_all_queue_it_sessions
          render("queue_it/cheating_queue", layout: false, locals: { queue_it_url: queue_cancel_url }) and return
        end
      end
    end
  end
end
