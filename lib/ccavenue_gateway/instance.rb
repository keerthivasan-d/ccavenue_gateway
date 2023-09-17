require 'uri'

module CcavenueGateway
  class Instance
    include AESCrypto

    attr_accessor :config
    def initialize(tenant_id)
      @config = Configuration.new(tenant_id)
    end

    def access_code
      @config.access_code
    end

    def merchant_id
      @config.merchant_id
    end

    def request_url
      if @config.mode.upcase == 'TEST'
        "https://test.ccavenue.com/transaction/transaction.do?command=initiateTransaction"
      elsif @config.mode.upcase == 'LIVE'
        "https://secure.ccavenue.com/transaction/transaction.do?command=initiateTransaction"
      end
    end

    def client
      @client = Client.new(@config)
    end

    def encrypt_hash_to_query(hash)
      query_string = AESCrypto.hash_to_query(hash.merge!({ merchant_id: @config.merchant_id }))
      AESCrypto.encrypt(query_string, @config.working_key)
    end

    def decrypt_to_hash(cipher_text)
      query = AESCrypto.decrypt(cipher_text, @config.working_key)
      AESCrypto.query_to_hash_and_symbolize(query)
    rescue OpenSSL::Cipher::CipherError
      raise CcavenueGateway::SignatureVerificationFailureError
    end

  end
end