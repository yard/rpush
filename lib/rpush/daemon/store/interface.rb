module Rpush
  module Daemon
    module Store
      class Interface
        PUBLIC_METHODS = [:deliverable_notifications, :mark_retryable,
                          :mark_batch_retryable, :mark_delivered, :mark_batch_delivered,
                          :mark_failed, :mark_batch_failed, :create_apns_feedback,
                          :create_gcm_notification, :create_adm_notification, :update_app,
                          :update_notification, :after_daemonize, :release_connection]

        def self.check(klass)
          missing = PUBLIC_METHODS - klass.instance_methods.map(&:to_sym)
          fail "#{klass} must implement #{missing.join(', ')}." if missing.any?
        end
      end
    end
  end
end
