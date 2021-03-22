require 'cadence'
require 'cadence/worker'

require_relative '../app/crypto_deposit_workflow'
require_relative '../app/activities/make_deposit_activity'
require_relative '../app/activities/make_send_activity'
require_relative '../app/activities/make_withdrawal_activity'
require_relative '../app/activities/place_order_activity'
require_relative '../app/activities/verify_market_order_completed_activity'
require_relative '../app/activities/verify_transfer_completed_activity'

Cadence.configure do |config|
    config.host = 'localhost'
    config.port = 6666 # this should point to the tchannel proxy
    config.domain = 'deposits'
    config.task_list = 'deposits'
end

Cadence.register_domain('deposits', 'Running crypto deposit workflows')

  
worker = Cadence::Worker.new
worker.register_workflow(CryptoDepositWorkflow)
worker.register_activity(MakeDepositActivity)
worker.register_activity(MakeWithdrawalActivity)
worker.register_activity(MakeSendActivity)
worker.register_activity(PlaceOrderActivity)
worker.register_activity(VerifyMarketOrderCompletedActivity)
worker.register_activity(VerifyTransferCompletedActivity)
worker.start

