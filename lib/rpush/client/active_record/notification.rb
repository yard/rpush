require 'rpush/daemon/store/active_record/reconnectable'

module Rpush
  module Client
    module ActiveRecord
      class Notification < ::ActiveRecord::Base
        include Rpush::MultiJsonHelper
        include Rpush::Client::ActiveModel::Notification
        include Rpush::Daemon::Store::ActiveRecord::Reconnectable

        self.table_name = 'rpush_notifications'

        # TODO: Dump using multi json.
        serialize :registration_ids

        belongs_to :app, class_name: 'Rpush::Client::ActiveRecord::App'

        if Rpush.attr_accessible_available?
          attr_accessible :badge, :device_token, :sound, :alert, :data, :expiry, :delivered,
                          :delivered_at, :failed, :failed_at, :error_code, :error_description, :deliver_after,
                          :alert_is_json, :app, :app_id, :collapse_key, :delay_while_idle, :registration_ids, :uri
        end

        def data=(attrs)
          return unless attrs
          fail ArgumentError, "must be a Hash" unless attrs.is_a?(Hash)
          write_attribute(:data, multi_json_dump(attrs.merge(data || {})))
        end

        def registration_ids=(ids)
          ids = [ids] if ids && !ids.is_a?(Array)
          super
        end

        def data
          multi_json_load(read_attribute(:data)) if read_attribute(:data)
        end

        #  Marks notification as delivered due to error
        #
        #  <tt><code/tt>  Code error occured during delivery
        #  <tt><description/tt>  Error description
        #
        def mark_delivered
          with_database_reconnect_and_retry do
            self.delivered = true
            self.delivered_at = Time.now
            self.save!(:validate => false)
          end
        end
  
        #  Marks notification as failed due to error
        #
        #  <tt><code/tt>  Code error occured during delivery
        #  <tt><description/tt>  Error description
        #
        def mark_failed(code, description)
          with_database_reconnect_and_retry do
            self.delivered = false
            self.delivered_at = nil
            self.failed = true
            self.failed_at = Time.now
            self.error_code = code
            self.error_description = description
            self.save!(:validate => false)
          end
        end

      end
    end
  end
end
