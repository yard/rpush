module Rpush
  module Daemon
    module Apns
      class Delivery < Rpush::Daemon::Delivery
        def initialize(app, conneciton, notification, batch)
          @app = app
          @connection = conneciton
          @notification = notification
          @batch = batch
        end

        def perform
          @connection.write(@notification.to_binary)
          mark_delivered
          log_info("#{@notification.id} sent to #{@notification.device_token}")
        end
      end
    end
  end
end
