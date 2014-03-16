module Rpush
  module Daemon
    module Dispatcher
      class Tcp
        include PubSubable

        TCP_DISPATCHED_EVENT = :tcp_dispatched
        TCP_CONNECTION_CLOSED_EVENT = :tcp_connection_closed
        TCP_CONNECTION_ESTABLISHED_EVENT = :tcp_connection_established

        def initialize(app, delivery_class, options = {})
          @app = app
          @delivery_class = delivery_class
          @host, @port = options[:host].call(@app)
        end

        def dispatch(notification, batch)
          @delivery_class.new(@app, connection, notification, batch).perform
          publish(TCP_DISPATCHED_EVENT, {app: @app, notification: notification})
        end

        def cleanup
          if @connection
            @connection.close
            publish(TCP_CONNECTION_CLOSED_EVENT, {app: @app, connection: @connection})
          end
        end

        protected

        def connection
          return @connection if defined? @connection
          connection = Rpush::Daemon::TcpConnection.new(@app, @host, @port)
          connection.connect
          publish(TCP_CONNECTION_ESTABLISHED_EVENT, {app: @app, connection: connection})
          @connection = connection
        end
      end
    end
  end
end
