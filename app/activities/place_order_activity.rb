class PlaceOrderActivity < Cadence::Activity
  class UnableToPlaceOrder < Cadence::ActivityException; end

  task_list 'deposits'

  timeouts start_to_close: 2 * 60 # 2 minutes

  retry_policy(
    interval: 60,
    backoff: 2,
    max_interval: 5 * 60, # 5 minutes
    expiration_interval: 10 * 60, # 10 minutes,
    non_retriable_errors: [ArgumentError]
  )

  def execute(type, side, base_currency, quote_currency, **args)
      raise ArgumentError, "size or funds are required args" unless (args[:size].present? || args[:funds].present?)
      product_id = "#{base_currency}-#{quote_currency}"
      res = ProClient.order(type, side, product_id, client_iod: activity.idem, **args)
      raise UnableToPlaceOrder, res.body if res.status != 201
  end
end