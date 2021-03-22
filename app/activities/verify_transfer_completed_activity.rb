class VerifyTransferCompletedActivity < Cadence::Activity
  class TransferPending < Cadence::ActivityException; end

  class TransferCanceled < Cadence::ActivityException; end

  class TransferDoesNotExist < Cadence::ActivityException; end

  class UnableToVerifyTransfer < Cadence::ActivityException; end

  task_list 'deposits'

  timeouts start_to_close: 2 * 60 # 2 minutes

  retry_policy(
    interval: 60,
    backoff: 2,
    max_interval: 60 * 60, # 1 hour
    expiration_interval: 20 * 60 * 60, # 20 hours since onchain sends can take a while depending on currency
    non_retriable_errors: [TransferCanceled, TransferDoesNotExist]
  )

  def execute(transfer_id)
    res = ProClient.get_transfer(transfer_id)
    verify_status(res[:status])

    transfer = res[:body]

    if transfer['completed_at'].nil? && transfer['canceled_at'].nil?
      # retry if transfer is pending
      raise TransferPending
    elsif transfer['completed_at']
      # nil for success
      nil
    elsif transfer['canceled_at']
      raise TransferCanceled, 'transfer canceled'
    end
  end

  private

  def verify_status(status)
    if [400, 404].include?(status)
      raise TransferDoesNotExist
    elsif status != 200
      raise UnableToVerifyTransfer
    end
  end
end
