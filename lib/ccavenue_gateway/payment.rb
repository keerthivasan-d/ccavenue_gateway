module CcavenueGateway
  class Payment < Entity
    def make_payment(order_id, amount, redirect_url)
      # Implement payment-specific logic if needed
      @client.make_payment(order_id, amount, redirect_url)
    end

    def handle_payment_response(params)
      # Implement payment-specific response handling if needed
      @client.handle_payment_response(params)
    end
  end
end