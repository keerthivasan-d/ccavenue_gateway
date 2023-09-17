module CcavenueGateway
  module AESCrypto
       
    INIT_VECTOR = (0..15).to_a.pack("C*")    

    def self.hash_to_query(hash)
      URI.encode_www_form(hash)
    end

    def self.query_to_hash_and_symbolize(query)
      URI.decode_www_form(query).to_h.symbolize_keys
    end
  
    def self.encrypt(plain_text, key)
        secret_key =  [Digest::MD5.hexdigest(key)].pack("H*") 
        cipher = aes_cipher
        cipher.encrypt
        cipher.key = secret_key
        cipher.iv  = INIT_VECTOR
        encrypted_text = cipher.update(plain_text) + cipher.final
        return (encrypted_text.unpack("H*")).first
    end
  
    def self.decrypt(cipher_text, key)
        secret_key =  [Digest::MD5.hexdigest(key)].pack("H*")
        encrypted_text = [cipher_text].pack("H*")
        decipher = aes_cipher
        decipher.decrypt
        decipher.key = secret_key
        decipher.iv  = INIT_VECTOR
        decrypted_text = (decipher.update(encrypted_text) + decipher.final).gsub(/\0+$/, '')
        return decrypted_text
    end

    private

    def self.aes_cipher
      OpenSSL::Cipher::Cipher.new('aes-128-cbc')
    end

  end
end
