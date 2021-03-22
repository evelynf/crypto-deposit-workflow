# Crypto Deposit Workflow README

This project attempts to automate the manual process for users who need to convert fiat into crypto and then send it over to an address. The workflow will deposit fiat into your Coinbase Pro account, trade it for the desired crypto and send it to the given address. If the workflow fails along the way, it will rollback it's actions by selling the crypto, and withdrawing it to the original payment method. 

# How to run
1. Install Cadence locally, by following the directions here https://github.com/coinbase/cadence-ruby
2. Create an API key on pro.coinbase.com with trade, transfer and view permissions
3. Fill in the API variables in app/pro_client.rb and the desired params in scripts/deposit_usd_and_send_btc.rb
4. In this order, run scripts/cadence_init.rb, scripts/cadence_workers.rb, and scripts/deposit_usd_and_send_btc.rb


# IMPORTANT
The workflow *should* be idempotent. However, due to the fact that making a deposit and a withdrawal is not idempotent in Pro (Pro does not allow clients to pass in an idempotency key), this workflow is not. Therefore, you should not actually run it on real funds since it is no longer deterministic. Please test this with Pro sandbox: https://public.sandbox.pro.coinbase.com/


Example where the workflow fails to make an order and so it rolls back and withdraws the fiat to the original payment method:
<img width="1774" alt="Screen Shot 2021-03-21 at 10 14 47 PM" src="https://user-images.githubusercontent.com/64184523/111939820-e2cee400-8a92-11eb-8b5c-2d4928115765.png">

Example of successful workflow:
<img width="1783" alt="Screen Shot 2021-03-22 at 10 11 29 AM" src="https://user-images.githubusercontent.com/64184523/112021605-14799680-8af7-11eb-9f53-8996d786b43d.png">



