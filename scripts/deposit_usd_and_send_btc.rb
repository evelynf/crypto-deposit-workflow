require_relative 'cadence_init'
require_relative '../app/crypto_deposit_workflow'
require_relative '../app/pro_client'

# Modify the below params for your case
payment_method_id = ProClient.get_payment_method_id_for('USD', 'ach_bank_account')

Cadence.start_workflow(CryptoDepositWorkflow,
                       crypto_currency: :BTC,
                       fiat_currency: :USD,
                       fiat_amount: 1000,
                       payment_method_id: payment_method_id,
                       crypto_address: '')
