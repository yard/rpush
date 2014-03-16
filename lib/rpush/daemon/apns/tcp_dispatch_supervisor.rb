module Rpush
  module Daemon
    module Apns
      class TcpDispatchSupervisor
        include PubSubable
        include Loggable

        EVENTS = {
          Dispatcher::Tcp::TCP_DISPATCHED_EVENT => :dispatched,
          Dispatcher::Tcp::TCP_CONNECTION_CLOSED_EVENT => :connection_closed,
          Dispatcher::Tcp::TCP_CONNECTION_ESTABLISHED_EVENT => :connection_established
        }

        def start
          @error_supervisors = {}
          @subscribers = []
          setup_subscriptions
        end

        def stop
          @subscribers.each { |subscriber| unsubscribe(subscriber) }
          @thread.join if @thread
        end

        private

        def setup_subscriptions
          EVENTS.each do |name, method|
            subscriber = subscribe(name) do |event|
              log_debug("Received #{name} event: #{event.inspect}.")
              send(method, event)
            end
            @subscribers << subscriber
            log_debug("Subscribed to #{name} events.")
          end
        end

        def dispatched(event)
          app, notification = event.payload.values_at(:app, :notification)
          @error_supervisors[app][connection].dispatched(notification)
        end

        def connection_established(event)
          app, connection = event.payload.values_at(:app, :connection)
          @error_supervisors[app] ||= {}
          @error_supervisors[app][connection] ||= ErrorReceiver.new(app, connection)
        end

        def connection_closed(event)
          app, connection = event.payload.values_at(:app, :connection)
          @error_supervisors[app].delete(connection).stop
          @error_supervisors.delete(app) if @error_supervisors[app].empty?
        end
      end
    end
  end
end
