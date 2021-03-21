class PlaceOrderActivity < Cadence::Activity
    def execute(type, side, base_currency, quote_currency, **args)
      raise ArgumentError, "size or funds are required args" unless (args[:size].present? || args[:funds].present?)
      product_id = "#{base_currency}-#{quote_currency}"
      ProClient.order(type, side, product_id, client_iod: activity.idem, **args )
      return
    end
end