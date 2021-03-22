class MakeDepositActivity < Cadence::Activity
  class UnableToDeposit < Cadence::ActivityException; end

  task_list 'deposits'

  timeouts start_to_close: 2 * 60 # 2 minutes

  retry_policy(
    interval: 60,
    backoff: 2,
    expiration_interval: 5 * 60 # 5 minutes,
  )

  # Warning: This activity is not idempotent because the pro api does not allow us to pass
  # in an idempotency key
  def execute(amount, currency, payment_method_id)
    res = ProClient.deposit(amount, currency, payment_method_id)
    raise UnableToDeposit, res[:body] if res[:status] != 200

    res
  end
end
