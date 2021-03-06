require 'rubygems'
require 'excon'
require 'json'
require 'base64'

module ProClient
  class BadRequestError < StandardError; end
  class << self
    API_PASSPHRASE = ''
    API_SECRET = ''
    API_KEY = ''
    API_URL = 'https://api-public.sandbox.pro.coinbase.com'

    def place_order(type, side, product_id, args = {})
      params = {
        type: type,
        side: side,
        product_id: product_id
      }.merge(args)

      post('/orders', params)
    end

    def deposit(amount, currency, payment_method_id)
      params = {
        amount: amount,
        currency: currency,
        payment_method_id: payment_method_id
      }

      post('/deposits/payment-method', params)
    end

    def withdraw(amount, currency, payment_method_id)
      params = {
        amount: amount,
        currency: currency,
        payment_method_id: payment_method_id
      }

      post('/withdrawals/payment-method', params)
    end

    def send(amount, currency, address, destination_tag = nil)
      params = {
        amount: amount,
        currency: currency,
        crypto_address: address,
        destination_tag: destination_tag
      }

      post('/withdrawals/crypto', params)
    end

    def get_transfer(transfer_id)
      get("/transfers/#{transfer_id}")
    end

    def get_order(order_id)
      get("/orders/#{order_id}")
    end

    def get_payment_method_id_for(currency, type)
      res = get('/payment-methods')
      raise BadRequestError, res[:body] if res[:status] != 200

      payment_methods = res[:body]

      payment_methods.each do |payment_method|
        # Simplify and assume only one payment method per type and currency
        return payment_method['id'] if payment_method['type'] == type && payment_method['currency'] == currency
      end

      nil
    end

    private

    def post(path, params)
      body = JSON.generate(params)
      res = Excon.post(API_URL + path, body: body, headers: headers('POST', path, body))
      response(res)
    end

    def get(path)
      res = Excon.get(API_URL + path, headers: headers('GET', path, ''))
      response(res)
    end

    # TODO: move this into its own class
    def response(res)
      object = {}
      object[:status] = res.status
      object[:body] = JSON.parse(res.body)
      object
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
end
