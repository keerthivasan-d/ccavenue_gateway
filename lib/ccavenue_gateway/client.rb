require 'httparty'

module CcavenueGateway
  class Client
    include HTTParty
    include Env
    include AESCrypto

    base_uri 'https://apitest.ccavenue.com/apis/servlet/DoWebTrans'

    def initialize(configuration)
      @merchant_id = configuration.merchant_id
      @access_code = find_value_by_name(:ccavenue_gateway, :api_access_code)
      @working_key = find_value_by_name(:ccavenue_gateway, :api_working_key)
    end

    def payment_status(tracking_id, order_no)
      data = {
        reference_no: tracking_id.to_s,
        order_no: order_no.to_s
      }.to_json.to_s

      enc_request = AESCrypto.encrypt(data, @working_key)

      payload = {
        enc_request: enc_request,
        access_code: @access_code,
        command: 'orderStatusTracker',
        request_type: 'JSON',
        response_type: 'JSON',
        version:'1.2'
      }

      decrypted_response(payload)
    end

    private

    def decrypted_response(payload)
      response = nil
      response = send_request(payload)
      decrypt_response(response)
    end

    def send_request(payload = {})
      api_url = "https://apitest.ccavenue.com/apis/servlet/DoWebTrans"
      response = HTTParty.post(api_url, body: payload)
    end

    def decrypt_response(response)
      params_s = response.body.to_s
      puts params_s.inspect
      params = Rack::Utils.parse_query(params_s)
      if params[:status].to_s == '0'
        enc_response = params['enc_response'].gsub('\r\n', '').strip
        json_params = ActiveSupport::JSON.decode(AESCrypto.decrypt(enc_response, @working_key))
        Payment.new(json_params)
      else
        Payment.new({status: :failed}.merge(params))
      end
    end
    
  end
end