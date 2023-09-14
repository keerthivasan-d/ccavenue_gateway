require 'httparty'

module CcavenueGateway
  class Client
    include HTTParty
    base_uri 'https://secure.ccavenue.com/transaction'

    def initialize(configuration)
      @merchant_id = configuration.merchant_id
      @access_code = configuration.access_code
      @working_key = configuration.working_key
    end

    def make_payment(order_id, amount, redirect_url)
      puts "payment make success"
      puts @merchant_id
    end

    def handle_payment_response(params)
      # Implement client-specific response handling logic
    end

    def payment
      @payment ||= Payment.new(self)
    end

    def subscription
      @subscription ||= Subscription.new(self)
    end
  end
end