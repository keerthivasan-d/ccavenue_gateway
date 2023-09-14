require 'uri'

module CcavenueGateway
  class Instance
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

    def payment
      client = Client.new(@config)
      @payment ||= Payment.new(client)
    end

    def encrypt_hash_to_query(hash)
      query_string = hash_to_query(hash.merge!({ merchant_id: @config.merchant_id }))
      encrypt(query_string)
    end

    def decrypt_data(cipher_text)
      query = decrypt(cipher_text)
      URI.decode_www_form(query).to_h.symbolize_keys
    rescue OpenSSL::Cipher::CipherError
      raise CcavenueGateway::SignatureVerificationFailureError
    end

    private

    def hash_to_query(hash)
      URI.encode_www_form(hash)
    end

    INIT_VECTOR = (0..15).to_a.pack("C*")    
  
    def encrypt(plain_text)
        secret_key =  [Digest::MD5.hexdigest(@config.working_key)].pack("H*") 
        cipher = OpenSSL::Cipher::Cipher.new('aes-128-cbc')
        cipher.encrypt
        cipher.key = secret_key
        cipher.iv  = INIT_VECTOR
        encrypted_text = cipher.update(plain_text) + cipher.final
        return (encrypted_text.unpack("H*")).first
    end
  
    def decrypt(cipher_text)
        secret_key =  [Digest::MD5.hexdigest(@config.working_key)].pack("H*")
        encrypted_text = [cipher_text].pack("H*")
        decipher = OpenSSL::Cipher::Cipher.new('aes-128-cbc')
        decipher.decrypt
        decipher.key = secret_key
        decipher.iv  = INIT_VECTOR
        decrypted_text = (decipher.update(encrypted_text) + decipher.final).gsub(/\0+$/, '')
        return decrypted_text
    end

  end
end