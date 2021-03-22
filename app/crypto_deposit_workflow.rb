require 'cadence/saga/concern'
require_relative 'activities/make_deposit_activity'
require_relative 'activities/make_send_activity'
require_relative 'activities/make_withdrawal_activity'
require_relative 'activities/place_order_activity'
require_relative 'activities/verify_market_order_completed_activity'
require_relative 'activities/verify_transfer_completed_activity'

# Given a fiat amount, will buy crypto and send the funds over to the
# desired address. The crypto funds will have the trading fee and network fee
# deducted from them
class CryptoDepositWorkflow < Cadence::Workflow
  include Cadence::Saga::Concern

  task_list 'deposits'

  timeouts execution: 12 * 60 * 60 # 12 hours. If not instant deposit, add a few days

  def execute(crypto_currency:, fiat_currency:, fiat_amount:, payment_method_id:, crypto_address:, destination_tag: nil, instant_deposit: true)
    run_saga do |saga|
      deposit = MakeDepositActivity.execute!(fiat_amount, fiat_currency, payment_method_id)
      saga.add_compensation(MakeWithdrawalActivity, fiat_amount, fiat_currency, payment_method_id)

      # Assumes deposit is instant since Coinbase Pro does not return whether it is or not
      # Pass in a flag if you do not have instant deposits
      unless instant_deposit
        workflow.sleep_until(deposit['payout_at'])
        VerifyTransferCompletedActivity.execute!(deposit['id'])
      end

      order = PlaceOrderActivity.execute!(:market, :buy, fiat_currency, crypto_currency, funds: fiat_amount)
      # Sells enough crypto to cover the fiat amount deposited
      # If price of crypto drops, will sell more to cover it, otherwise will sell less crypto than originally purchased
      saga.add_compensation(PlaceOrderActivity, :market, :sell, fiat_currency, crypto_currency, size: fiat_amount)
      VerifyMarketOrderCompletedActivity.execute!(order['id'])

      send = MakeSendActivity.execute!(crypto_amount, crypto_address, destination_tag)
      VerifyTransferCompletedActivity.execute!(send['id'])
    end
  end
end
