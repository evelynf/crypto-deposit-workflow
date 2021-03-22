class PlaceOrderActivity < Cadence::Activity
  class UnableToPlaceOrder < Cadence::ActivityException; end
  class InsufficientFunds < Cadence::ActivityException; end
  class ProductNotFound < Cadence::ActivityException; end

  task_list 'deposits'

  timeouts start_to_close: 2 * 60 # 2 minutes

  retry_policy(
    interval: 60,
    backoff: 2,
    expiration_interval: 5 * 60, # 5 minutes,
    non_retriable_errors: [ArgumentError, InsufficientFunds, ProductNotFound]
  )

  def execute(type, side, base_currency, quote_currency, **args)
    raise ArgumentError, 'size or funds are required args' unless args[:size] || args[:funds]

    product_id = "#{base_currency}-#{quote_currency}"
    res = ProClient.place_order(type, side, product_id, client_oid: activity.idem, **args)
    verify_response(res)

    res[:body]
  end

  private
  
  def verify_response(res)
    return if res[:status] == 200
    if res[:body] == 'Insufficient Funds'
      raise InsufficientFunds
    elsif res[:body] == 'Product not found'
      raise ProductNotFound
    end 

    raise UnableToPlaceOrder, res[:body]
  end
end
