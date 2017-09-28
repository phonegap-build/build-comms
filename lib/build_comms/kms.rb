module BuildComms
  class KMS
    class << self

      def client
        @client || @client = Aws::KMS::Client.new
      end

      def get_key key, context=nil
        opts = {
          :key_id => "alias/#{key}",
          :key_spec => "AES_256"
        }

        if !context.nil?
          opts[:encryption_context] = to_hash(context)
        end

        response = client.generate_data_key(opts)
        { :enc_key => Base64.strict_encode64(response.ciphertext_blob), :key => response.plaintext }
      end

      def encrypt key, data, context=nil
        opts = {
          :key_id => "alias/#{key}",
          :plaintext => data
        }
        
        if !context.nil?
          opts[:encryption_context] = to_hash(context)
        end

        Base64.strict_encode64(client.encrypt(opts).ciphertext_blob)
      end

      def decrypt data, context=nil
        opts = { :ciphertext_blob => Base64.strict_decode64(data) }
        
        if !context.nil?
          opts[:encryption_context] = to_hash(context)
        end

        client.decrypt(opts).plaintext
      end

      private

      def to_hash val
        if !val.is_a?(Hash)
          val = { :context => val }
        end
        Hash[val.map{ |k, v| [k.to_s, v.to_s] }]
      end

    end
  end
end
