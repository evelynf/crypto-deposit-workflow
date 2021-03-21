require 'rubygems'
require 'excon'

class ProClient
    API_PASSPHRASE = '3savwe1q6jb'
    API_SECRET = 'ILM07+vmnyRd1VxZX7M8lFfGBmFnxt+7M0PDgzbFxCcTKPk7IIAF13VMhPR/R5UC/bgG8glx4DKcNQjh5CicLA=='
    API_KEY = 'be8b73a90575271a4f89c52d04d4a2ae'

    def initialize(api_key = '', api_secret = '', api_pass = '', options = {})
        @api_url = "https://api-public.sandbox.pro.coinbase.com"
        @api_pass = API_PASSPHRASE
        @api_key = API_KEY
        @api_secret = API_SECRET
    end

   def place_order(type, side, product_id, **args)
    raise ArgumentError, "size or funds are required args" unless (args[:size] || args[:funds])
    
    params = {
        type: type,
        side: side,
        product_id: product_id,
        **args
    }

    post("/orders", params)
   end

   def deposit(amount, currency, payment_method_id)
    params = {
        amount: amount,
        currency: currency,
        payment_method_id: payment_method_id
    }    

    post("/deposits/payment-method", params)
   end

   def withdraw(amount, currency, payment_method_id)
    params = {
        amount: amount,
        currency: currency,
        payment_method_id: payment_method_id
    }    

    post("/withdrawals/payment-method", params)
   end

   def send(amount, currency, address, destination_tag: nil)
    params = {
        amount: amount,
        currency: currency,
        address: address,
        destination_tag: destination_tag
    }    

    post("/withdrawals/crypto", params)
   end

    def get(path)
        Excon.get(@api_url + path, :headers => headers('GET', path, ''))
    end

    def headers(method, path, body)
        timestamp = Time.now.utc.to_i.to_s
        key = Base64.decode64(API_SECRET)
        hmac = OpenSSL::HMAC.digest('sha256', key, "#{timestamp}#{method}#{path}#{body}".strip)       
        signature = Base64.encode64(hmac).strip
        
        {
            'CB-ACCESS-KEY': API_KEY,
            'CB-ACCESS-SIGN': signature,
            'CB-ACCESS-PASSPHRASE': API_PASSPHRASE, 
            'CB-ACCESS-TIMESTAMP': timestamp,
            'Content-Type': 'application/json',
            'USER-AGENT': 'api-test'
         }
    end
end