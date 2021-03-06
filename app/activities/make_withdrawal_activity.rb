class MakeWithdrawalActivity < Cadence::Activity
  class UnableToWithdraw < Cadence::ActivityException; end

  task_list 'deposits'

  timeouts start_to_close: 2 * 60 # 2 minutes

  retry_policy(
    interval: 60,
    backoff: 2,
    max_interval: 5 * 60, # 5 minutes
    expiration_interval: 10 * 60 # 10 minutes,
  )

  # Warning: this activity is not idempotent because the pro api does not allow us to pass
  # in an idempotency key
  def execute(amount, currency, payment_method_id)
    res = ProClient.withdraw(amount, currency, payment_method_id)
    raise UnableToWithdraw, res[:body] if res[:status] != 200

    res[:body]
  end
end
