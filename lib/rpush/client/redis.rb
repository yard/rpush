begin
  require 'modis'
rescue LoadError
  puts
  str = "* Please add Modis (github.com/ileitch/modis) to your Gemfile to use the Redis client. *"
  puts "*" * str.size
  puts str
  puts "*" * str.size
  puts
end

require 'redis'

require 'rpush/client/active_model'

require 'rpush/client/redis/app'
require 'rpush/client/redis/notification'

require 'rpush/client/redis/apns/app'
require 'rpush/client/redis/apns/notification'
require 'rpush/client/redis/apns/feedback'

require 'rpush/client/redis/gcm/app'
require 'rpush/client/redis/gcm/notification'

require 'rpush/client/redis/adm/app'
require 'rpush/client/redis/adm/notification'

require 'rpush/client/redis/wpns/app'
require 'rpush/client/redis/wpns/notification'

Modis.configure do |config|
  config.namespace = :rpush
end
