# Given a fiat amount, will buy crypto and send the funds over to the
# desired address. The crypto funds will have the trading fee and network fee
# deducted from them 

class CryptoDepositWorkflow < Cadence::Workflow

    def execute(crypto_currency, fiat_currency, fiat_amount, payment_method_id, crypto_address, destination_tag)
        MakeDepositActivity.execute!(fiat_amount, fiat_currency, payment_method_id)
        # Rely on coinbase instant deposits so you can send quickly afterwards
        # Better idea would be if Pro api changes and can stream when deposit has finished
        # Depending on the hedging, this could be more or less if price changes within seconds
        saga.add_compensation(MakeWithdrawalActivity, fiat_amount, fiat_currency, payment_method_id)
        
        # TODO WaitForDepositActivity
        # If not using instant, can check wait for deposit activity, has a timeout for pay outdate and then checks to see if deposit is completed
        
        crypto_amount = PlaceOrderActivity.execute!(:market, :buy, fiat_currency, crypto_currency, size: crypto_amount.to_d)
        # This sells the original fiat amount deposited. Could either make money,
        # but it will not withdraw more than what was originally deposited
        saga.add_compensation(PlaceOrderActivity, :market, :sell, crypto_currency, fiat_currency, funds: fiat_amount.to_d)
        
        # Crypto amount includes the fee amount. 
        MakeSendActivity.execute!(crypto_amount, crypto_address, destination_tag)        
        # TODO WaitForSendActivity - checks if send has completed
        
    end

    sig do
        params(
        crypto_currency: Symbol,
        fiat_currency: Symbol,
        fiat_amount: Integer,
        payment_method_id: String
        ).void
    end
    def execute(crypto_amount, fiat_currency, payment_method_id)
        fiat_amount = GetQuoteActivity.execute!(crypto_amount.to_d, crypto_amount.currency, fiat_currency)
        # GetQuoteActivity would include the network fee as well. 
        MakeDepositActivity.execute!(fiat_amount, fiat_currency, payment_method_id)
        # Rely on coinbase instant deposits so you can send quickly afterwards
        # Better idea would be if Pro api changes and can stream when deposit has finished
        # Depending on the hedging, this could be more or less if price changes within seconds
        saga.add_compensation(MakeWithdrawalActivity, fiat_amount, fiat_currency, payment_method_id)
        
        # TODO WaitForDepositActivity
        # If not using instant, can check wait for deposit activity, has a timeout for pay outdate and then checks to see if deposit is completed
        
        PlaceOrderActivity(:market, :buy, fiat_currency, crypto_amount.currency, crypto_amount.to_d)
        # idem: client_oid
        saga.add_compensation(PlaceOrderActivity, :market, :sell, crypto_amount.currency, fiat_currency, fiat_amount.to_d)
        # MakeSendActivity        
        # TODO WaitForSendActivity - checks if send has completed
        
    end


    # TODO
    # Input desired_amount base_currency, quote currency
    # Returns cost in base currency, including network fees, trading, conversion etc.
    # Approve? y/n
    # Y starts workflow
end