require_relative 'activities/make_deposit_activity'
require_relative 'activities/make_send_activity'
require_relative 'activities/place_order_activity'

# Given a fiat amount, will buy crypto and send the funds over to the
# desired address. The crypto funds will have the trading fee and network fee
# deducted from them 
class CryptoDepositWorkflow < Cadence::Workflow

    def execute(crypto_currency:, fiat_currency:, fiat_amount:, payment_method_id:, crypto_address:, destination_tag: nil)
        deposit = MakeDepositActivity.execute!(fiat_amount, fiat_currency, payment_method_id)
        # # saga.add_compensation(MakeWithdrawalActivity, fiat_amount, fiat_currency, payment_method_id)
        
        # if !instant
        #     workflow.sleep_until(deposit['payout_at'])
        #     VerifyDepositCompletedActivity.execute(deposit['id'])
        # end
        
        crypto_amount = PlaceOrderActivity.execute!(:market, :buy, fiat_currency, crypto_currency, size: fiat_amount.to_d)
        # Sells enough crypto to cover the fiat amount deposited
        # If price of crypto drops, will sell more to cover it, otherwise will sell less crypto than originally purchased
        saga.add_compensation(PlaceOrderActivity, :market, :sell, crypto_currency, fiat_currency, funds: fiat_amount.to_d)
        
        # TODO Wait for Order activity

        MakeSendActivity.execute!(crypto_amount, crypto_address, destination_tag)        
        
        # TODO WaitForSendActivity - checks if send has completed
        
    end
end