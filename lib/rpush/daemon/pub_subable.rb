module Rpush
  module Daemon
    module PubSubable
      def publish(name, *args)
        ActiveSupport::Notifications.publish(name, *args)
      end

      def subscribe(name, *args, &blk)
        ActiveSupport::Notifications.subscribe(name, *args) do
          event = ActiveSupport::Notifications::Event.new(*args)
          blk.call(event)
        end
      end

      def unsubscribe(subscriber)
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end
    end
  end
end
