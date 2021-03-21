require 'coinbase/exchange'

class ProClient
    API_PASSPHRASE = '3savwe1q6jb'
    API_SECRET = 'ILM07+vmnyRd1VxZX7M8lFfGBmFnxt+7M0PDgzbFxCcTKPk7IIAF13VMhPR/R5UC/bgG8glx4DKcNQjh5CicLA=='
    API_KEY = 'be8b73a90575271a4f89c52d04d4a2ae'

    def initialize#(api_key='', api_secret='', api_pass='')
        # TODO change this
        @client = Coinbase::Exchange::Client.new(API_KEY, API_SECRET, API_PASSPHRASE, api_url: "http://api-public.sandbox.pro.coinbase.com")
    end

    def order(type, side, product_id, **args)
        raise ArgumentError, "size or funds are required args" unless (args[:size] || args[:funds])
        
        params = {
            type: type,
            side: side,
            product_id: product_id,
            **args
        }
        
        client.order(params)
    end

    def deposit(account_id, amount, currency)
        raise ArgumentError, "size or funds are required args" unless (args[:size] || args[:funds])
        
        params = {
            type: type,
            side: side,
            product_id: product_id,
            **args
        }
        
        client.order(params)
    end

    private 
    attr_reader :client
end