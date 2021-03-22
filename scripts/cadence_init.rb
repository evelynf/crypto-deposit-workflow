require 'cadence'

Cadence.configure do |config|
  config.host = 'localhost'
  config.port = 6666 # this should point to the tchannel proxy
  config.domain = 'deposits'
  config.task_list = 'deposits'
end

Cadence.register_domain('deposits', 'Running crypto deposit workflows')
