class MakeSendActivity < Cadence::Activity
  class UnableToSend < Cadence::ActivityException; end

  task_list 'deposits'

  timeouts start_to_close: 2 * 60 # 2 minutes

  retry_policy(
    interval: 60,
    backoff: 2,
    expiration_interval: 5 * 60 # 5 minutes,
  )

  # Warning: this activity is not idempotent because the pro api does not allow us to pass
  # in an idempotency key
  def execute(amount, currency, crypto_address, destination_tag = nil)
    res = ProClient.send(amount, currency, crypto_address, destination_tag)
    raise UnableToSend, res[:body] if res[:status] != 200

    res
  end
end
