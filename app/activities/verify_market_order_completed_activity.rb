class VerifyMarketOrderCompletedActivity < Cadence::Activity
  class OrderPending < Cadence::ActivityException; end

  class OrderCanceled < Cadence::ActivityException; end

  class OrderDoesNotExist < Cadence::ActivityException; end

  class UnableToVerifyOrder < Cadence::ActivityException; end

  task_list 'deposits'

  timeouts start_to_close: 2 * 60 # 2 minutes

  retry_policy(
    interval: 60,
    backoff: 2,
    max_interval: 60 * 60, # 1 hour
    expiration_interval: 20 * 60 * 60, # 1 hour
    non_retriable_errors: [OrderCanceled, OrderDoesNotExist]
  )

  def execute(order_id)
    res = ProClient.get_order(order_id)
    verify_status(res[:status])

    order = res[:body]
    status = order['status']

    if status == 'pending'
      # retry if order is pending
      raise OrderPending
    elsif status == 'done' && order['done_reason'] == 'filled'
      return order
    elsif status == 'done' && order['done_reason'] == 'canceled'
      raise OrderCanceled
    end
  end

  private

  def verify_status(status)
    if [400, 404].include?(status)
      raise OrderDoesNotExist
    elsif status != 200
      raise UnableToVerifyOrder
    end
  end
end
